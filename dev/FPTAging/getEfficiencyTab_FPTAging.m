function MasterEfficiencyTable = getEfficiencyTab_FPTAging(RatAgeList,prefix)

RAT = [];
AGE = [];
PR = [];
SSN = cell(0,1);
FD = cell(0,1);
INV = [];
IIE = [];
AIE = [];
FIN = [];
LAP = [];
IER = [];
TIE = [];
DEL = [];
EXCL = [];
TITalt = [];
INValt = [];
TITadj = [];
INVadj = [];
EXPalt = [];
EXPadj = [];
fh(1)=figure;
fh(2)=figure;
for r = 1 : size(RatAgeList)
    rat = RatAgeList{r,1};
    pushdir(rat);
    disp(rat);
    
    rat = str2double(rat(2:end));
    fn = FindFiles('*-sd.mat');
    fd = cell(length(fn),1);
    ssn = cell(length(fn),1);
    pr = nan(length(fn),1);
    Invest = nan(length(fn),1);
    Adjust = nan(length(fn),1);
    Final = nan(length(fn),1);
    Laps = nan(length(fn),1);
    InefficiencyOveral = nan(length(fn),1);
    InefficiencyTitration = nan(length(fn),1);
    InefficiencyAlternation = nan(length(fn),1);
    InefficiencyInvestigation = nan(length(fn),1);
    Delay = nan(length(fn),1);
    Exclusion = false(length(fn),1);
    titAlterns = nan(length(fn),1);
    invAlterns = nan(length(fn),1);
    titAdjusts = nan(length(fn),1);
    invAdjusts = nan(length(fn),1);
    expAlterns = nan(length(fn),1);
    expAdjusts = nan(length(fn),1);
    for f = 1 : length(fn)
        pn = fileparts(fn{f});
        pushdir(pn);
        disp(pn);
        fd{f} = pn;
        id = regexpi(pn,'\');
        ssn{f} = pn(max(id)+1:end);
        
        sd = FPTInit;
        set(0,'currentfigure',fh(2))
        clf
        C = sd.ZoneIn==sd.DelayZone;
        
        [DD,LL] = DD_getDelays(sd,'nL',sd.TotalLaps);
        laps = (1:sd.TotalLaps)';
%         phases = DD_getPhaseSW2(sd,'nL',sd.TotalLaps);
%         Investigation = phases==1;
%         Titration = phases==2;
%         Alternation = phases==3;
%         nanlaps = find(isnan(phases));
%         Switch = (phases(1:end-1)==2&phases(2:end)==3)|(phases(1:end-1)==3&phases(2:end)==2);
%         SwitchLap = laps(Switch);
%         
%         nSwitches = length(SwitchLap);
%         nInvest = sum(double(Investigation));
%         nAdjust = sum(double(Titration));
%         nFinal = sum(double(Alternation));
        
        hold on
        plot(laps,LL,'ko-','linewidth',2)
%         plot(laps(Investigation),LL(Investigation),'ro','markerfacecolor','r')
%         plot(laps(Titration),LL(Titration),'bo')
%         plot(laps(Alternation),LL(Alternation),'go')
        Last20 = LL(laps>sd.TotalLaps-20);
        finalDelay = mean(Last20);
        startDelay = LL(1);
        if ~isnan(finalDelay)
            [ID,TI,nInvest,firstAltern] = DD_idealTitration(sd);
            [Inv0,Inv,Tit,Expl] = FPT_getPhases(sd);
            TA = DD_getLapType(sd,'nL',sd.TotalLaps);
            titAlterns(f) = sum(double(TA(Tit)==0));
            invAlterns(f) = sum(double(TA(Inv|Inv0)==0));
            titAdjusts(f) = sum(double(TA(Tit)==1));
            invAdjusts(f) = sum(double(TA(Inv|Inv0)==1));
            expAlterns(f) = sum(double(TA(Expl)==0));
            expAdjusts(f) = sum(double(TA(Expl)==1));
            
            if titAdjusts(f)==0
                disp('DEBUG.')
            end
            
            startLap = min(find(sd.ZoneIn==sd.DelayZone,1,'first'));
            Inefficiency = sqrt(mean((LL(startLap:end)-ID(startLap:end)).^2));
            
            AlternationInefficiency = sqrt(mean((LL(firstAltern:end)-finalDelay).^2));
            if nInvest-startLap>0
                InvestigationInefficiency = sqrt(mean((LL(startLap:nInvest)-startDelay).^2));
            else
                InvestigationInefficiency = nan;
            end
            
            if (firstAltern-nInvest)>1
                OT = LL(nInvest+1:firstAltern-1);
                IT0 = LL(nInvest+1):sign(finalDelay-startDelay):LL(firstAltern-1);
                nExtra = length(OT)-length(IT0);
                leading = floor(nExtra/2);
                trailing = nExtra-leading;
                IT1 = nan(length(OT),1);
                IT1(1:leading) = startDelay;
                IT1(leading+1:leading+length(IT0)) = IT0;
                IT1(leading+length(IT0)+1:leading+length(IT0)+trailing) = finalDelay;
                leading = ceil(nExtra/2);
                trailing = nExtra-leading;
                IT2 = nan(length(OT),1);
                IT2(1:leading) = startDelay;
                IT2(leading+1:leading+length(IT0))=IT0;
                IT2(leading+length(IT0)+1:leading+length(IT0)+nExtra-leading) = finalDelay;
                IT = nanmean([IT1(:) IT2(:)],2);
                TitrationInefficiency = sqrt(mean((OT-IT).^2));
            else
                IT = nan;
                OT = nan;
                TitrationInefficiency = nan;
            end
            
            if nInvest-startLap>0
                OverallInefficiency = sqrt(nanmean(([(LL(startLap:nInvest)-startDelay) ; abs(OT-IT) ; abs(LL(firstAltern:end)-finalDelay)]).^2));
            else
                OverallInefficiency = sqrt(nanmean(([abs(OT-IT) ; abs(LL(firstAltern:end)-finalDelay)]).^2));
            end
            
            ph = nan(3,1);
            legendStr = cell(3,1);
            plot(startLap:nInvest,LL(startLap:nInvest),'ro','markerfacecolor','r')
            plot(nInvest+1:firstAltern-1,LL(nInvest+1:firstAltern-1),'go','markerfacecolor','g')
            plot(firstAltern:sd.TotalLaps,LL(firstAltern:sd.TotalLaps),'bo','markerfacecolor','b')
            
            ph(1)=plot([1 nInvest],[startDelay startDelay],':m','linewidth',2);
            legendStr{1} = sprintf('Invest Ineff=%.3f',InvestigationInefficiency);
            if (firstAltern-nInvest)>1
                ph(2)=plot([nInvest+1:firstAltern-1],IT,'-','color',[0.8 0.8 0.8],'linewidth',2);
                legendStr{2} = sprintf('Tit Ineff=%.3f',TitrationInefficiency);
            end
%             ph(2)=plot(nInvest+1:sd.TotalLaps,TI(nInvest+1:end),'c:','linewidth',2);
            ph(3)=plot([firstAltern sd.TotalLaps],[ finalDelay finalDelay],':c');
            legendStr{3} = sprintf('Exploit Ineff=%.3f\nOverall Ineff=%.3f',AlternationInefficiency,OverallInefficiency);
            
            idnan = isnan(ph);
            ph(idnan) = [];
            legendStr(idnan) = [];
            legend(ph,legendStr);
        else
            InefficiencyOveral(f) = nan;
            InefficiencyTitration(f) = nan;
            nInvest = nan;
        end
        set(gca,'ylim',[0 30])
        set(gca,'xlim',[0 200])
        hold off
        drawnow
%         if sum(double(C))/length(C)<0.90
%             dev = LL-finalDelay;
% 
%             firstTitration = min(laps(Titration));
%             if any(Alternation)
%                 lastExploitation = max(laps(Alternation));
%             else
%                 lastExploitation = sd.TotalLaps;
%             end
%             lastTitration = min(max(laps(Titration&laps<lastExploitation)),sd.TotalLaps);
%             if isempty(Inefficiency)
%                 Inefficiency = nan;
%             end
            fprintf('\nInefficiency=%.4f,\nInvest=%.3f\n',Inefficiency,nInvest);
            Invest(f) = nInvest;
%             Adjust(f) = nAdjust;
%             Final(f) = nFinal;
            Laps(f) = sd.TotalLaps;
            Invest(f) = nInvest;
            InefficiencyOveral(f) = Inefficiency;
            InefficiencyTitration(f) = TitrationInefficiency;
            InefficiencyAlternation(f) = AlternationInefficiency;
            InefficiencyInvestigation(f) = InvestigationInefficiency;
            Delay(f) = finalDelay;
            Exclusion(f) = false;
%             Swtch(f) = nSwitches;
%         else
%             Invest(f) = nan;
% %             Adjust(f) = nan;
% %             Final(f) = nan;
%             Laps(f) = sd.TotalLaps;
%             InefficiencyOveral(f) = nan;
%             InefficiencyTitration(f) = nan;
%             InefficiencyAlternation(f) = nan;
%             InefficiencyInvestigation(f)=nan;
%             Delay(f) = nan;
%             Exclusion(f) = true;
%         end
        pr(f) = round(10.^(abs(log10(sd.World.nPleft/sd.World.nPright))));
        saveas(fh(2),'SessionPhases.fig','fig')
        saveas(fh(2),'SessionPhases.eps','epsc')
        popdir;
    end
    age = repmat(RatAgeList{r,2},length(fn),1);
    rat = repmat(rat,length(fn),1);
    RAT = cat(1,RAT,rat);
    AGE = cat(1,AGE,age);
    PR = cat(1,PR,pr);
    SSN = cat(1,SSN,ssn);
    FD = cat(1,FD,fd);
    INV = cat(1,INV,Invest);
     IIE = cat(1,IIE,InefficiencyInvestigation);
     AIE = cat(1,AIE,InefficiencyAlternation);
%     FIN = cat(1,FIN,Final);
    LAP = cat(1,LAP,Laps);
    IER = cat(1,IER,InefficiencyOveral);
    TIE = cat(1,TIE,InefficiencyTitration);
    DEL = cat(1,DEL,Delay);
    EXCL = cat(1,EXCL,Exclusion);
    TITalt = cat(1,TITalt,titAlterns);
    INValt = cat(1,INValt,invAlterns);
    TITadj = cat(1,TITadj,titAdjusts);
    INVadj = cat(1,INVadj,invAdjusts);
    EXPadj = cat(1,EXPadj,expAdjusts);
    EXPalt = cat(1,EXPalt,expAlterns);
    
    set(0,'currentfigure',fh(1));
    clf
    subplot(4,4,1)
    hold on
    p = kruskalwallis(IIE,AGE,'off');
    title(sprintf('P(Alternation|Investigation)\n(\\pm 95%% CI'))
    m = nan(3,1);
    ex = nan(3,2);
    for iAge=1:3
        [m(iAge),lo,hi] = binocis(TITalt(AGE==iAge),TITadj(AGE==iAge),1,0.05/3);
        ex(iAge,1) = m(iAge)-lo;
        ex(iAge,2) = hi-m(iAge);
    end
    plot(1:3,m,'ko')
    eh=errorbar(1:3,m,ex(:,1),ex(:,2));set(eh,'linestyle','none');
    set(gca,'ylim',[0 1])
    hold off
    subplot(4,4,2)
    hold on
    title(sprintf('P(Adjustment|Titration)\n(\\pm 95%% CI)'))
    m = nan(3,1);
    ex = nan(3,2);
    for iAge=1:3
        [m(iAge),lo,hi] = binocis(INVadj(AGE==iAge),INValt(AGE==iAge),1,0.05/3);
        ex(iAge,1) = m(iAge)-lo;
        ex(iAge,2) = hi-m(iAge);
    end
    plot(1:3,m,'ko')
    eh=errorbar(1:3,m,ex(:,1),ex(:,2));set(eh,'linestyle','none');
    set(gca,'ylim',[0 1])
    hold off
    
    subplot(4,4,3)
    p = kruskalwallis(AIE,AGE,'off');
    hold on
    title(sprintf('P(Alternation|Exploitation)\n(\\pm 95%% CI)'))
    m = nan(3,1);
    ex = nan(3,2);
    for iAge=1:3
        [m(iAge),lo,hi] = binocis(EXPadj(AGE==iAge),EXPalt(AGE==iAge),1,0.05/3);
        ex(iAge,1) = m(iAge)-lo;
        ex(iAge,2) = hi-m(iAge);
    end
    plot(1:3,m,'ko')
    eh=errorbar(1:3,m,ex(:,1),ex(:,2));set(eh,'linestyle','none');
    set(gca,'ylim',[0 1])
    hold off
    
    
    subplot(4,4,5)
    hold on
    id=AGE==1;
    [f,bin]=hist(INVadj(id),linspace(0,30,25));
    f2=hist(INValt(id),linspace(0,30,25));
    bar(bin(:),[f(:)./sum(f) f2(:)./sum(f2)],1)
    set(gca,'ylim',[0 1])
    set(gca,'xlim',[0 30])
    ylabel('adolescent')
    hold off
    subplot(4,4,9)
    hold on
    id=AGE==2;
    [f,bin]=hist(INVadj(id),linspace(0,30,25));
    f2=hist(INValt(id),linspace(0,30,25));
    bar(bin(:),[f(:)./sum(f) f2(:)./sum(f2)],1)
    set(gca,'ylim',[0 1])
    set(gca,'xlim',[0 30])
    ylabel('adult')
    hold off
    subplot(4,4,13)
    hold on
    id=AGE==3;
    [f,bin]=hist(INVadj(id),linspace(0,30,25));
    f2=hist(INValt(id),linspace(0,30,25));
    bar(bin(:),[f(:)./sum(f) f2(:)./sum(f2)],1)
    bar(bin,f./sum(f),1)
    set(gca,'ylim',[0 1])
    set(gca,'xlim',[0 30])
    ylabel('aged')
    hold off
    
    subplot(4,4,6)
    hold on
    id=AGE==1;
    [f,bin]=hist(TITalt(id),linspace(0,30,25));
    f2=hist(TITadj(id),linspace(0,30,25));
    bar(bin(:),[f(:)./sum(f) f2(:)./sum(f2)],1)
    set(gca,'xlim',[0 30])
    set(gca,'ylim',[0 1])
    hold off
    subplot(4,4,10)
    hold on
    id=AGE==2;
    [f,bin]=hist(TITalt(id),linspace(0,30,25));
    f2=hist(TITadj(id),linspace(0,30,25));
    bar(bin(:),[f(:)./sum(f) f2(:)./sum(f2)],1)
    set(gca,'xlim',[0 30])
    set(gca,'ylim',[0 1])
    hold off
    subplot(4,4,14)
    hold on
    id=AGE==3;
    [f,bin]=hist(TITalt(id),linspace(0,30,25));
    f2=hist(TITadj(id),linspace(0,30,25));
    bar(bin(:),[f(:)./sum(f) f2(:)./sum(f2)],1)
    set(gca,'xlim',[0 30])
    set(gca,'ylim',[0 1])
    hold off
    
    subplot(4,4,7)
    hold on
    id=AGE==1;
    [f,bin]=hist(EXPadj(id),linspace(0,30,25));
    f2=hist(EXPalt(id),linspace(0,30,25));
    bar(bin(:),[f(:)./sum(f) f2(:)./sum(f2)],1)
    set(gca,'ylim',[0 1])
    set(gca,'xlim',[0 30])
    hold off
    subplot(4,4,11)
    hold on
    id=AGE==2;
    [f,bin]=hist(EXPadj(id),linspace(0,30,25));
    f2=hist(EXPalt(id),linspace(0,30,25));
    bar(bin(:),[f(:)./sum(f) f2(:)./sum(f2)],1)
    set(gca,'ylim',[0 1])
    set(gca,'xlim',[0 30])
    hold off
    subplot(4,4,15)
    hold on
    id=AGE==3;
    [f,bin]=hist(EXPadj(id),linspace(0,30,25));
    f2=hist(EXPalt(id),linspace(0,30,25));
    bar(bin(:),[f(:)./sum(f) f2(:)./sum(f2)],1)
    set(gca,'ylim',[0 1])
    set(gca,'xlim',[0 30])
    hold off
    
    subplot(1,4,4)
    hold on
    legendStr = cell(3,1);
    xlabel('Investigation inefficiency')
    ylabel('Exploitation inefficiency')
    ph = nan(3,1);
    if any(AGE==1)
        ph(1)=plot(INValt(AGE==1)./(INValt(AGE==1)+INVadj(AGE==1)),EXPalt(AGE==1)./(EXPalt(AGE==1)+EXPadj(AGE==1)),'r.');
        X = INV(AGE==1);
        Y = TIE(AGE==1);
        [r,p]=corrcoef(X,Y);
        b = [ones(length(X),1) X]\Y;
        plot(INValt./(INValt+INVadj),[ones(length(INValt),1) INValt./(INValt+INVadj)]*b,'r-')
        legendStr{1} = sprintf('5 mo. (r=%.3f,p=%.4f)',r(2),p(2));
    end
    if any(AGE==2)
        ph(2)=plot(INValt(AGE==2)./(INValt(AGE==2)+INVadj(AGE==2)),EXPalt(AGE==2)./(EXPalt(AGE==2)+EXPadj(AGE==2)),'b.');
        X = INV(AGE==2);
        Y = TIE(AGE==2);
        [r,p]=corrcoef(X,Y);
        b = [ones(length(X),1) X]\Y;
        plot(INValt./(INValt+INVadj),[ones(length(INValt),1) INValt./(INValt+INVadj)]*b,'b-')
        legendStr{2} = sprintf('9 mo. (r=%.3f,p=%.4f)',r(2),p(2));
    end
    if any(AGE==3)
        ph(3)=plot(INValt(AGE==3)./(INValt(AGE==3)+INVadj(AGE==3)),EXPalt(AGE==3)./(EXPalt(AGE==3)+EXPadj(AGE==3)),'g.');
        X = INV(AGE==3);
        Y = TIE(AGE==3);
        [r,p]=corrcoef(X,Y);
        b = [ones(length(X),1) X]\Y;
        plot(INValt./(INValt+INVadj),[ones(length(INValt),1) INValt./(INValt+INVadj)]*b,'g-')
        legendStr{3} = sprintf('>27 mo. (r=%.3f,p=%.4f)',r(2),p(2));
    end
    idnan = isnan(ph);
    ph(idnan) = [];
    legendStr(idnan) = [];
    legend(ph,legendStr)
    hold off
    drawnow
    popdir;
end
saveas(fh(1),[prefix 'InefficiencySummary.fig'],'fig')
saveas(fh(1),[prefix 'InefficiencySummary.eps'],'epsc')

MasterEfficiencyTable.HEADER = {'Rat' 'Age' 'PR' 'SSN' 'FD' 'Investigation Laps' 'Investigation inefficiency' 'Alternation inefficiency' 'Total Laps' 'Inefficiency (MADIT)' 'Titration Inefficiency (shifted-MADIT)' 'Compensatory delay' 'Investigation alternations' 'Titration alternations' 'Investigation adjustments' 'Titration adjustments' 'Exploitation alternations' 'Exploitation adjustments' 'Exclude session'};
MasterEfficiencyTable.DATA = cell(length(RAT),11);
MasterEfficiencyTable.DATA(:,1) = mat2can(RAT);
MasterEfficiencyTable.DATA(:,2) = mat2can(AGE);
MasterEfficiencyTable.DATA(:,3) = mat2can(PR);
MasterEfficiencyTable.DATA(:,4) = SSN;
MasterEfficiencyTable.DATA(:,5) = FD;
MasterEfficiencyTable.DATA(:,6) = mat2can(INV);
MasterEfficiencyTable.DATA(:,7) = mat2can(IIE);
MasterEfficiencyTable.DATA(:,8) = mat2can(AIE);
MasterEfficiencyTable.DATA(:,9) = mat2can(LAP);
MasterEfficiencyTable.DATA(:,10) = mat2can(IER);
MasterEfficiencyTable.DATA(:,11) = mat2can(TIE);
MasterEfficiencyTable.DATA(:,12) = mat2can(DEL);
MasterEfficiencyTable.DATA(:,13) = mat2can(INValt);
MasterEfficiencyTable.DATA(:,14) = mat2can(TITalt);
MasterEfficiencyTable.DATA(:,15) = mat2can(INVadj);
MasterEfficiencyTable.DATA(:,16) = mat2can(TITadj);
MasterEfficiencyTable.DATA(:,17) = mat2can(EXPalt);
MasterEfficiencyTable.DATA(:,18) = mat2can(EXPadj);
MasterEfficiencyTable.DATA(:,19) = mat2can(EXCL);

[p,table,stats] = kruskalwallis(IER,AGE,'off');
MasterEfficiencyTable.OverallInefficiency.p = p;
MasterEfficiencyTable.OverallInefficiency.table = table;
MasterEfficiencyTable.OverallInefficiency.stats = stats;
[c,m,h]=multcompare(stats,'display','off');
MasterEfficiencyTable.OverallInefficiency.c = c;
MasterEfficiencyTable.OverallInefficiency.m = m;
MasterEfficiencyTable.OverallInefficiency.h = h;

[p,table,stats] = kruskalwallis(IIE,AGE,'off');
MasterEfficiencyTable.InvestigationInefficiency.p = p;
MasterEfficiencyTable.InvestigationInefficiency.table = table;
MasterEfficiencyTable.InvestigationInefficiency.stats = stats;
[c,m,h]=multcompare(stats,'display','off');
MasterEfficiencyTable.InvestigationInefficiency.c = c;
MasterEfficiencyTable.InvestigationInefficiency.m = m;
MasterEfficiencyTable.InvestigationInefficiency.h = h;

[p,table,stats] = kruskalwallis(TIE,AGE,'off');
MasterEfficiencyTable.TitrationInefficiency.p = p;
MasterEfficiencyTable.TitrationInefficiency.table = table;
MasterEfficiencyTable.TitrationInefficiency.stats = stats;
[c,m,h]=multcompare(stats,'display','off');
MasterEfficiencyTable.TitrationInefficiency.c = c;
MasterEfficiencyTable.TitrationInefficiency.m = m;
MasterEfficiencyTable.TitrationInefficiency.h = h;

[p,table,stats] = kruskalwallis(AIE,AGE,'off');
MasterEfficiencyTable.ExploitationInefficiency.p = p;
MasterEfficiencyTable.ExploitationInefficiency.table = table;
MasterEfficiencyTable.ExploitationInefficiency.stats = stats;
[c,n,h]=multcompare(stats,'display','off');
MasterEfficiencyTable.ExploitationInefficiency.c = c;
MasterEfficiencyTable.ExploitationInefficiency.m = m;
MasterEfficiencyTable.ExploitationInefficiency.h = h;

[p,table,stats] = kruskalwallis(INV,AGE,'off');
MasterEfficiencyTable.InvestigationLaps.p = p;
MasterEfficiencyTable.InvestigationLaps.table = table;
MasterEfficiencyTable.InvestigationLaps.stats = stats;
[c,n,h]=multcompare(stats,'display','off');
MasterEfficiencyTable.InvestigationLaps.c = c;
MasterEfficiencyTable.InvestigationLaps.m = m;
MasterEfficiencyTable.InvestigationLaps.h = h;
