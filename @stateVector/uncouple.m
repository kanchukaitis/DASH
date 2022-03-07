function[obj] = uncouple(obj, variables)
%% stateVector.uncouple  Allow variables to use different metadata when building ensemble members
% ----------
%   obj = obj.uncouple(v)
%   obj = obj.uncouple(variableNames)
%   Uncouple the specified variables from one another. Uncoupled variables
%   are not required to have matching metadata within an ensemble member.  
%   Coupling is transitive, so unlisted variables that are coupled to two
%   or more listed variables will also be uncoupled.
%
%   obj = obj.uncouple(-1)
%   Uncouples all variables in the state vector.
% ----------
%   Inputs:
%       v (logical vector | linear indices): The indices of variables in
%           the state vector that should be coupled. Either a logical
%           vector with one element per state vector variable, or a vector
%           of linear indices.
%       variableNames (string vector): The names of variables in the state
%           vector that should be coupled.
%
%   Outputs:
%       obj (scalar stateVector object): The state vector with updated
%           uncoupled variables.
%
% <a href="matlab:dash.doc('stateVector.uncouple')">Documentation Page</a>

% Setup
header = "DASH:stateVector:uncouple";
dash.assert.scalarObj(obj, header);
obj.assertEditable;

% Check user variables, get indices
if isequal(variables, -1)
    vUser = 1:obj.nVariables;
else
    vUser = obj.variableIndices(variables, true, header);
end

% Check each set of coupled variables for user-specified variables
[sets, nSets] = obj.coupledIndices;
for s = 1:nSets
    vCoupled = sets{s};
    isUserVar = ismember(vCoupled, vUser);

    % If there are 2+ user variables in the set, uncouple the entire set
    % (but maintain self coupling)
    if sum(isUserVar)>1
        obj.coupled(vCoupled,:) = false;
        obj.coupled(1:obj.nVariables+1:end) = true;
    end
end

end