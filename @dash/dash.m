classdef dash
    %% Contains various utility functions
    
    
    methods (Static)
        
        % Global data for dimension names
        names = dimensionNames;
        
        % Input error checks
        tf = isstrflag( input );        
        tf = isstrlist( input );
        file = checkFileExists(file);        
        assertStrFlag(input, name);
        assertStrList(input, name);
        assertNumericVectorN(input, N, name);
        assertPositiveIntegers(input, allowNaN, allowInf, name);
        str = errorStringList(strings);
        varargout = parseInputs(inArgs, flags, defaults, nPrev);

        % Indices and start, count, stride.
        indices = equallySpacedIndices(indices);
    end
    
end
        