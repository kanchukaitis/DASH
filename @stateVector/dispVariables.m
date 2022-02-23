function[] = dispVariables(obj)

% Initialize Field
fprintf('    Vector:\n');

% No variables case
if obj.nVariables==0
    fprintf('        No variables\n\n');
    return
end

% Get the number of rows for each variable and dimension details
nRows = NaN(obj.nVariables, 1);
details = strings(obj.nVariables, 1);
for v = 1:obj.nVariables
    [sizes, types] = obj.variables_(v).stateSizes;
    nRows(v) = prod(sizes);
    types = strcat(types, ' (', string(sizes), ')');
    details(v) = strjoin(types, ' x ');
end
nRows = string(nRows);

% Get width formats
nameWidth = max(strlength(obj.variableNames));
rowsWidth = max(strlength(nRows));
format = sprintf('        %%%.fs - %%%.fs rows', nameWidth, rowsWidth);

% Include dimension info and details link
link = sprintf('<a href="matlab:%s.variable(%%.f)">Show details</a>', inputname(1));
format = [format, '  |  %s   ', link, '\n'];

% Print each variable
for v = 1:obj.nVariables
    fprintf(format, obj.variableNames(v), nRows(v), details(v), v);
end
fprintf('\n');

end