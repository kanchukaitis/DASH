classdef ensemble
    
    properties
        file; % The .ens file associated with the object
        
        hasnan;
        meta;
        stateVector;
        
        members; % Which ensemble members to load
        v; % The indices of the variables to load.
    end
    
    % Constructor
    methods
        function obj = ensemble(filename)
            %% Creates a new ensemble object
            %
            % obj = ensemble(filename)
            % Finds a .ens file with the specified name on the active path
            % and returns an associated ensemble object.
            %
            % obj = ensemble(fullname)
            % Returns an ensemble object for a .ens file with the specified
            % full file path.
            %
            % ----- Inputs -----
            %
            % filename: The name of a .ens file on the active path. A string.
            %
            % fullname: The full file path to a .ens file. A string.
            %
            % ----- Outputs -----
            %
            % obj: An ensemble object for the specified .ens file.
            
            % Error check
            obj.file = dash.assertStrFlag(filename, "filename");
            
            % Build and check the matfile for the .ens file
            ens = obj.buildMatfile;
            
            % Update properties
            obj.hasnan = ens.hasnan;
            obj.meta = ens.meta;
            obj.stateVector = ens.stateVector;
            
            % Load everything by default
            obj.members = (1:obj.meta.nEns)';
            obj.v = (1:numel(obj.meta.variableNames))';
        end
    end
        
    % Object utilities
    methods
        ens = buildMatfile(obj);
    end
    
    % User methods
    methods
        add(obj, nAdd, showprogress)
        load(obj);
        loadGrids(obj);
        obj = loadMembers(obj, members);
        obj = loadVariables(obj, variables);
        variableNames(obj);
        info(obj);
    end
end