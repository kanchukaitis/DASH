function[design] = stateDimension( design, var, dim, index, takeMean, nanflag )

%%%%% Defaults
if ~exist('takeMean','var')
    takeMean = false;
end
if ~exist('nanflag','var')
    nanflag = 'includenan';
end
%%%%%

% Get the variable design
v = checkDesignVar(design, var);
var = design.varDesign(v);

% Get the dimension index
d = checkVarDim( var, dim );

% Check the indices are allowed
checkIndices(var, d, index);

% Get the metadata for the variable at the indices
meta = metaGridfile( var.file );
meta = meta.( var.dimID{d} );
meta = meta(index);

% Get the variables with coupled state indices.
coupled = find( design.coupleState(v,:) );
coupVars = design.varDesign(coupled);

% For each coupled variable
for c = 1:numel(coupled)
    
    % Get the state indices
    stateDex = getCoupledIndex( coupVars(c), dim, meta );
    
    % Set the values
    newVar = setStateIndices( coupVars(c), dim, stateDex{c}, takeMean, nanflag );
    design.varDesign(coupled(c)) = newVar;
end

% Also set values for the template variable
design.varDesign(v) = setStateIndices( var, dim, index );

end