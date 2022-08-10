function[varargout] = version
%% dash.version  Return the current version of the DASH toolbox
% ----------    
%   dash.version
%   Prints the current version to the console
%
%   v = dash.version  
%   Returns the version as a string
% ----------
%   Outputs:
%       v (string scalar): The current version string of the DASH toolbox
%
% <a href="matlab:dash.doc('dash.version')">Documentation Page</a>

version = "v4.0.0-beta-3";
if nargout==0
    disp(version);
else
    varargout = {version};
end

end