%% SSN locations
% OFCdir = 'G:\DATA\DelayRR\OFC DREADDs';
% OFCrats = {'R266';
%            'R271';
%            'R277';
%            'R279';
%            'R298'};
% promotableDirOFC = 'Promotable\StableRR\InjectionSequence';

PFCdir = '\\adrlab20\dropoff';

PFCrats = {'R267';
           'R278';
           'R280';
           'R288';
           'R291';
           'R296';
           'R297';
           'R306';
           'R308'};
promotableDirPFC = '.';

% CTLdir = 'G:\DATA\DelayRR\noDREADDs control';
% CTLrats = {'R324';
%            'R319';
%            'R323';
%            'R322'};
% promotableDirCTL = 'Promotable\StableRR';

VTEthresh = 0.5;

%% Assemble SSN fd's
% pushdir(OFCdir);
% disp(OFCdir)
% fdOFC = cell(0,1);
% k=0;
% for iR=1:length(OFCrats)
%     pushdir(OFCrats{iR});
%     disp(OFCrats{iR})
%     pushdir(promotableDirOFC);
%     
%     fn = FindFiles('RR-*.mat');
%     
%     popdir;
%     popdir;
%     for iF=1:length(fn)
%         k=k+1;
%         fdOFC{k} = fileparts(fn{iF});
%     end
% end
% fdOFC = unique(fdOFC(:));
% popdir;

pushdir(PFCdir);
disp(PFCdir);
fdPFC = cell(0,1);
k=0;
for iR=1:length(PFCrats)
    pushdir(PFCrats{iR});
    disp(PFCrats{iR});
    pushdir(promotableDirPFC);
    
    fn = FindFiles('RR-*.mat');
    
    popdir;
    popdir;
    for iF=1:length(fn)
        k=k+1;
        fdPFC{k} = fileparts(fn{iF});
    end
end
fdPFC = unique(fdPFC(:));
popdir;

% pushdir(CTLdir);
% disp(CTLdir);
% fdCTL = cell(0,1);
% k=0;
% for iR=1:length(CTLrats)
%     pushdir(CTLrats{iR});
%     disp(CTLrats{iR});
%     pushdir(promotableDirCTL);
%     
%     fn = FindFiles('RR-*.mat');
%     for iF=1:length(fn)
%         k=k+1;
%         fdCTL{k} = fileparts(fn{iF});
%     end
%     popdir;
%     popdir;
% end
% fdCTL = unique(fdCTL(:));
% popdir;

%fd = cat(1,fdOFC(:),fdPFC(:),fdCTL(:));
fd = cat(1,fdPFC(:));

%% Sort the fd list into nViralTarget x nRat x nCondition cell array
[fdSorted.fd,fdSorted.dimKey]=sortSessDimByExpKey(fd,{'ViralTarget' 'Rat' 'Condition'});

%% VTE
IdPhi = getFieldFromSSNs(fdSorted.fd,'IdPhi',@RRInit,'postProcess',{@zIdPhi});
LogIdPhi = log10(IdPhi);
LogIdPhi(IdPhi<=10) = nan;
ZLogIdPhi = nan(size(LogIdPhi));
for iRat=1:size(LogIdPhi,2)
    x1 = LogIdPhi(:,iRat,1,:,:,:);
    x2 = LogIdPhi(:,iRat,2,:,:,:);
    x = [x1(:) x2(:)];
    z = reshape(nanzscore(x(:)),[size(x,1) 2]);
    ZLogIdPhi(:,iRat,1,:,:,:) = reshape(z(:,1),size(x1));
    ZLogIdPhi(:,iRat,2,:,:,:) = reshape(z(:,2),size(x2));
end
ZIdPhi = nanzscore(IdPhi,6);

VTE = ZLogIdPhi>1;
notVTE = ZLogIdPhi<=1;

%% Value
stayGo = getFieldFromSSNs(fdSorted.fd,'stayGo',@RRInit);
delays = getFieldFromSSNs(fdSorted.fd,'ZoneDelay',@RRInit);
zoneIn = getFieldFromSSNs(fdSorted.fd,'ZoneIn',@RRInit);
%%
thresholds = nan(size(stayGo));
for iTarget=1:size(fdSorted.fd,1)
    for iRat=1:size(fdSorted.fd,2)
        for iCond=1:size(fdSorted.fd,3)
            for iRep=1:size(fdSorted.fd,4)
                if ~isempty(fdSorted.fd{iTarget,iRat,iCond,iRep})
                    pushdir(fdSorted.fd{iTarget,iRat,iCond,iRep});
                    sd = RRInit;
                    popdir;

                    % Thresholds
                    zn = zoneIn(iTarget,iRat,iCond,iRep,1,:);
                    th = nan(length(unique(zn(~isnan(zn)))),1);
                    for iZ=unique(zn(~isnan(zn)))'
                        idZ = zn==iZ;
                        d = delays(iTarget,iRat,iCond,iRep,1,idZ);
                        sg = stayGo(iTarget,iRat,iCond,iRep,1,idZ);
                        th(iZ) = RRheaviside(d(:),sg(:));
                    end
                    th0 = th(zn(~isnan(zn)));

                    thresholds(iTarget,iRat,iCond,iRep,1,1:length(th0)) = th0;
                end
            end
        end
    end
end

value = delays - thresholds;

%% Figures

binStep=3;
binLo=-12:binStep:12;
binHi=binLo+binStep;

P = nan(size(VTE,1),size(VTE,3),length(binLo),numel(VTE));
Y = nan(size(VTE,1),size(VTE,3),length(binLo),size(VTE,2),size(VTE,4));
for iTarg=1:size(VTE,1)
    m = nan(length(binLo),2);
    s = nan(length(binLo),2);
    n = nan(length(binLo),2);
    for iCond=1:size(VTE,3)
        V0 = VTE(iTarg,:,iCond,:,:);
        N0 = notVTE(iTarg,:,iCond,:,:);
        val = value(iTarg,:,iCond,:,:);
        for iBin=1:length(binLo)
            id = val>=binLo(iBin) & val<binHi(iBin);
            V = nan(size(V0));
            N = nan(size(N0));
            V(id) = V0(id);
            N(id) = N0(id);
            p0 = nansum(V,5)./(nansum(V,5)+nansum(N,5));
            m(iBin,iCond) = nanmean(p0(:));
            s(iBin,iCond) = nanstderr(p0(:));
            n(iBin,iCond) = sum(~isnan(p0(:)));
            P(iTarg,iCond,iBin,1:length(p0(:))) = p0(:);
            
            Y(iTarg,iCond,iBin,1:size(p0,2),1:size(p0,4)) = squeeze(p0);
        end
    end
end
%%
h = nan(3,length(binLo));
for iTarg=1:size(VTE,1)
    m = nan(length(binLo),2);
    s = nan(length(binLo),2);
    n = nan(length(binLo),2);
    for iCond=1:size(VTE,3)
        V0 = VTE(iTarg,:,iCond,:,:);
        N0 = notVTE(iTarg,:,iCond,:,:);
        val = value(iTarg,:,iCond,:,:);
        for iBin=1:length(binLo)
            id = val>=binLo(iBin) & val<binHi(iBin);
            V = nan(size(V0));
            N = nan(size(N0));
            V(id) = V0(id);
            N(id) = N0(id);
            p0 = nansum(V,5)./(nansum(V,5)+nansum(N,5));
            m(iBin,iCond) = nanmean(p0(:));
            s(iBin,iCond) = nanstderr(p0(:));
            n(iBin,iCond) = sum(~isnan(p0(:)));
        end
    end
    df = n-1;
    alpha = 0.05/(size(VTE,1)*length(binLo));
    tcrit = tinv(1-alpha/2,df);
    figure;
    hold on
    set(gca,'fontsize',28)
    sh1=ShadedErrorbar(binLo,m(:,2),s(:,2).*tcrit(:,2),'color','k');
    sh2=ShadedErrorbar(binLo,m(:,1),s(:,1).*tcrit(:,1),'color','r');
    text(binLo(h(iTarg,:)==1),nanmean(m(h(iTarg,:)==1,:),2),'$\star$','interpreter','latex','verticalalignment','middle','horizontalalignment','center','fontsize',24)
    legend([sh1(1) sh2(1)],{'Saline' 'CNO'})
    xlabel('Deviation delay - threshold, sec')
    ylabel(sprintf('P[VTE]\n(mean \\pm 95%% CI)'))
    if ~isempty(fdSorted.dimKey.dimLevels{iTarg,1})
        title(fdSorted.dimKey.dimLevels{iTarg,1});
    else
        title('No-DREADDs');
    end
    xlim([-15 15])
    ylim([0.05 0.35])
    hold off
end