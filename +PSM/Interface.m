classdef (Abstract) Interface

    % Information about a forward model's codebase
    properties (Abstract, Constant)
        estimatesR;         % Whether the forward model can estimate R uncertainties
        description;        % A description of the forward model
        repository;         % The Github repository holding the code
        commit;             % The git commit for the version of the forward model supported by DASH
        commitComment;      % Details about the supported commit
    end

    properties (SetAccess = private)
        label_ = "";    % An optional label for the forward model
        hasRows;        % Whether the user provided state vector rows for the forward model 
        rows_;          % The state vector rows to use as input to the forward model
    end

    % Methods that individual PSMs must implement
    methods (Abstract)
        [Y, R] = estimate(obj, X);
        output = rows(obj, rows);
    end

    % Methods for all PSMs
    methods
        function[varargout] = label(obj, label)
            %% PSM.Interface.label  Return or set the label of a PSM object
            % ----------
            %   label = obj.label
            %   Returns the label of the current PSM object.
            %
            %   obj = obj.label(label)
            %   Applies a new label to the PSM object
            % ----------
            %   Inputs:
            %       label (string scalar): A new label for the PSM
            %
            %   Outputs:
            %       label (string scalar): The current label of the object
            %       obj (scalar PSM.Interface object): The object with an updated label.
            %
            % <a href="matlab:dash.doc('PSM.Interface.label')">Documentation Page</a>
            
            % Setup
            header = "DASH:PSM:label";
            dash.assert.scalarObj(obj, header);
            
            % Return current label
            if ~exist('label','var')
                varargout = {obj.label_};
            
            % Apply new label
            else
                obj.label_ = dash.assert.strflag(label, 'label', header);
                varargout = {obj};
            end
        end        
        function[name] = name(obj)
            %% PSM.Interface.name  Return a name for error messages
            % ----------
            %   name = obj.name
            %   Returns a name for the PSM for use in error messages. The
            %   name includes the type of PSM and the label if the PSM has
            %   a label.
            % ----------
            %   Outputs:
            %       name (string scalar): A name for the PSM for use in error messages
            %
            % <a href="matlab:dash.doc('PSM.Interface.name')">Documentation Page</a>

            % Get the type of PSM
            type = class(obj);
            type = type(5:end);
            
            % Unlabeled
            if strcmp(obj.label_, "")
                name = sprintf('The %s PSM', type);
            else
                name = sprintf('The "%s" %s PSM', type);
            end
        end  
        function[output] = parseRows(obj, rows, nRequired)
            %% PSM.Interface.parseRows  Parse rows for a PSM object
            % ----------
            %   obj = obj.parseRows(rows, nRequired)
            %   Error checks and records rows for a PSM object. Throws an error if the
            %   rows are not valid.
            %
            %   rows = obj.rows
            %   Returns the current rows of the PSM object.
            %
            %   obj = obj.rows('delete')
            %   Deletes any previously specified rows from the PSM object.
            % ----------
            %   Inputs:
            %       rows (numeric array [1 x nMembers x nEvolving]): The state vector
            %           rows that hold the inputs for the PSMs.
            %       nRequired (numeric scalar): The number of state vector
            %           rows required to run the PSM
            %
            %   Outputs:
            %       obj (scalar PSM object): The PSM with updated rows
            %       rows (numeric array [1 x nMembers x nEvolving]): The current rows
            %           for the PSM object.
            %
            % <a href="matlab:dash.doc('PSM.Interface.parseRows')">Documentation Page</a>

            % Get the header
            header = class(obj);
            header = replace(header, '.', ':');
            header = sprintf('DASH:%s', header);
            
            % Require a scalar PSM object
            try
                dash.assert.scalarObj(obj, header);
            catch ME
                id = ME.identifier;
                message = replace(ME.message, "parseRows", "rows");
                ME = MException(id, '%s', message);
                throwAsCaller(ME);
            end
            
            % Return values
            if ~exist('rows', 'var')
                output = obj.rows_;
            
            % Delete
            elseif dash.is.strflag(rows) && strcmpi(rows, 'delete')
                obj.rows_ = [];
                obj.hasRows = false;
                output = obj;
            
            % Set rows. Error check rows
            else
                try
                    dash.assert.blockTypeSize(rows, 'numeric', [], 'rows', header);
                    dash.assert.positiveIntegers(rows, 'rows', header);
            
                    % Check the number of rows
                    nRows = size(rows, 1);
                    if nRows ~= nRequired
                        id = sprintf('%s:wrongNumberOfRows', header);
                        error(id, ['%s requires %.f rows to run, but the "rows" input ',...
                            'has %.f rows instead.'], obj.name, nRequired, nRows);
                    end
            
                % Minimize error stacks
                catch ME
                    throwAsCaller(ME);
                end
            
                % Record the rows
                obj.rows_ = rows;
                obj.hasRows = true;
                output = obj;
            end    
        end
        function[] = disp(obj)
            %% PSM.Interface.disp  Display a PSM object in the console
            % ----------
            %   obj.disp
            %   Displays a PSM object in the console. Begins by displaying
            %   a link to the class documentation. If the object is scalar,
            %   displays the label (if there is one). Also displays the
            %   status of assigned state vector rows. Displays any model
            %   parameters.
            %
            %   If the object is an array, displays the array size. If any
            %   of the objects in the array have labels, displays the
            %   labels. Any object without a label is listed as "<no
            %   label>". If the array is empty, declares that the array is
            %   empty.
            % ----------
            %   Outputs:
            %       Displays the object in the console.
            %
            % <a href="matlab:dash.doc('PSM.Interface.disp')">Documentation Page</a>
            
            % Class documentation link
            type = class(obj);
            link = sprintf('<a href="matlab:dash.doc(''%s'')">%s PSM</a>', type, type(5:end));
            
            % If not scalar, display array size
            if ~isscalar(obj)
                info = dash.string.nonscalarObj(obj, link);
                fprintf(info);

                % Exit if empty
                if isempty(obj)
                    return
                end

                % Collect labels
                labels = strings(size(obj));
                for k = 1:numel(obj)
                    labels(k) = obj(k).label_;
                end
                
                % Display labels
                unlabeled = strcmp(labels, "");
                if ~all(unlabeled, 'all')
                    fprintf('    Labels:\n');
                    labels(unlabeled) = "<no label>";
                    if ismatrix(labels)
                        fprintf('\n');
                    end
                    disp(labels);
                end

            % Scalar object, start with title
            else
                fprintf('%s with properties:\n\n', link);

                % Label
                pad = '';
                if ~strcmp(obj.label_, "")
                    fprintf('    Label: %s\n', obj.label);
                    pad = ' ';
                end
                
                % Rows
                if isempty(obj.rows_)
                    details = 'none';
                else
                    details = 'set';
                end
                fprintf('%s    Rows: %s\n', pad, details);
                [nMembers, nEvolving] = size(obj.rows_, 2:3);
                if nMembers>1
                    fprintf('%s\t\tFor %.f ensemble members\n', pad, nMembers);
                end
                if nEvolving>1
                    fprintf('%s\t\tFor %.f evolving ensembles\n', pad, nEvolving);
                end
                fprintf('\n');

                % Get parameter fields
                interfaceProps = properties('PSM.Interface');
                objProps = properties(obj);
                isparameter = ~ismember(objProps, interfaceProps);
                parameterNames = objProps(isparameter);

                % Build and display parameter structure
                s = struct;
                for p = 1:numel(parameterNames)
                    name = parameterNames{p};
                    s.(name) = obj.(name);
                end
                fprintf('    Parameters:\n');
                disp(s);
            end
        end
    end

end