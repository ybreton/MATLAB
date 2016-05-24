%% ResultsPacket.m
% Builds a results packet of the FPT/Aging data.

%% DEF Age groups
prefix = 'G:\DATA\FPT_Aging\ResultsPacket2\';
RatGroups = {'5 months' '9 months' '>27 months'};
RatAgeList = {'R248' 1
    'R249' 2
    'R250' 2
    'R251' 2
    'R256' 3
    'R257' 3
    'R258' 1
    'R259' 2
    'R260' 3
    'R261' 3
    'R262' 1
    'R263' 3
    'R264' 2
    'R265' 3
    'R272' 2
    'R273' 2
    'R274' 3
    'R275' 3
    'R282' 1
    'R283' 1
    'R284' 1
    'R285' 2
    'R286' 3
    'R287' 3};
%% Pre-process all sessions.
fn = FindFiles('R*-DD.mat');
fd=cell(length(fn),1);for f = 1 : length(fn);fd{f}=fileparts(fn{f});end;fd=unique(fd);
for f = 1 : length(fd)
    pushdir(fd{f});
    disp(fd{f})
    fpt=FindFiles('FPT-*.txt');
    nvt=FindFiles('*.nvt');
    zipfile=FindFiles('*.zip');
    if isempty(nvt) & isempty(fpt) & isempty(zipfile)
        disp('no tracking data.')
    else
        FPTInit;
    end
    popdir;
end

%% DEF efficiency and duration table.
MasterEfficiencyTable = getEfficiencyTab_FPTAging(RatAgeList,prefix);
save('MasterEfficiencyTable.mat','MasterEfficiencyTable');
close all;
%% FIGURE: P(Adjustment|Investigation) for each group
AGE = can2mat(MasterEfficiencyTable.DATA(:,2));
PR = can2mat(MasterEfficiencyTable.DATA(:,3));
INVadj = can2mat(MasterEfficiencyTable.DATA(:,15));
INValt = can2mat(MasterEfficiencyTable.DATA(:,13));
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
m = nan(3,1);
lo = nan(3,1);
hi = nan(3,1);
for iAge=1:3;
    [m(iAge),lo(iAge),hi(iAge)]=binocis(INVadj(AGE==iAge),INValt(AGE==iAge),1,0.05/3);
end
elo = m-lo;
ehi = hi-m;
hold on
bh=bar(1:3,m,0.8);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
eh=errorbar(1:3,m,elo,ehi);
set(eh,'linestyle','none')
set(eh,'color','k')
xlabel('Age groups')
ylabel(sprintf('P[Adjustment Lap] during investigation\n(\\pm corrected 95%% CI)'))
set(gca,'xtick',1:3)
set(gca,'xticklabel',RatGroups)
set(gca,'ylim',[0 0.4])
hold off
saveas(gcf,[prefix 'pAdjustment_InvestigationPhase.fig'],'fig')
saveas(gcf,[prefix 'pAdjustment_InvestigationPhase.eps'],'epsc')
%% FIGURE: P(Alternation|Titration) for each group
AGE = can2mat(MasterEfficiencyTable.DATA(:,2));
PR = can2mat(MasterEfficiencyTable.DATA(:,3));
TITadj = can2mat(MasterEfficiencyTable.DATA(:,16));
TITalt = can2mat(MasterEfficiencyTable.DATA(:,14));
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
m = nan(3,1);
lo = nan(3,1);
hi = nan(3,1);
for iAge=1:3;
    [m(iAge),lo(iAge),hi(iAge)]=binocis(TITalt(AGE==iAge),TITadj(AGE==iAge),1,0.05/3);
end
elo = m-lo;
ehi = hi-m;
hold on
bh=bar(1:3,m,0.8);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
eh=errorbar(1:3,m,elo,ehi);
set(eh,'linestyle','none')
set(eh,'color','k')
xlabel('Age groups')
ylabel(sprintf('P[Alternation Lap] during titration\n(\\pm corrected 95%% CI)'))
set(gca,'xtick',1:3)
set(gca,'xticklabel',RatGroups)
set(gca,'ylim',[0 0.75])
hold off
saveas(gcf,[prefix 'pAlternation_TitrationPhase.fig'],'fig')
saveas(gcf,[prefix 'pAlternation_TitrationPhase.eps'],'epsc')
%% FIGURE: P[Adjustment|Exploitation] vs Age
AGE = can2mat(MasterEfficiencyTable.DATA(:,2));
PR = can2mat(MasterEfficiencyTable.DATA(:,3));
EXPadj = can2mat(MasterEfficiencyTable.DATA(:,18));
EXPalt = can2mat(MasterEfficiencyTable.DATA(:,17));
figure;
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
m = nan(3,1);
lo = nan(3,1);
hi = nan(3,1);
for iAge=1:3;
    [m(iAge),lo(iAge),hi(iAge)]=binocis(EXPadj(AGE==iAge),EXPalt(AGE==iAge),1,0.05/3);
end
elo = m-lo;
ehi = hi-m;
hold on
bh=bar(1:3,m,0.8);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
eh=errorbar(1:3,m,elo,ehi);
set(eh,'linestyle','none')
set(eh,'color','k')
xlabel('Age groups')
ylabel(sprintf('P[Adjustment Lap] during exploitation\n(\\pm corrected 95%% CI)'))
set(gca,'xtick',1:3)
set(gca,'xticklabel',RatGroups)
hold off
saveas(gcf,[prefix 'pAdjustment_ExploitationPhase.fig'],'fig')
saveas(gcf,[prefix 'pAdjustment_ExploitationPhase.eps'],'epsc')
%% FIGURE: Alternation laps vs age

m = nan(3,1);
s = nan(3,1);
for iAge=1:3;
    m(iAge)=nanmean(EXPalt(AGE==iAge)+TITalt(AGE==iAge)+INValt(AGE==iAge));
    s(iAge)=nanstderr(EXPalt(AGE==iAge)+TITalt(AGE==iAge)+INValt(AGE==iAge));
end

fh=figure;
hold on
bh=bar(1:3,m,0.8);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
eh=errorbar(1:3,m,s);
set(eh,'linestyle','none')
set(eh,'linewidth',2)
xlabel('Age groups')
set(gca,'xtick',1:3)
set(gca,'xticklabel',RatGroups)
ylabel(sprintf('Number of alternation laps\n(\\pm SEM)'))
hold off

%% FIGURE: Adjustment laps vs Age

m = nan(3,1);
s = nan(3,1);
for iAge=1:3;
    m(iAge)=nanmean(EXPadj(AGE==iAge)+TITadj(AGE==iAge)+INVadj(AGE==iAge));
    s(iAge)=nanstderr(EXPadj(AGE==iAge)+TITadj(AGE==iAge)+INVadj(AGE==iAge));
end

fh=figure;
hold on
bh=bar(1:3,m,0.8);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
eh=errorbar(1:3,m,s);
set(eh,'linestyle','none')
set(eh,'linewidth',2)
xlabel('Age groups')
set(gca,'xtick',1:3)
set(gca,'xticklabel',RatGroups)
ylabel(sprintf('Number of adjustment laps\n(\\pm SEM)'))
hold off


%% FIGURE: Investigation inefficiency vs Age
AGE = can2mat(MasterEfficiencyTable.DATA(:,2));
IIE = can2mat(MasterEfficiencyTable.DATA(:,7));
for iAge=1:3
    m(iAge) = nanmean(IIE(AGE==iAge));
    s(iAge) = nanstderr(IIE(AGE==iAge));
end
fh=figure;
hold on
set(gca,'fontname','Arial')
set(gca,'fontsize',18)
bh=bar([1:3],m,0.8);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
eh=errorbar([1:3],m,s);
set(eh,'linestyle','none')
set(eh,'color','k')
set(eh,'linewidth',2)
xlabel('Age groups')
set(gca,'xtick',[1:3])
set(gca,'xticklabel',RatGroups)
ylabel(sprintf('Investigation inefficiency\n(mean \\pm SEM)'))
hold off
saveas(fh,[prefix 'InvestigationInefficiency_vs_Age.fig'],'fig')
saveas(fh,[prefix 'InvestigationInefficiency_vs_Age.eps'],'epsc')
close(fh);
[p,table,stats]=anova1(IIE,AGE); multcompare(stats,'ctype','hsd')
%%
for iAge=1:3; 
    idAge = can2mat(MasterEfficiencyTable.DATA(:,2))==iAge; 
    [m(iAge),lo(iAge),hi(iAge)]=binocis(can2mat(MasterEfficiencyTable.DATA(idAge,15)),can2mat(MasterEfficiencyTable.DATA(idAge,13)),1,0.05/3);
end
clf
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
hold on; 
bh=bar(1:3,m); 
childs = get(bh,'children');
set(childs,'facecolor',[0.8 0.8 0.8])
eh=errorbar(1:3,m,m-lo,hi-m); 
set(eh,'linestyle','none'); 
set(eh,'color','k');
set(gca,'ylim',[0.15 0.55])
set(gca,'ytick',[0.15:0.05:0.55])
set(gca,'xtick',[1:3]);
set(gca,'xticklabel',{'5 months' '9 months' '>27 months'});
xlabel('Age group')
ylabel(sprintf('P[Adjustment] during investigation\n(\\pm 95%% Bonferroni-corrected CI)'))

saveas(gcf,[prefix 'Investigation_PAdjustment.fig'],'fig')
saveas(gcf,[prefix 'Investigation_PAdjustment.eps'],'epsc')
%%
AGE = can2mat(MasterEfficiencyTable.DATA(:,2));
TIE = can2mat(MasterEfficiencyTable.DATA(:,11));
for iAge=1:3
    m(iAge) = nanmean(TIE(AGE==iAge));
    s(iAge) = nanstderr(TIE(AGE==iAge));
end
fh=figure;
hold on
set(gca,'fontname','Arial')
set(gca,'fontsize',18)
bh=bar([1:3],m,0.8);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
eh=errorbar([1:3],m,s);
set(eh,'linestyle','none')
set(eh,'color','k')
set(eh,'linewidth',2)
xlabel('Age groups')
set(gca,'xtick',[1:3])
set(gca,'xticklabel',RatGroups)
ylabel(sprintf('Titration inefficiency\n(mean \\pm SEM)'))
hold off
saveas(fh,[prefix 'TitrationInefficiency_vs_Age.fig'],'fig')
saveas(fh,[prefix 'TitrationInefficiency_vs_Age.eps'],'epsc')
close(fh);
[p,table,stats]=anova1(TIE,AGE); multcompare(stats,'ctype','hsd');
%%

for iAge=1:3; 
    idAge = can2mat(MasterEfficiencyTable.DATA(:,2))==iAge; 
    [m(iAge),lo(iAge),hi(iAge)]=binocis(can2mat(MasterEfficiencyTable.DATA(idAge,16)),can2mat(MasterEfficiencyTable.DATA(idAge,14)),1,0.05/3);
end
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
hold on; 
bh=bar(1:3,m); 
childs = get(bh,'children');
set(childs,'facecolor',[0.8 0.8 0.8])
eh=errorbar(1:3,m,m-lo,hi-m); 
set(eh,'linestyle','none'); 
set(eh,'color','k');
set(gca,'ylim',[0.15 0.55])
set(gca,'ytick',[0.15:0.05:0.55])
set(gca,'xtick',[1:3]);
set(gca,'xticklabel',{'5 months' '9 months' '>27 months'});
xlabel('Age group')
ylabel(sprintf('P[Adjustment] during titration\n(\\pm 95%% Bonferroni-corrected CI)'))

saveas(gcf,[prefix 'Titration_PAdjustment.fig'],'fig')
saveas(gcf,[prefix 'Titration_PAdjustment.eps'],'epsc')
%%
AGE = can2mat(MasterEfficiencyTable.DATA(:,2));
EIE = can2mat(MasterEfficiencyTable.DATA(:,8));
for iAge=1:3
    m(iAge) = nanmean(EIE(AGE==iAge));
    s(iAge) = nanstderr(EIE(AGE==iAge));
end
fh=figure;
hold on
set(gca,'fontname','Arial')
set(gca,'fontsize',18)
bh=bar([1:3],m,0.8);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
eh=errorbar([1:3],m,s);
set(eh,'linestyle','none')
set(eh,'color','k')
set(eh,'linewidth',2)
xlabel('Age groups')
set(gca,'xtick',[1:3])
set(gca,'xticklabel',RatGroups)
ylabel(sprintf('Exploration inefficiency\n(mean \\pm SEM)'))
hold off
saveas(fh,[prefix 'ExploitationInefficiency_vs_Age.fig'],'fig')
saveas(fh,[prefix 'ExploitationInefficiency_vs_Age.eps'],'epsc')
close(fh);
[p,table,stats]=anova1(EIE,AGE); multcompare(stats,'ctype','hsd');

%%

for iAge=1:3; 
    idAge = can2mat(MasterEfficiencyTable.DATA(:,2))==iAge; 
    [m(iAge),lo(iAge),hi(iAge)]=binocis(can2mat(MasterEfficiencyTable.DATA(idAge,18)),can2mat(MasterEfficiencyTable.DATA(idAge,17)),1,0.05/3);
end
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
hold on; 
bh=bar(1:3,m); 
childs = get(bh,'children');
set(childs,'facecolor',[0.8 0.8 0.8])
eh=errorbar(1:3,m,m-lo,hi-m); 
set(eh,'linestyle','none'); 
set(eh,'color','k');
set(gca,'ylim',[0.15 0.55])
set(gca,'ytick',[0.15:0.05:0.55])
set(gca,'xtick',[1:3]);
set(gca,'xticklabel',{'5 months' '9 months' '>27 months'});
xlabel('Age group')
ylabel(sprintf('P[Adjustment] during exploitation\n(\\pm 95%% Bonferroni-corrected CI)'))

saveas(gcf,[prefix 'Exploitation_PAdjustment.fig'],'fig')
saveas(gcf,[prefix 'Exploitation_PAdjustment.eps'],'epsc')
%%
AGE = can2mat(MasterEfficiencyTable.DATA(:,2));
IE = can2mat(MasterEfficiencyTable.DATA(:,10));
for iAge=1:3
    m(iAge) = nanmean(IE(AGE==iAge));
    s(iAge) = nanstderr(IE(AGE==iAge));
end
fh=figure;
hold on
set(gca,'fontname','Arial')
set(gca,'fontsize',18)
bh=bar([1:3],m,0.8);
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
eh=errorbar([1:3],m,s);
set(eh,'linestyle','none')
set(eh,'color','k')
set(eh,'linewidth',2)
xlabel('Age groups')
set(gca,'ylim',[3.5 6.5])
set(gca,'xtick',[1:3])
set(gca,'xticklabel',RatGroups)
ylabel(sprintf('Overall inefficiency\n(mean \\pm SEM)'))
hold off
saveas(fh,[prefix 'OverallInefficiency_vs_Age.fig'],'fig')
saveas(fh,[prefix 'OverallInefficiency_vs_Age.eps'],'epsc')
close(fh);
[p,table,stats]=anova1(IE,AGE); multcompare(stats,'ctype','hsd');
%%
% for iAge=1:3; 
%     idAge = can2mat(MasterEfficiencyTable.DATA(:,2))==iAge;
%     Adj = can2mat(MasterEfficiencyTable.DATA(idAge,18))+can2mat(MasterEfficiencyTable.DATA(idAge,16))+can2mat(MasterEfficiencyTable.DATA(idAge,15));
%     Alt = can2mat(MasterEfficiencyTable.DATA(idAge,13))+can2mat(MasterEfficiencyTable.DATA(idAge,14))+can2mat(MasterEfficiencyTable.DATA(idAge,17));
%     pAdj = Adj./(Adj+Alt);
%     m(iAge) = nanmean(pAdj);
%     s(iAge) = nanstderr(pAdj);
%     n(iAge) = sum(~isnan(pAdj));
% %     [m(iAge),lo(iAge),hi(iAge)]=binocis(Adj,Alt,1,0.05/3);
% end
% lo = m-s;
% hi = m+s;
% clf
% set(gca,'fontsize',18)
% set(gca,'fontname','Arial')
% hold on; 
% bh=bar(1:3,m); 
% childs = get(bh,'children');
% set(childs,'facecolor',[0.8 0.8 0.8])
% eh=errorbar(1:3,m,m-lo,hi-m); 
% set(eh,'linestyle','none'); 
% set(eh,'color','k');
% set(gca,'ylim',[0.15 0.55])
% set(gca,'ytick',[0.15:0.05:0.55])
% set(gca,'xtick',[1:3]);
% set(gca,'xticklabel',{'5 months' '9 months' '>27 months'});
% xlabel('Age group')
% ylabel(sprintf('P[Adjustment] throughout session\n(mean \\pm SEM)'))
% 
% saveas(gcf,[prefix 'Overall_PAdjustment.fig'],'fig')
% saveas(gcf,[prefix 'Overall_PAdjustment.eps'],'epsc')
%%
AGE = can2mat(MasterEfficiencyTable.DATA(:,2));
Adj = can2mat(MasterEfficiencyTable.DATA(:,18))+can2mat(MasterEfficiencyTable.DATA(:,16))+can2mat(MasterEfficiencyTable.DATA(:,15));
Alt = can2mat(MasterEfficiencyTable.DATA(:,13))+can2mat(MasterEfficiencyTable.DATA(:,14))+can2mat(MasterEfficiencyTable.DATA(:,17));

[m(1),lo(1),hi(1)] = binocis(Adj(AGE==1),Alt(AGE==1),1,0.05/3);
[m(2),lo(2),hi(2)] = binocis(Adj(AGE==2),Alt(AGE==2),1,0.05/3);
[m(3),lo(3),hi(3)] = binocis(Adj(AGE==3),Alt(AGE==3),1,0.05/3);

clf
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
hold on
bh=bar(1:3,m);
childs=get(bh,'children');
set(childs,'facecolor',[0.8 0.8 0.8])
eh=errorbar(1:3,m,m-lo,hi-m);
set(eh,'linestyle','none')
set(eh,'color','k')
set(gca,'ylim',[0.25 0.5])
set(gca,'ytick',[0.25:0.05:0.5])
set(gca,'xtick',[1:3])
set(gca,'xticklabel',RatGroups)
xlabel('Age group')
ylabel(sprintf('P[Adjustment] throughout session\n(mean \\pm 95%% CI)'));

hold off
saveas(gcf,[prefix 'Overall_PAdjustment.fig'],'fig')
saveas(gcf,[prefix 'Overall_PAdjustment.eps'],'epsc')
%% Is efficiency in titration related to duration of investigation phase?
% Logic:
% Aged rats are much more inefficient at investigating the options, but
% adolescent and adult rats are equally inefficient.
% Maybe the adolescent rats aren't using the investigation phase to titrate
% more efficiently.
% The longer you investigate, the less you should be spending on
% exploration during the titration phase, making that more efficient. So is
% there a difference in how well increased investigation reduces
% inefficiency in the subsequent titration phase across age groups?

AGE = can2mat(MasterEfficiencyTable.DATA(:,2));
INV = can2mat(MasterEfficiencyTable.DATA(:,6));
TIE = can2mat(MasterEfficiencyTable.DATA(:,11));
idExc = INV>50;
AGE(idExc) = [];
INV(idExc) = [];
TIE(idExc) = [];
fh = figure;
set(gca,'fontsize',18);
set(gca,'fontname','Arial');
hold on
ph= plot(INV(AGE==1),TIE(AGE==1),'k.');
idnan = isnan(INV)|isnan(TIE);
X = INV(AGE==1&~idnan);
Y = TIE(AGE==1&~idnan);
[r,p] = corrcoef(X,Y);
b = [ones(length(X),1) X]\Y;
ph(2)=plot(X,[ones(length(X),1) X]*b,'k-');
legendStr = {'Data' sprintf('Fit, r=%.3f, p=%.3f',r(2),p(2))};
legend(ph,legendStr)
xlabel('Investigation laps')
ylabel('Titration inefficiency')
title(sprintf('5 months'));
set(gca,'xlim',[0 30])
set(gca,'ylim',[0 20])
hold off
saveas(fh,[prefix 'Ado_TIE_vs_InvestigationLaps.fig'],'fig')
saveas(fh,[prefix 'Ado_TIE_vs_InvestigationLaps.eps'],'epsc')

fh = figure;
set(gca,'fontsize',18);
set(gca,'fontname','Arial');
hold on
ph=plot(INV(AGE==2),TIE(AGE==2),'k.');
X = INV(AGE==2&~idnan);
Y = TIE(AGE==2&~idnan);
[r,p] = corrcoef(X,Y);
b = [ones(length(X),1) X]\Y;
ph(2)=plot(X,[ones(length(X),1) X]*b,'k-');
legendStr = {'Data' sprintf('Fit, r=%.3f, p=%.3f',r(2),p(2))};
legend(ph,legendStr)
xlabel('Investigation laps')
ylabel('Titration inefficiency')
title(sprintf('9 months'));
set(gca,'xlim',[0 30])
set(gca,'ylim',[0 20])
hold off
saveas(fh,[prefix 'Adult_TIE_vs_InvestigationLaps.fig'],'fig')
saveas(fh,[prefix 'Adult_TIE_vs_InvestigationLaps.eps'],'epsc')


fh = figure;
set(gca,'fontsize',18);
set(gca,'fontname','Arial');
hold on
ph=plot(INV(AGE==3),TIE(AGE==3),'k.');
X = INV(AGE==3&~idnan);
Y = TIE(AGE==3&~idnan);
[r,p] = corrcoef(X,Y);
b = [ones(length(X),1) X]\Y;
ph(2)=plot(X,[ones(length(X),1) X]*b,'k-');
legendStr = {'Data' sprintf('Fit, r=%.3f, p=%.3f',r(2),p(2))};
legend(ph,legendStr)
xlabel('Investigation laps')
ylabel('Titration inefficiency')
title(sprintf('>27 months'));
set(gca,'xlim',[0 30])
set(gca,'ylim',[0 20])
hold off
saveas(fh,[prefix 'Aged_TIE_vs_InvestigationLaps.fig'],'fig')
saveas(fh,[prefix 'Aged_TIE_vs_InvestigationLaps.eps'],'epsc')

fh = figure;
hold on
legendStr = cell(6,1);
ph = nan(6,1);
ph(1)=plot(INV(AGE==1),TIE(AGE==1),'r.');
legendStr{1} = '5 months';
X = INV(AGE==1&~idnan);
Y = TIE(AGE==1&~idnan);
[r,p] = corrcoef(X,Y);
b = [ones(length(X),1) X]\Y;
ph(2)=plot(INV,[ones(length(INV),1) INV]*b,'r-');
legendStr{2} = sprintf('Fit');
ph(3)=plot(INV(AGE==2),TIE(AGE==2),'b.');
legendStr{3} = {'9 months'};
X = INV(AGE==2&~idnan);
Y = TIE(AGE==2&~idnan);
[r,p] = corrcoef(X,Y);
b = [ones(length(X),1) X]\Y;
ph(4)=plot(INV,[ones(length(INV),1) INV]*b,'b-');
legendStr{4} = sprintf('Fit');
ph(5)=plot(INV(AGE==3),TIE(AGE==3),'c.');
legendStr{5} = {'9 months'};
X = INV(AGE==3&~idnan);
Y = TIE(AGE==3&~idnan);
[r,p] = corrcoef(X,Y);
b = [ones(length(X),1) X]\Y;
ph(6)=plot(INV,[ones(length(INV),1) INV]*b,'b-');
legendStr{6} = sprintf('Fit');
legend
xlabel('Investigation laps')
ylabel('Titration inefficiency')
set(gca,'xlim',[0 30])
hold off
saveas(fh,[prefix 'TIE_vs_InvestigationLaps_by_Age.fig'],'fig')
saveas(fh,[prefix 'TIE_vs_InvestigationLaps_by_Age.eps'],'epsc')
% close all
%% DEF session list with Rat, AGE, PR, SSN, Directory.
RAT = can2mat(MasterEfficiencyTable.DATA(:,1));
AGE = can2mat(MasterEfficiencyTable.DATA(:,2));
PR = can2mat(MasterEfficiencyTable.DATA(:,3));
SSN = (MasterEfficiencyTable.DATA(:,4));
FD = (MasterEfficiencyTable.DATA(:,5));

MasterSSNTable.HEADER = {'RatNumber' 'AgeGroup' 'PelletRatio' 'SSN' 'DIRECTORY'};
MasterSSNTable.DATA = cell(length(RAT),4);
MasterSSNTable.DATA(:,1) = mat2can(RAT);
MasterSSNTable.DATA(:,2) = mat2can(AGE);
MasterSSNTable.DATA(:,3) = mat2can(PR);
MasterSSNTable.DATA(:,4) = SSN;
MasterSSNTable.DATA(:,5) = FD;
save('MasterSSNList.mat','MasterSSNTable')

%% Get ADs.
finalD = MasterEfficiencyTable.DATA(:,12);
MasterSSNTable.DATA(:,6) = finalD;
MasterSSNTable.HEADER{6} = 'Compensatory Delay';
% AD = getAD_FPTAging(MasterSSNTable);
% MasterSSNTable.HEADER{6} = 'FINAL DELAY';
% MasterSSNTable.DATA(:,6) = mat2can(AD);
save('MasterSSNList.mat','MasterSSNTable')

%% Predictor and outcome matrices.
% X = can2mat(MasterSSNTable.DATA(:,[1 2 3]));
% Xfull = unique(X,'rows');
% Y = can2mat(MasterSSNTable.DATA(:,6));
% Yfull = nan(size(Xfull,1),1);
% for iX = 1 : size(Xfull,1)
%     id = all(repmat(Xfull(iX,:),size(X,1),1)==X,2);
%     
%     Yfull(iX) = nanmean(Y(id));
% end
% clear Y
% S = Xfull(:,1);
% B = Xfull(:,2);
% W = Xfull(:,3);
% Xfull = Xfull(:,2:3);
%% AD, PR @ Age simple effects Kruskal-Wallis
S = can2mat(MasterSSNTable.DATA(:,1));
PR = can2mat(MasterSSNTable.DATA(:,3));
Age = can2mat(MasterSSNTable.DATA(:,2));
Y = can2mat(MasterSSNTable.DATA(:,6));
uniqueSPR = unique([S PR],'rows');
Age0 = nan(size(uniqueSPR,1),1);
Y0 = nan(size(uniqueSPR,1),1);
PR0 = uniqueSPR(:,2);
for iSPR = 1 : size(uniqueSPR,1)
    id = uniqueSPR(iSPR,1)==S & uniqueSPR(iSPR,2)==PR;
    Y0(iSPR) = nanmedian(Y(id));
    Age0(iSPR) = nanmedian(Age(id));
end

%%
[p,tbl,stats]=kruskalwallis(Y0(Age0==1),PR0(Age0==1));
chisq = can2mat(tbl(2:end,5));
etasq = chisq./(length(Y0(Age0==1))-1);
multcompare(stats,'ctype','hsd','alpha',0.05/3);
%%
[p,tbl,stats]=kruskalwallis(Y0(Age0==2),PR0(Age0==2));
chisq = can2mat(tbl(2:end,5));
etasq = chisq./(length(Y0(Age0==2))-1);
multcompare(stats,'ctype','hsd','alpha',0.05/3);
%%
[p,tbl,stats]=kruskalwallis(Y0(Age0==3),PR0(Age0==3));
chisq = can2mat(tbl(2:end,5));
etasq = chisq./(length(Y0(Age0==3))-1);
multcompare(stats,'ctype','hsd','alpha',0.05/3);

%% AD, Age @ PR simple effects Kruskal-Wallis
% PR0 = can2mat(MasterSSNTable.DATA(:,3));
% Age = can2mat(MasterSSNTable.DATA(:,2));
% Y = can2mat(MasterSSNTable.DATA(:,6));
%%
[p,tbl,stats]=kruskalwallis(Y0(PR0==1),Age0(PR0==1));
chisq = can2mat(tbl(2:end,5));
etasq = chisq./(length(Y0(PR==1))-1);
multcompare(stats,'ctype','hsd','alpha',0.05/3);
%%
[p,tbl,stats]=kruskalwallis(Y0(PR0==2),Age0(PR0==2));
chisq = can2mat(tbl(2:end,5));
etasq = chisq./(length(Y0(PR0==2))-1);
multcompare(stats,'ctype','hsd','alpha',0.05/3);
%%
[p,tbl,stats]=kruskalwallis(Y0(PR0==3),Age0(PR0==3));
chisq = can2mat(tbl(2:end,5));
etasq = chisq./(length(Y0(PR0==3))-1);
multcompare(stats,'ctype','hsd','alpha',0.05/3);
%%
[p,tbl,stats]=kruskalwallis(Y0(PR0==4),Age0(PR0==4));
chisq = can2mat(tbl(2:end,5));
etasq = chisq./(length(Y0(PR0==4))-1);
multcompare(stats,'ctype','hsd','alpha',0.05/3);

%% AD, Age main effect
% Age = can2mat(MasterSSNTable.DATA(:,2));
% Y = can2mat(MasterSSNTable.DATA(:,6));
[p,tbl,stats]=kruskalwallis(Y0,Age0);
multcompare(stats,'ctype','hsd','alpha',0.05);

%% AD, PR main effect
% PR = can2mat(MasterSSNTable.DATA(:,3));
% Y = can2mat(MasterSSNTable.DATA(:,6));
[p,tbl,stats]=kruskalwallis(Y0,PR0);
multcompare(stats,'ctype','hsd','alpha',0.05);

%%
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
        id = PR0==iPR & Age0==iAge;
        M(iPR,iAge) = nanmedian(Y0(id));
        Q1(iPR,iAge) = prctile(Y0(id),25);
        Q3(iPR,iAge) = prctile(Y0(id),75);
%         Lo(iPR,iAge) = prctile(Y(id),2.5);
%         Hi(iPR,iAge) = prctile(Y(id),97.5);
    end
    
end
figure
hold on
E1 = M-Q1;
E3 = Q3-M;

d = linspace(-0.4,0.4,5); d=d(2:end-1);
w = 0.8*mean(diff(d));
x = repmat((1:4)',1,3)+repmat(d,4,1);
cmap = [0 1 1;
        0 0 1;
        1 0 0];
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

%% AD , Age x PR
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
AD_AgeXPR_Mixed2WayAnova;
popdir;

%% FIGURE: AD vs PR x Age
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
AD_AgeXPR_Figure;
popdir;

%% FIGURE: AD vs PR
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
AD_PR_Figure;
popdir;

%% FIGURE: AD vs Age
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
AD_Age_Figure;
popdir;
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% DEF VTE list with Rat, Age, PR, SSN, Directory, AD, Lap, D, C, LogIdPhi, zIdPhi, Titration/Alternation, Z-LogIdPhi
VTETable = getVTE_FPTAging(MasterSSNTable);
save('VTETable.mat','VTETable')

%% Autocorrelation of choice
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
autocorrelation_choice_by_lap_Figure
popdir;

%%
uniqueSSN = unique(VTETable.DATA(:,5)); 
D = nan(length(uniqueSSN),1); 
AGE = nan(length(uniqueSSN),1); 
for iSSN = 1 : length(uniqueSSN); 
    id = strcmp(uniqueSSN{iSSN},VTETable.DATA(:,5)); 
    id0 = strcmp(uniqueSSN{iSSN},MasterEfficiencyTable.DATA(:,5));
    nINV = can2mat(MasterEfficiencyTable.DATA(id0,6));
    if ~isnan(nINV)
        C = can2mat(VTETable.DATA(id,9));
        C = C(1:nINV);
        D(iSSN) = nansum(C)/length(C);
    else
        D(iSSN) = nan;
    end
    AGE(iSSN) = nanmean(can2mat(VTETable.DATA(id,2))); 
end
for iAge = 1 : 3; m(iAge) = nanmean(D(AGE==iAge)); s(iAge) = nanstderr(D(AGE==iAge)); end; 
figure
set(gca,'fontsize',18)
set(gca,'fontname','Arial')
hold on; 
bh=bar(1:3,m); 
childs=get(bh,'children');
set(childs,'facecolor',[0.8 0.8 0.8]);
eh=errorbar(1:3,m,s);
set(eh,'linestyle','none');
set(eh,'color','k');
xlabel('Age group')
set(gca,'ylim',[-1 -0.4])
set(gca,'xtick',[1:3])
set(gca,'xticklabel',RatGroups)
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

%% FIGURE: Example economic/noneconomic
%pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
%ExampleEconNonecon_Figure;
%popdir;

%% FIGURE: Example VTE/NOT
%pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
%ExampleVTENot_Figure;
%popdir;

%% FIGURE: All LogIdPhi histogram
clf
hold on
set(gca,'fontname','Arial')
set(gca,'fontsize',18)
title(sprintf('All groups'))
[f,bin] = hist(can2mat(VTETable.DATA(:,10)),linspace(1,3.5,30));
% plot(bin,f/sum(f),'k-','linewidth',2)
bh=bar(bin,f/sum(f),1);
binw = mean(diff(bin));
set(get(bh,'children'),'facecolor',[0.8 0.8 0.8])
set(get(bh,'children'),'edgecolor',[0.6 0.6 0.6])
idnan = isnan(can2mat(VTETable.DATA(:,10)))|isinf(can2mat(VTETable.DATA(:,10)));
mixfit = gmdistribution.fit(can2mat(VTETable.DATA(~idnan,10)),2);
[mu,idsort] = sort(mixfit.mu);
Sigma = mixfit.Sigma(idsort);
PComponents = mixfit.PComponents(idsort);
% PComponents = fit_gauss_taus(can2mat(VTETable.DATA(:,10)),mu,sqrt(Sigma));

ph=plot(bin,cdf(mixfit,bin(:)+binw/2)-cdf(mixfit,bin(:)-binw/2),'k-','linewidth',2);
legendStr = cell(1,2);
legendStr{1} = sprintf('Data');
legendStr{2} = sprintf('Gaussian mixture fit');

legend([get(bh,'children') ph],legendStr)
xlabel(sprintf('Log_{10}[I d\\phi]'));
ylabel('Proportion of laps');
set(gca,'box','off')
set(gca,'xlim',[1 3.5])
set(gca,'ylim',[0 0.5])
hold off
saveas(gcf,[prefix 'Overall_LogIdPhi_hist.fig'],'fig')
saveas(gcf,[prefix 'Overall_LogIdPhi_hist.eps'],'epsc')
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% FIGURE: All LogIdPhi survivor
% [f,bin] = ecdf(can2mat(VTETable.DATA(:,10)),'function','survivor');
% stairs(bin,f,'k-','linewidth',2)
% xlabel(sprintf('Log_{10}[I d\\phi]'));
% ylabel('Surviving Fraction');
% set(gca,'box','off')
% saveas(gcf,[prefix 'Overall_LogIdPhi_surv.fig'],'fig')
% saveas(gcf,[prefix 'Overall_LogIdPhi_surv.eps'],'epsc')
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end


%% FIGURE: Raw LogIdPhi
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
LogIdPhi_Figure;
popdir;
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% FIGURE: z IdPhi
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% zIdPhi_Figure;
% popdir;
%% FIGURE: VTE occurrence vs. age
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% VTE_Age_Figure;
% popdir;
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% FIGURE: zIdPhi vs. Age
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% zIdPhi_Age_Figure;
% popdir;
%% FIGURE: LogIdPhi vs. Age
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% LogIdPhi_Age_Figure;
% popdir;
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% FIGURE: LogIdPhi vs. Binned lap
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% LogIdPhi_binnedLap_Figure;
% popdir;

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

%% P(VTE|Alternation)
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% VTEatAlt_Age_Figure;
% popdir;

%% FIGURE: P(Alternation | VTE) and P(Alternation | Not VTE)
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% AltatVTE_Age_Figure;
% AltatNOT_Age_Figure;
% popdir;

%% FIGURE: P(VTE|Titration)
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% VTEatTit_Age_Figure
% popdir;
%% FIGURE: LogIdPhi at Alternation and Titration by Age
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% LogIdPhiatAlt_Age_Figure
% LogIdPhiatTit_Age_Figure
% popdir;
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

%% FIGURE: P(Alternation)
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% Alt_Age_Figure
% popdir;

%% FIGURE: P(VTE) by percent alternation for each age, during Alt and Tit laps
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% VTEduringAltTit_Age_Figure
% popdir;
%% FIGURE: LogIdPhi by percent alternation for each age, during Alt and Tit laps
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% LogIdPhiduringAltTit_Age_Figure
% popdir;
%% FIGURE: LogIdPhi by percent alternation for each age, during Alt and Tit laps,
%          comparing mean to 95% confidence interval about the shuffled
%          control (same sequence of alt/tit but shuffled LogIdPhi)
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
LogIdPhiduringAltTit_Control_Age_SubFigures;
popdir;
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% FIGURE: MAD histogram
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
MADT_histogram
popdir;
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% FIGURE: MAD vs Age
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
MADD_Age_Figure
popdir;
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% FIGURE: P1s histogram
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
P1s_histogram;
popdir;
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% FIGURE: P1s vs Age
pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
P1s_Age_Figure
popdir;
%%
close all
ch = get(0,'children');
for c = 1 : length(ch)
    close(ch(c));
end

%% FIGURE: Time in CP vs Age
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% CPtime_Age_Figure;
% popdir;
%% FIGURE: Time in CP vs LogIdPhi
% pushdir('G:\DATA\FPT_Aging\ResultsPacket2');
% CPtime_LogIdPhi_Age_Figure;
% popdir;
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
