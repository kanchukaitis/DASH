function[rst] = arg(name, details, link, handle)
%% reST format for the description of an input/output
% ----------
%   rst = format.block.arg(name, details, link, handle)
% ----------
%   Inputs:
%       name (string scalar): Name of the input
%       details (string scalar): reST formatted description
%       link (string scalar): Reference link for the input/output
%       handle (string scalar): Section ID for collapsible accordion
%
%   Outputs:
%       rst: The formatted input/output description

% Build components
accordion = format.accordion(name, details, handle, true);
reflink = sprintf(".. _%s:", link);
underline = repmat('+', [1, strlength(name)]);

% Format
rst = strcat(...
    ".. rst-class:: collapse-examples", '\n',...
                                        '\n',...
    reflink,                            '\n',...
                                        '\n',...
    name,                               '\n',...
    underline,                          '\n',...
                                        '\n',...
    accordion                                ... % trailing newline
    );
    
end