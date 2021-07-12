function[d, dims] = checkDimensions(obj, dims, allowMultiple)
%% Returns the indices of dimensions in a state vector variable. Returns an
% error if any dimensions do not exist. Does not allow duplicate names.
% Also returns the dimension names as strings
%
% [d, dims] = obj.checkDimensions(dims)
%
% [d, dims] = obj.checkDimensions(dims, allowMultiple)
%
% ----- Inputs -----
%
% dims: The input being checked as a list of dimension names.
%
% allowMultiple: A scalar logical indicating whether to allow multiple
%    dimensions as input. Default is true
%
% ----- Outputs -----
%
% d: The indices in the stateVectorVariable dims array
%
% dims: The dimension names as strings

% Default and error check for allowMultiple
if ~exist('allowMultiple','var') || isempty(allowMultiple)
    allowMultiple = true;
end

% Option for empty dims
d = [];
if ~isempty(dims)

    % Check the dimensions are in the variable and get their index.
    % Optionally check for a single input
    listName = sprintf('dimension in the .grid file for the %s variable', obj.name);
    d = dash.assert.strsInList(dims, obj.dims, 'dims', listName);
    if ~allowMultiple && numel(d)>1
        error('dim can only list one dimension. It should be a string scalar or character row vector.');
    end

    % No duplicates
    if numel(d) ~= numel(unique(d))
        error('dims cannot repeat dimension names.');
    end
    
    % Convert dims to string
    dims = string(dims);
end

end