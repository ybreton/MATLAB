function status = figureFontSizes(fn,varargin)
% Automatically re-sizes font in figures specified in fn.
%
% figureFontSizes
% figureFontSizes('property','value')
% 
% will change the font sizes of all objects in all axes of all figures in
% the current directory, but not subdirectories of the current in the tree.
% 
% figureFontSizes(fn)
% figureFontSizes(fn,'property','value')
% where     fn          is a string with figure filename, or an
%                            m x n cell array of strings with filenames
%
% will change the font sizes of all objects in all axes of all figures
% specified.
%
% status = figureFontSizes(fn)
% where     status      is a m x n vector of status returned for each
%                           figure in fn:
%                               NaN     empty cell or string, 
%                               0       file not found,
%                               1       file found but not fully processed,
%                               2       file found and processed.
%
% OPTIONAL ARGUMENTS:
% ******************
% FontSize  (default 18)
%                       is a scalar specifying the font size for all
%                       figure axis text.
% ObjPercent (default 100)
%                       is a scalar specifying how much smaller than
%                       FontSize axis children text objects should be. For
%                       the default 18pt axis size, 16pt text in a textbox
%                       within the axis would be 90 percent.
% SaveSuffix (default '')
%                       is a string to append to the end of the filename
%                       when re-saving figures with updated font size. 
%                       For example, 'figure1.fig' would become
%                       'figure1-18pt.fig' with SaveSuffix set to '-18pt'.
% DontClose  (default false)
%                       logical specifying whether to leave figure open
%                       after processing. Default is false, closing figure
%                       upon save.
% DontSave   (default false)
%                       logical specifying whether to save the processed
%                       figure. Default is false, saving the figure upon
%                       processing.
%
%

if mod(nargin,2)==0
    varargin = cat(2,fn,varargin);
    fn = {};
end
if ischar(fn)
    fn = {fn};
end
if isempty(fn)
    fn = FindFiles('*.fig','CheckSubdirs',false);
end
FontSize = 18;
ObjPercent = 100;
SaveSuffix = '';
DontClose = false;
DontSave = false;
process_varargin(varargin);

assert(numel(FontSize)==1,'FontSize must be a scalar.')
assert(ischar(SaveSuffix),'SaveSuffix must be a string.')
assert(numel(DontClose)==1,'DontClose must be a 1x1 logical.')
assert(numel(DontSave)==1,'DontSave must be a 1x1 logical.')
assert(islogical(DontClose),'DontClose must be a 1x1 logical.')
assert(islogical(DontSave),'DontSave must be a 1x1 logical.')

sz = size(fn);
fn = fn(:);

s = nan(sz);
for iF=1:length(fn);
    if ~isempty(fn)
        if exist(fn{iF},'file')==2
            disp(fn{iF});
            h=open(fn{iF});
            s(iF) = 1;
            try
                ah=get(h,'children');
                for iA=1:length(ah)
                    disp(['Axis ' num2str(iA)])
                    set(ah(iA),'FontSize',FontSize);
                    xh=get(ah(iA),'xlabel');
                    set(xh,'FontSize',FontSize);
                    yh=get(ah(iA),'ylabel');
                    set(yh,'FontSize',FontSize);
                    th=get(ah(iA),'title');
                    set(th,'FontSize',FontSize);

                    oh=get(ah(iA),'children');
                    for iO=1:length(oh)
                        properties = get(oh(iO));
                        if isfield(properties,'FontSize')
                            set(oh(iO),'FontSize',FontSize*(ObjPercent)/100);
                        end
                    end
                end
                drawnow;
                filename = get(h,'FileName');
                [d,f,x] = fileparts(filename);
                f2 = [f SaveSuffix];
                filename = [d '\' f2 x];
                if ~DontSave
                    disp(['Saving ' filename 'with updated font size.'])
                    saveas(h,filename)
                end
                if ~DontClose
                    close(h);
                end
                s(iF) = 2;
            catch exception
                str = '';
                for iS=1:length(exception.stack)
                    str = [str sprintf('Exception %d in %s,\nfunction %s line %d:\n%s\n\n',exception.identifier,stack(iS).file,stack(iS).name,stack(iS).line,message)];
                end
                warning(str);
            end
        else
            disp(['Figure ' fn{iF} ' does not exist.'])
            s(iF) = 0;
        end
    end
end

if nargout>0
    status = s;
end