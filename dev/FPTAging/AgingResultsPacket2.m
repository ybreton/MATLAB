%% ResultsPacket.m
% Builds a results packet of the FPT/Aging data.

%%
close all
childs=get(0,'children');
close(childs);

clear all
%% DEF Age groups
prefix = 'G:\DATA\FPT_Aging\ResultsPacket2\'; % where to store the figures
RatGroups = {'5 months' '9 months' '>27 months'}; % age group as string
RatAgeTable = import_ascii_text('RatsAges.csv','delim',','); % import rats,ages
[RatNames,idSort] = sort(RatAgeTable(:,1)); % list of rat names, sorted alphanumerically
RatAges = can2mat(RatAgeTable(idSort,2)); % list of corresponding rat ages
nLaps = 250; % maximum number of laps
maxRats = 10; % maximum number of rats per group
nSess = 16; % maximum number of sessions;

%% Pre-process all sessions.
% sdfn is nRats x nSess cell, with directory containing sd.mat.
% disp('Finding R*-DD.mat files...')
% fn = FindFiles('R*-DD.mat');
% fd=cell(length(fn),1);for f = 1 : length(fn);fd{f}=fileparts(fn{f});end;fd=unique(fd);
% sdfn=cell(length(RatNames),nSess);
% lastRat='';
% disp('Init...')
% fh=figure;
% for f = 1 : length(fd)
%     pushdir(fd{f});
%     d = fd{f};
%     delim = regexpi(d,'\');
%     SSN = d(max(delim)+1:end);
%     delim = regexpi(SSN,'-');
%     rat = SSN(1:min(delim)-1);
%     if ~strcmp(lastRat,rat)
%         col = 1;
%     else
%         col = col+1;
%     end
%     lastRat = rat;
%     row = find(strcmpi(RatNames,rat));
%     
%     disp(fd{f})
%     fpt=FindFiles('FPT-*.txt');
%     nvt=FindFiles('*.nvt');
%     zipfile=FindFiles('*.zip');
%     if isempty(nvt) && isempty(fpt) && isempty(zipfile)
%         disp(['Excluding ' SSN ': no tracking data.'])
%     else
%         FPTInit;
%         
%         sdfile = FindFile('*-sd.mat','CheckSubdirs',0);
%         load(sdfile)
%         
%         sd = FPTdownsamplePos(sd);
%         sd = zIdPhi(sd,'tstart',sd.EnteringCPTime_fix,'tend',sd.ExitingCPTime_fix);
%         save(sdfile,'sd');
% %         if any(sd.ZoneIn==sd.DelayZone)
%             sdfn{row,col} = sdfile;
% %         else
% %             disp(['Excluding ' SSN ': no delayed choices.'])
% %         end
%         set(0,'currentfigure',fh);
%         clf
%         hold on
%         FPTplotPaths(sd,'tstart',sd.EnteringCPTime_fix,'tend',sd.ExitingCPTime_fix);
%         hold off
%         drawnow
%     end
%     
%     
%     popdir;
% end
% close(fh);
load('VTETable.mat');

%% Pellet ratios, delays, efficiency

disp('Extracting pellet ratios, delays, inefficiency, ...')

delays=FPTVTETableExtract(VTETable,1,4,7,'Delay');
finalDelays=FPTVTETableExtract(VTETable,1,4,7,'Compensatory Delay');
TitrationAlternation=FPTVTETableExtract(VTETable,1,4,7,'Titration/Alternation');
pelletRatios=FPTVTETableExtract(VTETable,1,4,7,'PelletRatio');
LogIdPhi=FPTVTETableExtract(VTETable,1,4,7,'LogIdPhi');
choseLL=FPTVTETableExtract(VTETable,1,4,7,'Choice');
lapsRun=FPTVTETableExtract(VTETable,1,4,7,'Lap');

%%
VTETableGetStartDelays;
%%
sdfd = FPTVTETableExtract(VTETable,1,4,7,5,'numeric',[true false true false]);
sdfn = FPTVTETableExtract(VTETable,1,4,7,4,'numeric',[true false true false]);
sdfd = squeeze(sdfd(:,:,1));
sdfn = squeeze(sdfn(:,:,1));
%%
for iR = 1 : size(sdfn,1)
    for iC = 1 : size(sdfn,2)
        if ~isempty(sdfn{iR,iC})
            sdfn{iR,iC} = [sdfd{iR,iC} '\' sdfn{iR,iC} '-sd.mat'];
        end
    end
end

%% Differences in running parameters
% number of pellets
nP = pelletRatios(:,:,1);
ages = repmat(RatAges,1,size(nP,2));
[p,table,stats] = kruskalwallis(nP(:),ages(:));

SD = startDelays(:,:,1);
[p,table,stats] = kruskalwallis(SD(:),ages(:));

direction = sign(finalDelays(:,:,1)-startDelays(:,:,1));
[p,table,stats] = kruskalwallis(direction(:),ages(:));

%% Rate of reinforcement
[rate,pellets,IRI] = FPTGetReinfRate(sdfn,'nLaps',nLaps);
SessRRf = nansum(pellets,3)./nansum(IRI,3);
SessRRf(isinf(SessRRf)) = nan;
ratRRf = nanmean(SessRRf,2); 

[p,table,stats]=anova1(ratRRf,RatAges);
multcompare(stats,'ctype','bonferroni')

%%
lapMean = nanmean(rate,2);
figure;
cmap = [0 1 1;
        0 0 1;
        1 0 0];
    
for iAge = 1 :3
    idAge = RatAges==iAge;
    ratLap = squeeze(lapMean(idAge,:,:));
    ratLapMean = nanmean(ratLap,1);
    ratLapSEM = nanstderr(ratLap);
    hold on
    plot(ratLapMean,'o-','markerfacecolor',cmap(iAge,:),'color',cmap(iAge,:));
    eh=errorbar(1:length(ratLapMean),ratLapMean,ratLapSEM);
    set(eh,'linestyle','none')
    set(eh,'color',cmap(iAge,:))
end

%% FIGURE: P[alternation lap] vs age

m = nan(3,1);
s = nan(3,1);
y = nan(3,maxRats);
for iAge=1:3;
    idAge = iAge==RatAges;
    ageTA = TitrationAlternation(idAge,:);
    ageTA = ageTA==0; % titration=1, alternation=0.
    sessionP = nanmean(ageTA,3);
    ratMean = nanmean(sessionP,2);
    y(iAge,1:length(ratMean)) = reshape(ratMean,1,numel(ratMean));
    m(iAge)=nanmean(ratMean);
    s(iAge)=nanstderr(ratMean);
end

fh=figure;
hold on
bh=bar(1:3,m,0.8);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
eh=errorbar(1:3,m,s);
set(eh,'linestyle','none')
set(eh,'linewidth',2)
for iAge=1:3
    plot(ones(1,maxRats)*iAge,y(iAge,:),'ko','markerfacecolor','k');
end
xlabel('Age groups')
set(gca,'xtick',1:3)
set(gca,'xticklabel',RatGroups)
ylabel(sprintf('P[Alternation lap]\n(mean across rats\\pm SEM)'))
hold off

saveas(fh,[prefix 'Palt_vs_Age.fig'],'fig')
saveas(fh,[prefix 'Palt_vs_Age.eps'],'epsc')
close(fh);

%% FIGURE: Overall inefficiency vs Age
% m = nan(3,1);
% s = nan(3,1);
% y = nan(3,maxRats);
% for iAge=1:3
%     idAge = iAge==RatAges;
%     AgeIE = OIE(idAge,:);
%     ratIE = nanmean(AgeIE,2);
%     y(iAge,1:length(ratIE)) = reshape(ratIE,1,numel(ratIE));
%     m(iAge) = nanmean(ratIE);
%     s(iAge) = nanstderr(ratIE);
% end
% 
% fh=figure;
% hold on
% set(gca,'fontname','Arial')
% set(gca,'fontsize',18)
% bh=bar([1:3],m,0.8);
% set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
% eh=errorbar([1:3],m,s);
% set(eh,'linestyle','none')
% set(eh,'color','k')
% set(eh,'linewidth',2)
% for iAge=1:3
%     plot(ones(1,maxRats)*iAge,y(iAge,:),'ko','markerfacecolor','k')
% end
% xlabel('Age groups')
% set(gca,'ylim',[3.5 6.5])
% set(gca,'xtick',[1:3])
% set(gca,'xticklabel',RatGroups)
% ylabel(sprintf('Overall inefficiency\n(mean across rats \\pm SEM)'))
% hold off
% saveas(fh,[prefix 'OverallInefficiency_vs_Age.fig'],'fig')
% saveas(fh,[prefix 'OverallInefficiency_vs_Age.eps'],'epsc')
% close(fh);
% AGE = repmat([1;2;3],1,size(y,2));
% [p,table,stats]=anova1(y(:),AGE(:)); multcompare(stats,'ctype','hsd');

%% AD vs PR & Age Kruskal-Wallis
% Y0 is rat's median final delay for given pellet ratio
Y0 = nan(3,4,maxRats);
% X1 is age groups
X1 = repmat([1;2;3],[1,4,maxRats]);
% X2 is pellet ratios
X2 = repmat([1 2 3 4],[3,1,maxRats]);
for iAge = 1 : 3
    idAge = RatAges==iAge;
    ageFDs = finalDelays(idAge,:);
    agePRs = pelletRatios(idAge,:);
    for iPR = 1 : 4
        idPRs = agePRs==iPR;
        ratFDs = nan(size(ageFDs));
        ratFDs(idPRs) = ageFDs(idPRs);
        ratMedian = nanmedian(ratFDs,2);
        Y0(iAge,iPR,1:length(ratMedian)) = reshape(ratMedian,1,1,numel(ratMedian));
    end
end
X = [X1(:) X2(:)];
Y = Y0(:);

% Simple effect of PR at Age
for iAge=1:3
    [AD_vs_PR_at_Age_SE(iAge).p, AD_vs_PR_at_Age_SE(iAge).tbl,AD_vs_PR_at_Age_SE(iAge).stats,AD_vs_PR_at_Age_SE(iAge).multcomp] = orthogonalContrasts(Y(X(:,1)==iAge),X(X(:,1)==iAge,2),@kruskalwallis);
%     [AD_vs_PR_at_Age_SE(iAge,iPR).p,AD_vs_PR_at_Age_SE(iAge,iPR).tbl,AD_vs_PR_at_Age_SE(iAge,iPR).stats]=kruskalwallis(Y(X(:,1)==iAge),[X(X(:,1)==iAge,2)>iPR]);
%     AD_vs_PR_at_Age_SE(iAge).chisq = can2mat(AD_vs_PR_at_Age_SE(iAge).tbl(2:end,5));
%     AD_vs_PR_at_Age_SE(iAge).etasq = AD_vs_PR_at_Age_SE(iAge).chisq./(length(Y(X(:,1)==iAge))-1);
%     multcompare(AD_vs_PR_at_Age_SE(iAge).stats,'ctype','hsd','alpha',0.05);
end
% Simple effect of Age at PR
for iPR=1:4
    [AD_vs_Age_at_PR_SE(iAge).p,AD_vs_Age_at_PR_SE(iAge).tbl,AD_vs_Age_at_PR_SE(iAge).stats]=kruskalwallis(Y(X(:,2)==iPR),X(X(:,2)==iPR,1));
    AD_vs_Age_at_PR_SE(iAge).chisq = can2mat(AD_vs_Age_at_PR_SE(iAge).tbl(2:end,5));
    AD_vs_Age_at_PR_SE(iAge).etasq = AD_vs_Age_at_PR_SE(iAge).chisq./(length(Y(X(:,2)==iPR))-1);
    multcompare(AD_vs_Age_at_PR_SE(iAge).stats,'ctype','hsd','alpha',0.05);
end
% Main effect of Age
[AD_vs_Age.p,AD_vs_Age.tbl,AD_vs_Age.stats]=kruskalwallis(Y,X(:,1));
multcompare(AD_vs_Age.stats,'ctype','hsd','alpha',0.05);
% Main effect of PR
[AD_vs_PR.p,AD_vs_PR.tbl,AD_vs_PR.stats]=kruskalwallis(Y,X(:,2));
multcompare(AD_vs_PR.stats,'ctype','hsd','alpha',0.05);

%% Figure: final delay vs PR at each age

% PR = can2mat(MasterSSNTable.DATA(:,3));
% Age = can2mat(MasterSSNTable.DATA(:,2));
% Y = can2mat(MasterSSNTable.DATA(:,6));
M = nan(4,3);
Q1 = nan(4,3);
Q3 = nan(4,3);
Lo = nan(4,3);
Hi = nan(4,3);
for iAge=1:3
    for iPR=1:4
        id1 = X1==iAge;
        id2 = X2==iPR;
        M(iPR,iAge) = nanmedian(Y0(id1(:,1,1),id2(1,:,1),:),3);
        Q1(iPR,iAge) = prctile(Y0(id1(:,1,1),id2(1,:,1),:),25,3);
        Q3(iPR,iAge) = prctile(Y0(id1(:,1,1),id2(1,:,1),:),75,3);
    end
end
figure
hold on
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
E1 = M-Q1;
E3 = Q3-M;

d = linspace(-0.4,0.4,5); d=d(2:end-1);
w = 0.8*mean(diff(d));
x = repmat((1:4)',1,3)+repmat(d,4,1);
cmap = [0 1 1;
        0 0 1;
        1 0 0];
ph = nan(3,1);
for iAge = 1 : 3
    for iPR = 1 : 4
        xc = x(iPR,iAge);
        x0 = [xc-w/2 xc+w/2];
        y0 = [M(iPR,iAge) M(iPR,iAge)];
        
        
        ph(iAge)=plot(x0,y0,'-','linewidth',2,'color',cmap(iAge,:));
%         plot([xc xc],[Lo(iPR,iAge) Hi(iPR,iAge)],'-','linewidth',2,'color',cmap(iAge,:))
%         ph(iAge)=plot([xc xc],[Q1(iPR,iAge) Q3(iPR,iAge)],'-','linewidth',3,'color',cmap(iAge,:));
        eh=errorbar(xc,M(iPR,iAge),E1(iPR,iAge),E3(iPR,iAge));
        set(eh,'linestyle','none')
        set(eh,'color',cmap(iAge,:))
        set(eh,'linewidth',1);
    end
end
set(gca,'xtick',[1:4])
set(gca,'xticklabel',[1:4])

xlabel('Pellets on LL side')
ylabel(sprintf('Compensatory delay\n(s, median \\pm interquartile range)'));
set(gca,'ylim',[0 30])
set(gca,'xtick',[1:4])
legend(ph,RatGroups)
hold off
saveas(gcf,[prefix 'AD_vs_Age_PR_nonparametric.fig'],'fig')
saveas(gcf,[prefix 'AD_vs_Age_PR_nonparametric.eps'],'epsc')
close all

%% 
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
AD_vs_PR_saturation_Figure;
popdir;
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end


%% Autocorrelation of choice
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
autocorrelation_choice_by_lap_Figure
popdir;

%%
% FPTgaussfit;
%%
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
VTE_Age_Figure
popdir;

%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% FIGURE: P[VTE] vs. Binned lap
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
pVTE_binnedLap_Figure;
popdir;

%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% FIGURE: LogIdPhi at Alternation and Titration by Age and by Lap
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% LogIdPhiduringAltTit_Age_Figure2;
% LogIdPhiatAltTit_EarlyLate_Age_Figure;
pVTE_vs_Age_TitrationAlternation_EarlyLate;
popdir;

%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% Convert (just in case)
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
convert_fig2eps;
convert_fig2jpg;
popdir;
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end
