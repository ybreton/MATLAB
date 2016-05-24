function [ph,eh,ah,fh] = plot_grouped_Y(X,Y,varargin)
% plots Y as a function of X, grouped by unique levels of X.
% [ph,eh,ah,fh] = plot_grouped_Y(X,Y,varargin)
% where     ph is a handle to plot objects,
%           eh is a handle to errorbar objects,
%           ah is a handle to axis,
%           fh is a handle to figure.
% OPTIONAL
%           fh, figure handle (default gcf)
%           ah, axis handle (default gca)
%           dist, distribution for confidence interval; values are
%               bootstrp (default, bootstrap-derived confidence intervals)
%               normal (based on t distribution of Y values)
%               binomial (based on binomial distribution of Y values)
%

fh=gcf;
ah=gca;
dist='bootstrp';
alpha=0.05;
if size(Y,2)>1
    dist='binomial';
end
process_varargin(varargin);

pten = 10.^(floor(log10(alpha/2))-1);
while (alpha/2)/pten<25
    pten = pten/10;
end
nBoot = 1./pten;

set(0,'currentfigure',fh)
set(fh,'currentaxes',ah)

if size(X,2)==1
    uniqueX = unique(X,'rows');
    ph = nan;
    eh = nan;
    for r = 1 : size(uniqueX,1)
        comp = repmat(uniqueX(r,:),size(X,1),1);
        idX = all(comp == X,2);
        Yr = Y(idX);
        m(r) = nanmean(double(Yr));
        if nargout>1
            switch dist
                case 'binomial'
                    if size(Yr,2)==1
                        [m(r),lo(r),hi(r)] = binocis(nansum(Yr),nansum(~Yr),1,alpha);
                    else
                        [m(r),lo(r),hi(r)] = binocis(nansum(Yr(:,1)),nansum(Yr(:,2)),1,alpha);
                    end
                case 'normal'
                    n = length(Yr(~isnan(Yr)));
                    lo(r) = m(r)+tinv(0.025,n-1)*nanstderr(Yr);
                    hi(r) = m(r)+tinv(0.975,n-1)*nanstderr(Yr);
                otherwise
                    bootstat=bootstrp(nBoot,@mean,Yr);
                    m(r) = median(bootstat);
                    lo(r) = prctile(bootstat,2.5);
                    hi(r) = prctile(bootstat,97.5);
            end
        end
    end
    ph=plot(uniqueX,m,'ko');
    if nargout>1
        hold on
        eh=errorbar(uniqueX,m,m-lo,hi-m);
        set(eh,'linestyle','none')
        set(eh,'color','k')
        hold off
    end
else
    % second column to the end is lines.
    L = X(:,2:end);
    uniqueL = unique(L,'rows');
    % first column is X.
    X = X(:,1);
    cmap = hsv(size(uniqueL,1));
    ph = nan(size(uniqueL,1),1);
    eh = nan(size(uniqueL,1),1);
    for lid = 1 : size(uniqueL,1);
        idL = repmat(uniqueL(lid,:),size(L,1),1)==L;
        uniqueX = unique(X(idL));
        hold on
        for r = 1 : size(uniqueX,1)
            idX = X==uniqueX(r) & all(idL,2);
            Yr = Y(idX,:);
            if size(Yr,2)>1
                m(r) = binocis(nansum(Yr(:,1)),nansum(Yr(:,2)));
            else
                m(r) = nanmean(double(Yr));
            end
            if nargout>1
                switch dist
                    case 'binomial'
                        if size(Yr,2)==1
                            [m(r),lo(r),hi(r)] = binocis(nansum(Yr(:,1)),nansum(Yr(:,2)),1,alpha);
                        else
                            [m(r),lo(r),hi(r)] = binocis(nansum(Yr(:,1)),nansum(Yr(:,2)),1,alpha);
                        end
                    case 'normal'
                        n = length(Yr(~isnan(Yr)));
                        lo(r) = m(r)+tinv(0.025,n-1)*nanstderr(Yr);
                        hi(r) = m(r)+tinv(0.975,n-1)*nanstderr(Yr);
                    case 'stderr'
                        lo(r) = m-nanstderr(Yr);
                        hi(r) = m+nanstderr(Yr);
                    otherwise
                        if length(Yr)>1
                            bootstat=bootstrp(nBoot,@mean,Yr);
                            m(r) = median(bootstat);
                            lo(r) = prctile(bootstat,2.5);
                            hi(r) = prctile(bootstat,97.5);
                        else
                            m(r) = Yr;
                            lo(r) = -inf;
                            hi(r) = inf;
                        end
                end
            end
            
        end
        ph(lid)=plot(uniqueX,m,'o','markerfacecolor',cmap(lid,:),'markeredgecolor',cmap(lid,:));
        legendStr{lid} = sprintf('%.1f\n',uniqueL(lid,:));
        if nargout>1
            eh(lid)=errorbar(uniqueX,m,m-lo,hi-m);
            set(eh(lid),'linestyle','none')
            set(eh(lid),'color',cmap(lid,:))
        end
    end
    legend(ph,legendStr)
    hold off
end