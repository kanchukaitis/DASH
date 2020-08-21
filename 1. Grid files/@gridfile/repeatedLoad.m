function[X, meta, sources] = repeatedLoad(obj, inputOrder, inputIndices, sources)
%% Loads values from the data sources managed by a .grid file. Optimizes
% the process for repeated load operations (which is a common task
% when building state vector ensembles) by saving and returning pre-built
% dataSource objects. This is a low level method. It provides little error
% checking and is not intended for users. For a user-friendly method
% see "gridfile.load". It may be useful to call "gridfile.review" to 
% implement error checking before using this method.
%
% [X, meta, sources] = obj.repeatedLoad(inputOrder, inputIndices, sources)
%
% ----- Inputs -----
%
% inputOrder: An ordering used to match .grid file dimensions to the 
%    order of dimensions requested for the output array.
%
% inputIndices: A cell vector with an element for each dimension specified
%    in inputOrder. Each element specifies the LINEAR indices to load for
%    that dimension.
%
% sources: A cell vector with an element for each data source in the .grid
%    file. May contain pre-built dataSource objects to hasten repeated
%    loads (see gridfile.review). Use an empty array if not performing
%    repeated loads.
%
% ----- Outputs -----
%
% X: The loaded data values.
%
% meta: Metadata for the loaded data values.
%
% sources: A cell array holding any dataSource objects built for previous load
%    operations.

% Default for unset sources
if ~exist('sources','var') || isempty(sources)
    nSource = size(obj.fieldLength,1);
    sources = cell(nSource,1);
end

% Preallocate indices for all dimensions, the size of the output grid, and
% the dimension limits of the requested values, and the output metadata
nDims = numel(obj.dims);
indices = cell(nDims, 1);
outputSize = NaN(1, nDims);
loadLimit = NaN(nDims, 2); 
meta = obj.meta;

% Get indices for all .grid dimensions
indices(inputOrder) = inputIndices;
for d = 1:nDims
    if isempty(indices{d})
        indices{d} = 1:obj.size(d);
    end
    
    % Determine the size of the dimension, and dimensions limits
    outputSize(d) = numel(indices{d});
    loadLimit(d,:) = [min(indices{d}), max(indices{d})];
    
    % Limit the metadata to these indices
    meta.(obj.dims(d)) = meta.(obj.dims(d))(indices{d},:);
end

% Preallocate the output
X = NaN( outputSize );

% Check each data source to see if it contains any requested data
tooLow = any(loadLimit(:,2) < obj.dimLimit(:,1,:), 1);
tooHigh = any(loadLimit(:,1) > obj.dimLimit(:,2,:), 1);
useSource = find(~tooLow & ~tooHigh);

% Build a data source object for each source with required data or load a
% pre-built object.
for s = 1:numel(useSource)
    if isempty(sources{useSource(s)})
        sources(useSource(s)) = obj.buildSources(useSource(s));
    end
    source = sources{useSource(s)};    
    
    % Preallocate the location of requested data relative to the source
    % grid, and relative to the output grid
    nMerged = numel(source.mergedDims);
    sourceIndices = cell(1, nMerged);
    outputIndices = repmat({':'}, [1,nDims]);
    
    % Get the .grid dimension indices covered by the data source
    for d = 1:nDims
        limit = obj.dimLimit(d,:,useSource(s));
        dimIndices = limit(1):limit(2);
        
        % Get the indices of the requested data relative to the source grid
        % and the output grid
        [ismem, sourceDim] = ismember(obj.dims(d), source.mergedDims);
        if ismem
            [~, loc] = ismember( indices{d}, dimIndices );
            sourceIndices{sourceDim} = loc(loc~=0);
            [~, outputIndices{d}] = ismember( dimIndices(sourceIndices{sourceDim}), indices{d} );
        end
    end
    
    % Load the data from the data source
    Xsource = source.read( sourceIndices );
    
    % Permute to match the order of the .grid dimensions. Add to output
    dimOrder = 1:nDims;
    [~, gridOrder] = ismember( obj.dims, source.mergedDims );
    gridOrder(gridOrder==0) = dimOrder(~ismember(dimOrder,gridOrder));
    X(outputIndices{:}) = permute(Xsource, gridOrder);
end

% Permute to match the requested dimension order
dimOrder = 1:nDims;
inputOrder = [dimOrder(inputOrder), dimOrder(~ismember(dimOrder,inputOrder))];
X = permute(X, inputOrder);
dims = obj.dims(inputOrder);
isdefined = obj.isdefined(inputOrder);

if isfield(meta, obj.attributesName)
    inputOrder(end+1) = max(inputOrder)+1;
end
meta = orderfields(meta, inputOrder);

% Remove any undefined singleton dimensions from the data and the metadata
order = [find(isdefined), find(~isdefined)];
X = permute(X, order);
meta = rmfield( meta, dims(~isdefined) );
    
end