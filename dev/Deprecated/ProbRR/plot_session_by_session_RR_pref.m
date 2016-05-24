function [fit,fh] = plot_session_by_session_RR_pref(varargin)
% [betas_logit_fit,fh] = plot_session_by_session_RR_pref(varargin)
% produces a figure of the session-by-session restaurant row preference
% along with the results of a logistic fit of the form:
% u = b(1)*(Z==1)+b(2)*(Z==2)+b(3)*(Z==3)+b(4)*(Z==4)+b(5)*n+b(6)*Pr
% pref = 1/(1+u)
% where     Z==z is an indicator function for zone,
%           n is the number of food pellets,
%           Pr is the probability of reinforcement.
%
% Optional arguments:
% legendOff             suppresses a legend for each plot (default true)
% session_list          list of sessions to include (default all in directory and subdirectories)
% alpha                 type-I error level for (1-alpha) confidence bound (default 0.05 for 95% CI)
% exclude_sessions      list of sessions to exclude (default none)

nZones = 4;
legendOff = true;
session_list = FindFiles('*.mat');
for f = 1 : length(session_list)
    fn = session_list{f};
    ssn_list = fileparts(fn);
    id = min(regexpi(ssn_list,'\R*-*-*-'));
    ssn_list = ssn_list(id+1:end);
    session_list{f} = ssn_list;
end
alpha = 0.05;
exclude_sessions = cell(0,1);
process_varargin(varargin);

if ischar(exclude_sessions)
    exclude_sessions = {exclude_sessions};
end

files = cell(0,1);
for f = 1 : length(session_list)
    fn = FindFiles(['*' session_list{f} '*.mat']);
    idInc = true(length(fn),1);
    for f0 = 1 : length(fn)
        for ex = 1 : length(exclude_sessions);
            if ~isempty(regexpi(fn{f0},exclude_sessions{ex}))
                idInc(f0) = false;
            end
        end
    end
    fn = fn(idInc);
    files(length(files)+1:length(files)+length(fn))=fn;
end
session_list = files;
clear files

Skip = nan(4,11);
Entry = nan(4,11);
ZoneProbSkipPref = nan(4,11);
ZoneSkipPref = nan(4,1);
ProbSkipPref = nan(1,11);

PelletsPerDrop = nan(4,1);
n = 0;
for d = 1 : length(session_list)
    vars = {'ZoneIn' 'ZoneProbability' 'nPelletsPerDrop'};
    load(session_list{d},vars{:})
    try
        ZoneIn = ZoneIn(:)';
        
        n = n + 1;
        files{n} = session_list{d};
        ssn_name = fileparts(files{n});
        id = max(regexpi(ssn_name,'\'));
        directories{n,1} = ssn_name(id+1:end);
        
        [Skip(:,:,n),Entry(:,:,n),ZoneProbSkipPref(:,:,n),ZoneSkipPref(:,:,n),ProbSkipPref(:,:,n)] = RevealedPreferences;
        if numel(nPelletsPerDrop)==1
            nPelletsPerDrop = repmat(nPelletsPerDrop,4,1);
        end
        PelletsPerDrop(:,:,n) = nPelletsPerDrop(:);
        clear ZoneIn ZoneProbability nPelletsPerDrop
    end
end
directories = unique(directories);
session_list = files;
% Number of pellets, list
PelletsDispensed = unique(PelletsPerDrop(:));

% for fitting.
probabilities = 0:0.1:1;
x0 = [];
y0 = [];
for ssn = 1 : size(Skip,3)
    for zone = 1 : size(Skip,1)
        nPellets = PelletsPerDrop(zone,1,ssn);
        for prob = 1 : size(Skip,2)
            x0 = [x0; zone nPellets probabilities(prob)];
            y0 = [y0; Entry(zone,prob,ssn) Entry(zone,prob,ssn)+Skip(zone,prob,ssn)];
        end
    end
end

if length(unique(x0(:,2)))>1 & length(unique(x0(:,3)))>1
    [fitX,betas_logit_fit,deviance,stats] = logit_fit_zones(x0,y0(:,1),y0(:,2)-y0(:,1));
elseif length(unique(x0(:,2)))==1 & length(unique(x0(:,3)))>1
    exCol = 2;
    cols = 1:size(x0,2);
    [fitX] = logit_fit_zones(x0,y0(:,1),y0(:,2)-y0(:,1));
    [~,betas_logit_fit0,deviance,stats] = logit_fit_zones(x0(:,cols~=exCol),y0(:,1),y0(:,2)-y0(:,1));
    exCol = nZones+1;
    cols = 1:size(fitX,2);
    betas_logit_fit(cols~=exCol) = betas_logit_fit0;
    betas_logit_fit(exCol) = 0;
    stats.se(cols~=exCol) = stats.se;
    stats.t(cols~=exCol) = stats.t;
    stats.p(cols~=exCol) = stats.p;
    stats.se(exCol) = 0;
    stats.t(exCol) = NaN;
    stats.p(exCol) = 1;
    stats.beta(cols~=exCol) = stats.beta;
    stats.beta(exCol) = 0;
    stats.coeffcorr(cols~=exCol,cols~=exCol) = stats.coeffcorr;
    stats.coeffcorr(:,exCol) = 0;
    stats.coeffcorr(exCol,:) = 0;
    stats.covb(cols~=exCol,cols~=exCol) = stats.covb;
    stats.covb(:,exCol) = 0;
    stats.covb(exCol,:) = 0;
elseif length(unique(x0(:,2)))>1 & length(unique(x0(:,3)))==1
    exCol = 3;
    cols = 1:size(x0,2);
    [fitX] = logit_fit_zones(x0,y0(:,1),y0(:,2)-y0(:,1));
    [~,betas_logit_fit0,deviance,stats] = logit_fit_zones(x0(:,cols~=exCol),y0(:,1),y0(:,2)-y0(:,1));
    exCol = nZones+2;
    cols = 1:size(fitX,2);
    betas_logit_fit(cols~=exCol) = betas_logit_fit0;
    betas_logit_fit(exCol) = 0;
    stats.se(cols~=exCol) = stats.se;
    stats.t(cols~=exCol) = stats.t;
    stats.p(cols~=exCol) = stats.p;
    stats.se(exCol) = 0;
    stats.t(exCol) = NaN;
    stats.p(exCol) = 1;
    stats.beta(cols~=exCol) = stats.beta;
    stats.beta(exCol) = 0;
    stats.coeffcorr(cols~=exCol,cols~=exCol) = stats.coeffcorr;
    stats.coeffcorr(:,exCol) = 0;
    stats.coeffcorr(exCol,:) = 0;
    stats.covb(cols~=exCol,cols~=exCol) = stats.covb;
    stats.covb(:,exCol) = 0;
    stats.covb(exCol,:) = 0;
else
    exCol = [2 3];
    cols = 1:size(x0,2);
    [fitX] = logit_fit_zones(x0,y0(:,1),y0(:,2)-y0(:,1));
    [~,betas_logit_fit0,deviance,stats] = logit_fit_zones(x0(:,cols~=exCol),y0(:,1),y0(:,2)-y0(:,1));
    exCol = [nZones+1 nZones+2];
    cols = 1:size(fitX,2);
    betas_logit_fit(cols~=exCol) = betas_logit_fit0;
    betas_logit_fit(exCol) = 0;
    stats.se(cols~=exCol) = stats.se;
    stats.t(cols~=exCol) = stats.t;
    stats.p(cols~=exCol) = stats.p;
    stats.se(exCol) = 0;
    stats.t(exCol) = NaN;
    stats.p(exCol) = 1;
    stats.beta(cols~=exCol) = stats.beta;
    stats.beta(exCol) = 0;
    stats.coeffcorr(cols~=exCol,cols~=exCol) = stats.coeffcorr;
    stats.coeffcorr(:,exCol) = 0;
    stats.coeffcorr(exCol,:) = 0;
    stats.covb(cols~=exCol,cols~=exCol) = stats.covb;
    stats.covb(:,exCol) = 0;
    stats.covb(exCol,:) = 0;
end
betas_logit_fit = betas_logit_fit(:);

clf
fh = gcf;
if length(PelletsDispensed)>1
    totalRows = length(PelletsDispensed)+1;
else
    totalRows = length(PelletsDispensed);
end
totalCols = nZones+1;
X = 0:0.1:1;

for zone = 1 : nZones
    if length(PelletsDispensed)>1
        clear PelletEntries PelletSkips PelletSSN Pelletn E S
        PelletEntries = Entry(zone,:,:);
        PelletSkips = Skip(zone,:,:);
        Pelletn = size(PelletEntries,3);
        p = totalCols*(totalRows-1)+zone;
        ah=subplot(totalRows,totalCols,p);
        set(ah,'fontsize',8)
        hold on
        th=title(sprintf('Overall Zone %d',zone));
        set(th,'fontangle','italic')
        E = nan(11,Pelletn);
        S = nan(11,Pelletn);
        for d = 1 : Pelletn
            Y0 = PelletEntries(:,:,d);
            Y1 = PelletSkips(:,:,d);
            E(:,d) = Y0(:);
            S(:,d) = Y1(:);
        end
%         mY = mean(L,2);
        
        [mY,lo,hi] = binocis(E,S,2,alpha);
        sY = [lo(:) hi(:)];
        plot(X,mY,'ko','linewidth',1,'markersize',10);
        for xi = 1 : length(X)
            plot([X(xi) X(xi)],[sY(xi,1) sY(xi,2)],'k-','linewidth',0.5)
        end
        xh=xlabel('Reward Probability');
        set(xh,'fontweight','bold')
        if mod(p,totalCols)==1
            yh=ylabel('Proportion of times chosen');
            set(yh,'fontweight','bold')
        end
        try
            x0 = fitX(logical(fitX(:,zone)),:);
            x0 = sortrows(x0,6);
            A = mean(PelletsDispensed);
            x0(:,5) = A;
            y_hat = glmval(betas_logit_fit,x0,'logit','constant','off');
            plot(x0(:,6),y_hat,'k-','linewidth',2)
            thresholdZone = -(betas_logit_fit(zone)+betas_logit_fit(5)*A)/betas_logit_fit(6);
            thresh = sprintf('\\theta_{Z=%d} = %.2f',zone,thresholdZone);
            text(0,0,thresh,'verticalalignment','bottom','fontweight','bold')
        end
        set(gca,'xtick',[0:0.1:1])
        set(gca,'xlim',[-0.05 1.05])
        set(gca,'ytick',[0:0.1:1])
        set(gca,'ylim',[-0.05 1.05])
        hold off
    end
    
    for pelletID = 1 : length(PelletsDispensed)
        pellets = PelletsDispensed(pelletID);
        p = totalCols*(pelletID-1)+zone;
        
        id = (PelletsPerDrop(zone,1,:))==pellets;
        
        
        if any(id(:))
            
            ah=subplot(totalRows,totalCols,p);
            set(ah,'fontsize',8)
            clear PelletEntries PelletSkips PelletSSN Pelletn L
            PelletEntries = Entry(zone,:,id);
            PelletSkips = Skip(zone,:,id);
            PelletSSN = session_list(id);
            Pelletn = size(PelletEntries,3);
            cmap = jet(Pelletn);
            hold on
            if p<=totalCols
                title(sprintf('Zone %.0f,\n%.0f pellets',zone,pellets))
            else
                title(sprintf('%.0f pellets',pellets))
            end
            clear ph legendStr
            E = nan(11,Pelletn);
            S = nan(11,Pelletn);
            ph = nan(1,Pelletn);
            for d = 1 : Pelletn
                if ~isempty(PelletEntries(:,:,d))&~isempty(PelletSkips(:,:,d));
                    Y0 = PelletEntries(:,:,d);
                    Y1 = PelletSkips(:,:,d);
                    E(:,d) = Y0(:);
                    S(:,d) = Y1(:);
                    ph(d)=plot(X,Y0(:)./(Y0(:)+Y1(:)),'x','color',cmap(d,:),'linewidth',2);
                    legendStr{d}=PelletSSN{d};
                end
            end
            idNaN = isnan(ph);
            ph(idNaN) = [];
            legendStr(idNaN) = [];
            [mY,lo,hi] = binocis(E,S,2,alpha);
            sY = [lo(:) hi(:)];
%             sY = nanstd(L,0,2)./sqrt(size(L,2));
            ph(length(ph)+1) = plot(X,mY,'ko','linewidth',1,'markersize',10);
            legendStr{length(legendStr)+1} = sprintf('Mean (\\pmSEM)');
            for xi = 1 : length(X)
                plot([X(xi) X(xi)],[sY(xi,1) sY(xi,2)],'k-','linewidth',0.5)
            end
            if p>(totalRows-1)*totalCols
                xh=xlabel('Reward Probability');
                set(xh,'fontweight','bold')
            end
            if mod(p,totalCols)==1
                yh=ylabel('Proportion of times chosen');
                set(yh,'fontweight','bold')
            end
            try
                x0 = fitX(fitX(:,zone)==1&fitX(:,5)==pellets,:);
                x0 = sortrows(x0,6);
                y_hat = glmval(betas_logit_fit,x0,'logit','constant','off');
                plot(x0(:,6),y_hat,'k-','linewidth',2)
                thresholdZonePellet = -(betas_logit_fit(zone)+betas_logit_fit(5)*pellets)/betas_logit_fit(6);
                thresh = sprintf('\\theta_{Z=%d,n=%d} = %.2f',zone,pellets,thresholdZonePellet);
                th=text(1,0,thresh,'verticalalignment','bottom','fontsize',8,'HorizontalAlignment','right');
                set(th,'fontangle','italic')
            end
            set(gca,'xtick',[0:0.1:1])
            set(gca,'xlim',[-0.05 1.05])
            set(gca,'ytick',[0:0.1:1])
            set(gca,'ylim',[-0.05 1.05])
            if (length(ph)<=4 || length(ph)>=2) && ~legendOff
                lh=legend(ph,legendStr);
                set(lh,'location','southeast')
                set(lh,'fontsize',8)
            end
            hold off
            
        end
    end
end

for pelletID = 1 : length(PelletsDispensed)
    pellets = PelletsDispensed(pelletID);
    id = squeeze(PelletsPerDrop(:,1,:))==pellets;
    
    p = totalCols*(pelletID-1)+nZones+1;
    
    ah=subplot(totalRows,totalCols,p);
    set(ah,'fontsize',8)
    hold on
    th=title(sprintf('Overall %d pellets',pellets));
    set(th,'fontangle','italic')
    E = nan(11,size(id,2));
    S = nan(11,size(id,2));
    for d = 1 : size(id,2)
        PelletEntries = Entry(id(:,d),:,d);
        PelletSkips = Skip(id(:,d),:,d);
        if ~isempty(PelletEntries)&~isempty(PelletSkips)
            Y0 = sum(PelletEntries,1);
            Y1 = sum(PelletSkips,1);
            E(:,d) = Y0(:);
            S(:,d) = Y1(:);
        end
    end
    idNaN = isnan(E)|isnan(S);
    E(idNaN,:) = [];
    S(idNaN,:) = [];
    [mY,lo,hi] = binocis(E,S,2,alpha);
    sY = [lo(:) hi(:)];
    plot(X,mY,'ko','linewidth',1,'markersize',10);
    for xi = 1 : length(X)
        plot([X(xi) X(xi)],[sY(xi,1) sY(xi,2)],'k-','linewidth',0.5)
    end
    if p>(totalRows-1)*totalCols
        xh=xlabel('Reward Probability');
        set(xh,'fontweight','bold')
    end
    if mod(p,totalCols)==1
        yh=ylabel('Proportion of times chosen');
        set(yh,'fontweight','bold')
    end
    try
        x0 = fitX(fitX(:,zone)==1&fitX(:,5)==pellets,:);
        x0 = sortrows(x0,6);
        Z = mean(x0(:,1:4),1);
        x0(:,1) = 0.25;
        x0(:,2) = 0.25;
        x0(:,3) = 0.25;
        x0(:,4) = 0.25;
        y_hat = glmval(betas_logit_fit,x0,'logit','constant','off');
        plot(x0(:,6),y_hat,'k-','linewidth',2)
        thresholdPellets = -([0.25 0.25 0.25 0.25]*betas_logit_fit(1:4)+betas_logit_fit(5)*pellets)/betas_logit_fit(6);
        thresh = sprintf('\\theta_{n=%d} = %.2f',pellets,thresholdPellets);
        text(0,0,thresh,'verticalalignment','bottom','fontweight','bold')
    end
    set(gca,'xtick',[0:0.1:1])
    set(gca,'xlim',[-0.05 1.05])
    set(gca,'ytick',[0:0.1:1])
    set(gca,'ylim',[-0.05 1.05])
    hold off
end

if totalRows>1
    ah=subplot(totalRows,totalCols,totalRows*totalCols);
    set(ah,'fontsize',8)
    clear PelletEntries PelletSkips PelletSSN Pelletn L
    hold on
    th=title(sprintf('Overall'));
    set(th,'fontweight','bold')
%     for d = 1 : size(Entry,3)
%         numerator = sum(sum(Entry,1),3);
%         denominator = sum(sum(Entry,1),3)+sum(sum(Skip,1),3);
%         Y = numerator ./ denominator;
%         L(:,d) = Y(:);
%         E(:,d) = sum(sum(Entry,1),3);
%         S(:,d) = sum(sum(Skip,1),3);
%     end
    E = sum(sum(Entry,1),3);
    S = sum(sum(Skip,1),3);
    [mY,lo,hi] = binocis(E(:),S(:),2,alpha);
    sY = [lo(:) hi(:)];
    plot(X,mY,'ko','linewidth',1,'markersize',10);
    for xi = 1 : length(X)
        plot([X(xi) X(xi)],[sY(xi,1) sY(xi,2)],'k-','linewidth',0.5)
    end
    xh=xlabel('Reward Probability');
    set(xh,'fontweight','bold')
    if mod(totalRows*totalCols,totalCols)==1
        yh=ylabel('Proportion of times chosen');
        set(yh,'fontweight','bold')
    end
    
    try
        x0 = fitX;
        x0 = sortrows(x0,6);
        x0(:,1) = 0.25;
        x0(:,2) = 0.25;
        x0(:,3) = 0.25;
        x0(:,4) = 0.25;
        x0(:,5) = mean(PelletsDispensed);
        y_hat = glmval(betas_logit_fit,x0,'logit','constant','off');
        plot(x0(:,6),y_hat,'k-','linewidth',2)
        thresholdOverall = -([0.25 0.25 0.25 0.25 mean(PelletsDispensed)]*betas_logit_fit(1:5))/betas_logit_fit(6);
        thresh = sprintf('\\Theta_{overall}=%.2f\nSlope = %.1f \\times P_{rew}',thresholdOverall,betas_logit_fit(6));
        text(0,0,thresh,'verticalalignment','bottom','fontweight','bold')
    end
    
    set(gca,'xtick',[0:0.1:1])
    set(gca,'xlim',[-0.05 1.05])
    set(gca,'ytick',[0:0.1:1])
    set(gca,'ylim',[-0.05 1.05])
    hold off
end

fit.HEADER.Col = {'b' 'CB low' 'CB high' 't' 'p'};
for zone = 1 : nZones
    fit.HEADER.Row{zone,1} = sprintf('Zone %d',zone);
end
lr = size(fit.HEADER.Row,1);
fit.HEADER.Row{lr+1} = 'nPellets';
fit.HEADER.Row{lr+2} = 'Probability';

fit.DATA(:,1) = betas_logit_fit;
fit.DATA(:,2) = betas_logit_fit+tinv(0.025,stats.dfe)*stats.se;
fit.DATA(:,3) = betas_logit_fit+tinv(0.975,stats.dfe)*stats.se;
fit.DATA(:,4) = stats.t;
fit.DATA(:,5) = stats.p;
fit.stats = stats;