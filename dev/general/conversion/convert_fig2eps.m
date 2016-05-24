function convert_fig2eps(varargin)
%
%
%
%

if mod(nargin,2)==0
    fn = FindFiles('*.fig');
else
    fn = varargin{1};
    varargin = varargin(2:end);
end
process_varargin(varargin);

if ischar(fn)
    fn = {fn};
end

for f = 1 : length(fn);
    [pn,filename,ext] = fileparts(fn{f});
    if ~isempty(pn)
        pushdir(pn);
    end
    
    fh=open(fn{f});
    set(fh,'name',fn{f})
    ah = get(fh,'children');
    for iA = 1 : length(ah)
        try
            set(ah(iA),'box','off');
        end
    end
    drawnow;
    saveas(fh,[filename '.eps'],'epsc')
    close(fh);
    
    if ~isempty(pn)
        popdir;
    end
end