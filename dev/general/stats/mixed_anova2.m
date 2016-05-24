function [p,table,posthoc] = mixed_anova2(S,B,W,Y,varargin)
%
%
%
%

method = 'bonferroni';
process_varargin(varargin);

Subjects = unique(S);
Between = unique(B);
Within = unique(W);
BxW = unique([B W],'rows');
SxW = unique([S W],'rows');

uniqueSBW = unique([S B W],'rows');
for r = 1 : size(uniqueSBW,1)
    idS = S==uniqueSBW(r,1);
    idB = B==uniqueSBW(r,2);
    idW = W==uniqueSBW(r,3);
    Y0(r) = nanmean(Y(idS&idB&idW));
end
S = uniqueSBW(:,1);
B = uniqueSBW(:,2);
W = uniqueSBW(:,3);
Y = Y0;

% 
% % Each subject's mean, across levels of the within factor.
% mS = nan(length(Y),1);
% for iS = 1 : length(Subjects)
%     idS = Subjects(iS) == S;
%     nS(idS) = sum(double(idS));
%     mS(idS) = nanmean(Y(idS));
% end
% 
% % Each group's mean, across levels of the within factor.
% mB = nan(length(Y),1);
% for iB = 1 : length(Between)
%     idB = Between(iB) == B;
%     nB(idB) = sum(double(idB));
%     mB(idB) = nanmean(Y(idB));
% end
% 
% % Each condition's mean, across groups.
% mW = nan(length(Y),1);
% for iW = 1 : length(Within)
%     idW = Within(iW) == W;
%     nW(idW) = sum(double(idW));
%     mW(idW) = nanmean(Y(idW));
% end
% 
% % The cell mean of the group-condition combination.
% mBW = nan(length(Y),1);
% for iBW = 1 : size(BxW,1)
%     idBW = BxW(iBW,1)==B & BxW(iBW,2)==W;
%     nBW(idBW) = sum(double(idBW));
%     mBW(idBW) = nanmean(Y(idBW));
% end
% 
% % The cell mean of the group-condition combination.
% mSW = nan(length(Y),1);
% for iSW = 1 : size(SxW,1)
%     idSW = SxW(iSW,1)==S & SxW(iSW,2)==W;
%     nSW(idSW) = sum(double(idSW));
%     mSW(idSW) = nanmean(Y(idSW));
% end
% 
% % Deviations:
% % Total
% Dt = Y - nanmean(Y);
% % Of Between from overall
% Db = mB - nanmean(Y);
% % Of Subjects within Between from group mean
% Dsb = mS - mB;
% % Of subjects from overall
% Ds = mS - nanmean(Y);
% % Of Within from overall
% Dw = mW - nanmean(Y);
% % Of group-condition from overall, removing group and condition alone
% Dbw = mBW - mB - mW + nanmean(Y);
% % What's left is error due to interactions between subject and condition.
% Dsw = Y - mBW - mW - mB;
% 
% SSt = Dt'*Dt;
% dft = length(Y)-1;
% 
% SSb = Db'*Db;
% dfb = length(Between)-1;
% SSsb = Dsb'*Dsb;
% dfsb = (length(Subjects)-1)-(length(Between)-1);
% SSs = Ds'*Ds;
% dfs = length(Subjects)-1;
% SSw = Dw'*Dw;
% dfw = length(Within)-1;
% SSbw = Dbw'*Dbw;
% dfbw = (length(Within)-1)*(length(Between)-1);
% 
% SSerr = SSt - (SSb+SSsb+SSw+SSbw);
% dferr = (dft - dfs) - (dfw + dfbw);
% 
% MSt = SSt/dft;
% MSb = SSb/dfb;
% MSsb = SSsb/dfsb;
% % MSs = SSs/dfs;
% MSw = SSw/dfw;
% MSbw = SSbw/dfbw;
% MSerr = SSerr/dferr;
% 
% Fb = MSb/MSsb;
% Fw = MSw/MSerr;
% Fbw = MSbw/MSerr;
% 
% p = 1-fcdf([Fb; Fw; Fbw],[dfb; dfw; dfbw],[dfsb; dferr; dferr]);
% 
% table(1,1:6) = {'Source' 'SS' 'df' 'MS' 'F' 'p'};
% % table(2,1:3) = {'Subjects' SSs dfs};
% table(3,1:6) = {'Between' SSb dfb MSb Fb p(1)};
% table(4,1:4) = {'Error' SSsb dfsb MSsb};
% 
% table(5,1:6) = {'Within' SSw dfw MSw Fw p(2)};
% table(6,1:6) = {'Between X Within' SSbw dfbw MSbw Fbw p(3)};
% table(7,1:4) = {'Error' SSerr dferr MSerr};
% table(8,1:4) = {'TOTAL' SSt dft MSt};

[p,table,stats,terms] = anovan(Y,[S B W],'nested',[0 1 0;0 0 0;0 0 0],'random',1,'model','full','varnames',{'Subject' 'Between' 'Within'});

MSsb = table{2,5};
MSsw = table{5,5};

% post hoc
% number of permutations of 2-choose-n

t = nan(length(Between));
df = t;
    cB = 0;
    for c1 = 1 : length(Between)-1
        id1 = Between(c1)==B;
        m1 = nanmean(Y(id1));
        n1 = length(unique(S(id1)));
        v1 = nanvar(Y(id1));
        for c2 = c1+1:length(Between)
            id2 = Between(c2)==B;
            m2 = nanmean(Y(id2));
            n2 = length(unique(S(id2)));
            v2 = nanvar(Y(id1));
            
            v = ((n1-1)*v1+(n2-1)*v2)/((n1-1)+(n2-1));
            t(c1,c2) = (m1-m2)/sqrt(v/(n1+n2));
            df(c1,c2) = (n1-1)+(n2-1);
            cB = cB+1;
        end
    end
    
    posthoc(1).t = t;
    posthoc(1).df = df;
    posthoc(1).p = 1-tcdf(abs(t),df);
    if strcmpi(method,'exact')
        alpha_pc = 1 - (1 - 0.05).^(1/cB);
    elseif strcmpi(method,'bonferroni')
        alpha_pc = 0.05/cB;
    end
    posthoc(1).alpha_pc = alpha_pc;
    posthoc(1).crit = posthoc(1).p<=alpha_pc;
    
    figure
    hold on
    mY = nan(length(Between),1);
    sY = mY;
    for c1 = 1 : length(Between)
        id1 = Between(c1)==B;
        mY(c1) = nanmean(Y(id1));
        sY(c1) = nanstderr(Y(id1));
    end
    xlabel('Between-subjects factor')
    ylabel('Dependent variable')
    eh=errorbar(1:length(Between),mY,sY);
    set(eh,'color','k')
    set(eh,'linestyle','none')
    plot(1:length(Between),mY,'ko','markerfacecolor','w','markersize',12)
    for r = 1 : size(posthoc(1).crit,1)
        for c = 1 : size(posthoc(1).crit,2)
            if posthoc(1).crit(r,c)
                offset = ((c-1)*r+r)/(prod(size(posthoc(1).crit)))*(max(mY)-min(mY));
                y = max(mY(r),mY(c))+offset;
                plot([r c],[y y],'k-')
                text(mean([r c]),y,'*','fontsize',24,'horizontalalignment','center','verticalalignment','bottom')
            end
        end
    end
    hold off


t = nan(length(Within));
df = t;

    cW = 0;
    for c1 = 1 : length(Within)-1
        id1 = Within(c1)==W;
        for c2 = c1+1:length(Within)
            id2 = Within(c2)==W;
            S1 = S(id1);
            S2 = S(id2);
            Scommon = intersect(S1,S2);
            d = nan(length(Scommon),1);
            for iS = 1 : length(Scommon)
                idS = Scommon(iS)==S;
                d(iS) = (Y(id1&idS))-(Y(id2&idS));
            end
            Md = nanmean(d);
            Sd = nanstderr(d);
            n = length(Scommon);
            t(c1,c2) = (Md)/Sd;
            df(c1,c2) = (n-1);
            cW = cW+1;
        end
    end
    posthoc(2).t = t;
    posthoc(2).df = df;
    posthoc(2).p = 1-tcdf(abs(t),df);
    if strcmpi('exact',method)
        alpha_pc = 1 - (1 - 0.05).^(1/cW);
    elseif strcmpi('bonferroni',method)
        alpha_pc = 0.05/cW;
    end
    posthoc(2).alpha_pc = alpha_pc;
    posthoc(2).crit = posthoc(2).p<=alpha_pc;

    figure
    hold on
    mY = nan(length(Within),1);
    sY = mY;
    for c1 = 1 : length(Within)
        id1 = Within(c1)==W;
        mY(c1) = nanmean(Y(id1));
        sY(c1) = nanstderr(Y(id1));
    end
    xlabel('Within-subjects factor')
    ylabel('Dependent variable')
    eh=errorbar(1:length(Within),mY,sY);
    set(eh,'color','k')
    set(eh,'linestyle','none')
    plot(1:length(Within),mY,'ko','markerfacecolor','w','markersize',12)
    for r = 1 : size(posthoc(2).crit,1)
        for c = 1 : size(posthoc(2).crit,2)
            if posthoc(2).crit(r,c)
                offset = ((c-1)*r+r)/(prod(size(posthoc(2).crit)))*(max(mY)-min(mY));
                y = max(mY(r),mY(c))+offset;
                plot([r c],[y y],'k-')
                text(mean([r c]),y,'*','fontsize',24,'horizontalalignment','center','verticalalignment','bottom')
            end
        end
    end
    hold off

t = nan(size(BxW,1));
df = t;

    cBW = 0;
    for c1 = 1 : size(BxW,1)-1
        id1 = BxW(c1,1)==B & BxW(c1,2)==W;
        for c2 = c1+1:size(BxW,1)
            id2 = BxW(c2,1)==B & BxW(c2,2)==W;
            S1 = S(id1);
            S2 = S(id2);
            Scommon = intersect(S1,S2);
            idS = any(repmat(S(:),1,length(Scommon))==repmat(Scommon(:)',length(S),1),2);
            m1 = nanmean(Y(id1&idS));
            m2 = nanmean(Y(id2&idS));
            n = length(intersect(S(id1),S(id2)));
            t(c1,c2) = (m1-m2)/sqrt(MSsw);
            df(c1,c2) = (n-1);
            cBW = cBW+1;
        end
    end
    posthoc(3).t = t;
    posthoc(3).p = 1-tcdf(abs(t),df);
    if strcmpi(method,'exact')
        alpha_pc = 1 - (1 - 0.05).^(1/cBW);
    else
        alpha_pc = 0.05/cBW;
    end
    posthoc(2).alpha_pc = alpha_pc;
    posthoc(3).crit = posthoc(3).p<=alpha_pc;

    figure
    hold on
    mY = nan(size(BxW,1),1);
    sY = mY;
    for c1 = 1 : size(BxW,1)
        id1 = BxW(c1,1)==B & BxW(c1,2)==W;
        mY(c1) = nanmean(Y(id1));
        sY(c1) = nanstderr(Y(id1));
    end
    xlabel('Within-subjects factor')
    ylabel('Dependent variable')
    
    cmap = lines(length(Between));
    offset = linspace(0,1,length(Between)+4)-0.5;
    offset = offset(3:end-2);
    ph = [];
    legendStr = cell(0,1);
    for iB = 1 : length(Between)
        idB = Between(iB)==BxW(:,1);
        eh=errorbar((1:length(Within))+offset(iB),mY(idB),sY(idB));
        set(eh,'color',cmap(iB,:))
        set(eh,'linestyle','none')
        ph(iB)=plot((1:length(Within))+offset(iB),mY(idB),'o','markeredgecolor',cmap(iB,:),'markerfacecolor','w','markersize',12);
        legendStr{iB} = sprintf('Between factor %d',Between(iB));
    end
    legend(ph,legendStr)
    
    for r = 1 : size(posthoc(3).crit,1)
        for c = 1 : size(posthoc(3).crit,2)
            if posthoc(3).crit(r,c)
                y = max(mY(r),mY(c));
                plot([BxW(r,2)+offset(r) BxW(c,2)+offset(c)],[y y],'k-')
                text(mean([BxW(r,2)+offset(r) BxW(c,2)+offset(c)]),y,'*','fontsize',24,'horizontalalignment','center','verticalalignment','bottom')
            end
        end
    end
    hold off