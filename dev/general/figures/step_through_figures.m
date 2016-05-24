function step_through_figures(varargin)

filter = {'*'};
exclusions = {''};
process_varargin(varargin);
if ischar(filter)
    filter = {filter};
end
if ischar(exclusions)
    exclusions = {exclusions};
end

figures = cell(0,1);
for in = 1 : length(filter)
    fn = FindFiles([filter{in} '.fig']);
    figures(length(figures)+1:length(figures)+length(fn)) = fn;
end
out = false(length(figures),1);
for iExc = 1 : length(exclusions)
    for f = 1 : length(figures)
        if ~isempty(regexpi(figures{f},exclusions{iExc}))
            out(f) = true;
        end
    end
end
figures = figures(~out);

for f = 1 : length(figures)
    filename = figures{f};
    pathname = fileparts(filename);
    pushdir(pathname);
    open(filename);
    fh=gcf;
    set(gcf,'position',[1921 57 1280 948])
    set(gcf,'name',filename);
    pause;
    close(fh);
    popdir;
end