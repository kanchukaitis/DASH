classdef dash
    %% Contains various utility functions
    
    methods (Static)
        
        % Maths
        [Xmean, Xdev] = decompose(X, dim);
        [C, Ycov] = estimateCovariance(X, Y);
        dist = haversine(latlon1, latlon2);
        Y = gaspariCohn2D(X, R, scale);
        closest = closestLatLon(coords, lats, lons);
        
        % Localization                
        [wloc, yloc] = localizationWeights(type, varargin);
        [wloc, yloc] = gc2dLocalization(ensCoords, siteCoords, R, scale);
        
        % Misc
        [names, lon, lat, coord, lev, time, run, var]  = dimensionNames;
        convertToV7_3(filename);
        [X, order] = permuteDimensions(X, index, iscomplete, nDims);
        tf = bothNaN(A, B);
        s = loadMatfileFields(file, fields, extName);
        str = version;
        
        % Input parsing
        varargout = parseInputs(inArgs, flags, defaults, nPrev);
        [input, wasCell] = parseInputCell(input, nDims, name);
        input = parseLogicalString(input, nDims, logicalName, stringName, allowedStrings, lastTrue, name);
        index = parseListIndices(input, strName, indexName, list, listName, lengthName, inputNumber, eltNames);
        
        % Structures
        [s, inputs] = preallocateStructs(fields, siz);
        values = collectField(s, field);
        
        % Files
        path = checkFileExists(file);  
        path = unixStylePath(path);
        path = relativePath(toFile, fromFolder);
        filename = setupNewFile(filename, ext, overwrite);
        
        % Strings and string lists
        tf = isstrflag( input );        
        tf = isstrlist( input );
        input = assertStrFlag(input, name);
        input = assertStrList(input, name);
        k = checkStrsInList(input, list, name, message);
        str = messageList(list);
        
        % Input assertions
        assertScalarType(input, name, type, typeName);
        assertRealDefined(input, name, allowNaN, allowInf, allowComplex);
        assertVectorTypeN(input, type, N, name);
        assertPositiveIntegers(input, allowNaN, allowInf, name);
        
        % Indices
        indices = checkIndices(indices, name, dimLength, dimName);
        indices = equallySpacedIndices(indices);
    end
    
    % New stuff
    methods (Static)
        limits = buildLimits(nEls);
        dims = commaDelimitedDims(dims);
        meta = checkMetadataField(meta, dim);
        tf = hasDuplicateRows(meta)
    end
    
end
        