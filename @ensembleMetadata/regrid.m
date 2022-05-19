function[X, metadata] = regrid(obj, variable, X, varargin)
%% ensembleMetadata.regrid  Regrids a variable in a state vector ensemble
% ----------
%   [V, metadata] = obj.regrid(variableName, X)
%   [V, metadata] = obj.regrid(v, X)
%   Regrids a variable in a state vector ensemble. The variable is
%   extracted from the overall state vector, and then reshaped into a
%   gridded dataset. The method also returns metadata for the dimensions of
%   the regridded dataset. This metadata will include metadata for any
%   state dimensions or sequences used in the state vector. The metadata
%   for sequence and standard state dimensions will have one row per
%   element along the dimension. The metadata for state dimensions that
%   implement a mean will have one row per data element used in the mean.
%
%   This method works on N-dimensional data arrays X. X can have any number
%   of dimensions, but at least one dimension must have the same length as
%   the state vector. By default, the method acts along the the first
%   dimension with this length. Only this state vector dimension is reshaped into a
%   gridded dataset. The dimensions before and after the state vector
%   dimension are not reshaped. The returned metadata only includes
%   information for the reshaped state vector dimensions. It does not
%   include information for the other dimensions of X.
%
%   By default, the method removes any singleton regridded state vector
%   dimensions (regridded state vector dimensions that have a length of 1).
%   Neither the returned array nor the returned metadata will include these
%   removed singleton dimensions. If all the regridded state vector
%   dimensions are singleton (i.e. the variable has a length of 1), then
%   the length of the regridded state vector dimension will be 1, but the
%   metadata will not contain information on any dimension.
%
%   ... = obj.regrid(..., 'order', dimensions)
%   Returns the regridded data in a custom dimension order. The order of
%   dimensions in the regridded dataset will match the order specified in
%   the dimensions list. If the state vector has state dimensions or
%   sequences that are not specified in the dimensions list, the
%   unspecified dimensions are moved to the end of the order. If a
%   singleton dimension is specified in the dimensions list, the singleton
%   dimension will not be removed from the regridded dataset and metadata.
%
%   ... = obj.regrid(..., 'dim', d)
%   Indicate the dimension of X that should be used as the state vector
%   dimension. The length of the dimension must match the length of the
%   state vector.
%
%   ... = obj.regrid(..., 'singletons', singletons)
%   ... = obj.regrid(..., 'singletons', "keep"|"k"|true)
%   ... = obj.regrid(..., 'singletons', "remove"|"r"|false)
%   Specify how to treat regridded singleton dimensions. By default,
%   singleton dimensions are removed from the regridded output unless they
%   are listed in the dimension order. Use "keep"|"k"|true to keep all
%   singleton dimensions in the regridded dataset. Using "remove"|"r"|false
%   enacts the default behavior and removes singleton dimensions that are
%   not listed in the dimension order.
% ----------

% Setup
header = "DASH:ensembleMetadata:regrid";
dash.assert.scalarObj(obj, header);

% Get variable index
v = obj.variableIndices(variable, false, header);
if numel(v)>1
    tooManyVariablesError;
end

% Parse optional inputs
defaults = {[], [], "remove"};
[stateOrder, dim, singletons] = dash.parse.nameValue(varargin, ...
                        ["order","dim","singletons"], defaults, 2, header);
switches = {["r","remove"], ["k","keep"]};
singletons = dash.parse.switches(singletons, switches, 1, 'singletons', 'allowed option', header);

% Get the size of the data array
siz = size(X);
nArrayDims = numel(siz);

% Error check user-provided dimension
if ~isempty(dim)
    dash.assert.scalarType(dim, 'numeric', 'dim', header);
    dash.assert.positiveIntegers(dim, 'dim', header);
    if siz(dim) ~= obj.length
        wrongSizeError;
    end

% Otherwise, locate first dimension of the required length
else
    haveDimension = false;
    for d = 1:nArrayDims
        if siz(d)==obj.length
            dim = d;
            haveDimension = true;
            break
        end
    end

    % Throw error if no dimensions have the correct length
    if ~haveDimension
        noDimensionError;
    end
end

% Update the data size if dim is greater than the number of dimensions
if dim>nArrayDims
    nArrayDims = dim;
    siz(end+1:dim) = 1;
end

% Track whether dimensions were listed by the user
nStateDims = numel(obj.stateDimensions{v});
userDimension = false(1, nStateDims);

% Default or error check dimension order
if isempty(stateOrder)
    stateOrder = 1:nStateDims;
else
    stateOrder = dash.assert.strlist(stateOrder, 'dimension order', header);
    dash.assert.uniqueSet(stateOrder, 'dimension', header);
    if ~isrow(stateOrder)
        stateOrder = stateOrder';
    end

    % Require dimensions are state dimensions
    [isdim, stateOrder] = ismember(stateOrder, obj.stateDimensions{v});
    if ~all(isdim)
        notStateDimensionError;
    end

    % Record listed dimensions. Get full state dimension order including
    % state dimensions not listed by the user
    userDimension(stateOrder) = true;
    allDims = 1:nStateDims;
    remainingDims = allDims(~ismember(allDims, stateOrder));
    stateOrder = [stateOrder, remainingDims];
end

% Note which dimensions to keep in the final dataset
if singletons
    keep = true(1, nStateDims);
else
    keep = obj.stateSize{v}>1 | userDimension;
end
nKeep = sum(keep);

% Extract the variable from the overall state vector
nDims = max(dim, nArrayDims);
indices = repmat({':'}, 1, nDims);
indices{dim} = obj.find(v);
X = X(indices{:});

% Reshape the state vector
stateSize = obj.stateSize{v}(keep);
if isempty(stateSize)
    stateSize = 1;
end
siz = [siz(1:dim-1), stateSize, siz(dim+1:end)];
X = reshape(X, siz);

% Adjust state order for removed dimensions
dRemove = find(~keep);
stateOrder(ismember(stateOrder, dRemove)) = [];
if isempty(stateOrder)
    stateOrder = 1;
    nKeep = 1;
else
    adjust = sum(stateOrder>dRemove', 1);
    stateOrder = stateOrder - adjust;
end

% Permute to requested dimension order. Preserve leading and trailing
% dimensions of the full data array.
order = [1:dim-1,  stateOrder+dim-1,  (dim+1:nArrayDims)+nKeep-1];
X = permute(X, order);

% Only return metadata if requested
if nargout<2
    return
end

% Initialize metadata. Return if there are no kept dimensions
metadata = gridMetadata;
if ~any(keep)
    return
end

% Get the metadata for each kept dimension
metadata = gridMetadata;
for d = 1:numel(obj.stateDimensions{v})
    if keep(d)
        dimMetadata = obj.state{v}{d};
        if obj.stateType{v}(d) == 1
            dimMetadata = permute(dimMetadata, [3 2 1]);
        end

        % Update the output object
        dimension = obj.stateDimensions{v}(d);
        metadata = metadata.edit(dimension, dimMetadata);
    end
end

% Order the metadata
dimensions = obj.stateDimensions{v}(keep);
dimensionOrder = dimensions(stateOrder);
metadata = metadata.setOrder(dimensionOrder);

end