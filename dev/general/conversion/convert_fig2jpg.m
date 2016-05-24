function convert_fig2jpg(varargin)
%
%
%
%

fn = FindFiles('*.fig');
process_varargin(varargin);

if ischar(fn)
    fn = {fn};
end

for f = 1 : length(fn);
    [pn,filename,ext] = fileparts(fn{f});
    pushdir(pn);
    
    fh=open(fn{f});
    set(fh,'name',fn{f})
    ah = get(fh,'children');
    for iA = 1 : length(ah)
        try
            set(ah(iA),'box','off');
        end
    end
    drawnow;
    saveas(fh,[filename '.jpg'],'jpg')
    close(fh);
    
    popdir;
end