function flag = removeBoxplotXtick(fh)
% Removes the annoying, hanging tick labels on boxplots.
% flag = removeBoxplotXtick(fh)
% where     flag        is a stop code indicating successful (1) or
%                           unsuccessful (0) removal of the x-tick.
%
%           fh          is a handle to the figure object on which to
%                           operate.
%
%
flag = false;
try
    hB=findobj(fh,'Type','hggroup');
    hL=findobj(hB,'Type','text');
    delete(hL);
catch exception
    disp(exception.message);
end
flag = true;