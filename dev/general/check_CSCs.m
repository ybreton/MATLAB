function s = check_CSCs(varargin)

fd=pwd;
firstN=[];
process_varargin(varargin);

if ischar(fd)
    fd = {fd};
end

for d = 1 : length(fd)
    pushdir(fd{d});
    
    fn = FindFiles('*.ncs');
    cn = nan(length(fn),1);
    for f = 1 : length(fn)
        [~,fileStr,ext] = fileparts(fn{f});
        idCSC = regexpi(fileStr,'CSC');
        cn(f) = str2double(fileStr(idCSC+3:end));
    end
    [cn,id] = sort(cn);
    fn = fn(id);
    if ~isempty(firstN)
        fn = fn(1:firstN);
        cn = cn(1:firstN);
    end
    
    nvt = FindFiles('*.nvt');
    zipFile = FindFiles('*.zip');
    unzipped = false;
    if isempty(nvt) & ~isempty(zipFile)
        unzip(zipFile{1});
        unzipped = true;
        nvt = FindFiles('*.nvt');
    end
    
    xd = [];
    xt = [];
    yd = [];
    yt = [];
    for n = 1 : length(nvt)
        [x0,y0] = LoadVT_lumrg(nvt{n});
        xd = cat(1,xd,x0.data);
        xt = cat(1,xt,x0.range);
        yd = cat(1,yd,y0.data);
        yt = cat(1,yt,y0.range);
    end
    [xt,id] = sort(xt);
    xd = xd(id);
    [yt,id] = sort(yt);
    yt = yt(id);
    x = tsd(xt,xd);
    y = tsd(yt,yd);
    if unzipped
        for n = 1 : length(nvt)
            delete(nvt{n})
        end
    end
    
    RR = FindFiles('RR-*.mat');
    fprintf('\n Press enter to move on to next trial \n');
    for s = 1 : length(RR)
        fileStr = RR{s};
        idSlash = regexpi(fileStr,'\');
        fileStr = fileStr(max(idSlash)+1:end);
        idDash = regexpi(fileStr,'-');
        
        yyyy = fileStr(idDash(1)+1:idDash(2)-1);
        mm = fileStr(idDash(2)+1:idDash(3)-1);
        dd = fileStr(idDash(3)+1:idDash(4)-1);
        ssn = [yyyy '-' mm '-' dd];
        sd = load(RR{s});
        first = sd.EnteringZoneTime(1)*1e-6;
        last = sd.ExitZoneTime(end)*1e-6+60;
        for f = 1 : length(fn)
            c = LoadCSC(fn{f});
            fprintf('Processed CSC%d \n',cn(f));
            c = c.restrict(first,last);
            CSC{f} = ctsd(min(c.range),c.dt,c.data);
            clear c
        end
        cmap = lines(length(fn));
        
        for t = 1 : length(sd.EnteringZoneTime)
            t1 = sd.EnteringZoneTime(t)*1e-6;
            if t<=length(sd.ExitZoneTime)
                t2 = sd.ExitZoneTime(t)*1e-6;
            else
                t2 = max(x.range);
            end
            x0 = x.restrict(t1,t2);
            y0 = y.restrict(t1,t2);
            
            clf
            subplot(1,2,1)
            title(sprintf('%s, trial %d',ssn,t))
            hold on
            plot(-y.data,-x.data,'-','color',[0.8 0.8 0.8],'linewidth',0.5)
            scatterplotc(-y0.data,-x0.data,x0.range)
            caxis([min(x0.range) max(x0.range)]);
            cbh=colorbar;
            axis square
            set(gca,'ylim',[-720 0])
            set(gca,'xlim',[-480 0])
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            hold off
            drawnow
            
            for f = 1 : length(fn)
                subplot(length(fn),2,2*f)
                hold on
                c = CSC{f}.restrict(t1,t2);
                plot(c.range,c.data,'-','color',cmap(f,:));
                ylabel(sprintf('CSC%d',f));
                hold off
                drawnow
            end
            pause;
        end
    end
    popdir;
end