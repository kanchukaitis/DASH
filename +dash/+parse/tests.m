function[] = tests

vararginFlags;
inputOrCell;
nameValue;

end

function[] = vararginFlags

tests  = {
    % description, input, spacing, nPrevious, should pass, outout
    'all flags', {'option1', 'name2', 'dim3'}, [], [], true, ["option1";"name2";"dim3"];
    'mixed string and char flags', {'option1',"name2",'dim3'}, [], [], true, ["option1";"name2";"dim3"];
    'spaced flags', {'option',5,'flag',3}, 2, [], true, ["option";"flag"];
    'not flags', {5,6,7}, [], [], false, [];
    'custom error', {5}, [], 4, false, [];
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,5};
    if shouldFail
        try
        	dash.parse.vararginFlags(tests{t,2}, tests{t,3}, tests{t,4}, testHeader);
        catch ME
        end
        assert(contains(ME.identifier, testHeader), tests{t,1});
        
    else
        flags = dash.parse.vararginFlags(tests{t,2}, tests{t,3}, tests{t,4}, testHeader);
        assert(isequal(flags, tests{t,6}), tests{t,1});
    end
end

end
function[] = inputOrCell

tests = {
    'single array directly', 5, 1, [], true, {5}, false;
    'single array in cell', {5}, 1, [], true, {5}, true;
    'multiple arrays', {1,2,3}, 3, [], true, {1,2,3}, true;
    'not a cell vector', 5, 3, [], false, [], [];
    'incorrect number of arrays', {1 2 3}, 4, [], false, [], [];
    'custom error', {1 2 3}, 4, 'test', false, [], [];
    };
testHeader = 'test:header';

for t = 1:size(tests,1)
    shouldFail = ~tests{t,5};
    if shouldFail
        try
            dash.parse.inputOrCell(tests{t,2}, tests{t,3}, tests{t,4}, testHeader);
        catch ME
        end
        assert(contains(ME.identifier, testHeader));
        
    else
        [input, wasCell] = dash.parse.inputOrCell(tests{t,2}, tests{t,3}, tests{t,4}, testHeader);
        assert(isequal(input, tests{t,6}) && wasCell==tests{t,7}, tests{t,1});
    end
end

end
function[] = nameValue

tests = {
    


    
    