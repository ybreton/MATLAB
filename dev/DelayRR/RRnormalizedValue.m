function [V,U,Ue] = RRnormalizedValue(sd,varargin)
% [V,U,Ue] = RRnormalizedValue(sd)
% where         V       is nTrials x m x n x ... x p matrix of per-pellet flavour values
%               U       is nTrials x m x n x ... x p matrix of offer payoffs
%               Ue      is nTrials x m x n x ... x p matrix of overall skip payoff
%
%               sd      is m x n x ... x p standard session data structure.
%
% If sd is nx1 or 1xn structure, V, U and Ue are nTrials x n.
%
% Calculates the value of the flavor (relative to any) and the payoff for
% the offer:
%               V_z = Th_z/Th_a /N_z
%               U_z = (V_z * N_z)/D_z
%               U_e = 1/Th_a
% The normalized per-pellet value of the zone is calculated here as the
% threshold, relative to any flavour. The payoff from staying at the zone
% is the value, in arbitrary units, of pursuit of the goal per unit time.
%
% Assuming that when D_i = Th_i,
% U_i = U_go for all z,
% and assuming that
% U_i = (V_z*N_z)/D_z,
% it follows that 
% V_i*N_i/Th_i = U_e = V_j*N_j/Th_j
% which sets up the equality
% V_i/V_j = Th_i/Th_j * N_i/N_j.
% When V_a is defined as the per-pellet value of any food, and Th_a the
% threshold for obtaining any food,
% V_i/V_a = Th_i/Th_a * N_i/1
% provides a scale for measuring each flavor relative to any flavor. Since
% V_i is expressed in arbitrary units of value,
% let V_a = 1
% U_i = (V_i*N_i)/D_i
% and
% U_e = 1/Th_a.
% If we take the log,
% Log10(U_i) = log10((V_i*N_i)/D_i) = log10(((V_i*N_i)/V_a)/D_i) = log10((V_i*N_i)/V_a) - log10(Di)
%            = log10(V_i) + log10(N_i) - log10(D_i) - log10(V_a),
% with log10(V_a) constant across all zones,
% and
% Log10(U_e) = log10(1) - log10(Th_a) = -log10(Th_a).
% 
maxTrl = 800;
debug = false;
process_varargin(varargin);
sz = size(sd);
sd = sd(:);

uniqueZones = [];
nT = nan(1,length(sd));
zoneIn = nan(maxTrl,length(sd));
stayGo = nan(maxTrl,length(sd));
delay = nan(maxTrl,length(sd));
nPellets = nan(maxTrl,length(sd));
for iSubSess = 1:length(sd)
    uniqueZones = unique([uniqueZones(:); unique(sd(iSubSess).ZoneIn(:))]);
    nT(iSubSess) = length(sd(iSubSess).ZoneIn);
    zoneIn(1:nT(iSubSess),iSubSess) = sd(iSubSess).ZoneIn;
    stayGo(1:length(sd(iSubSess).ExitZoneTime),iSubSess) = ismember(sd(iSubSess).ExitZoneTime,sd(iSubSess).FeederTimes);
    delay(1:nT(iSubSess),iSubSess) = sd(iSubSess).ZoneDelay;
    nPellets(1:nT(iSubSess),iSubSess) = sd(iSubSess).nPellets;
end
idnan = isnan(delay(:))|isnan(stayGo(:));
thAll = RRheaviside(delay(~idnan),stayGo(~idnan));
th = nan(max(uniqueZones),1);
for iZ = uniqueZones(:)'
    idZ = zoneIn==iZ;

    th(iZ) = RRheaviside(delay(idZ),stayGo(idZ));
end
I = nan(size(zoneIn));
for iZ=uniqueZones(:)'
    idZ = zoneIn==iZ;
    I(idZ) = th(iZ)/thAll;
end
V = I./nPellets;
U = (V.*nPellets)./delay;
Ue = ones(size(U))./thAll;

if debug
    clf
    m = ceil(sqrt(max(uniqueZones)));
    for p = 1 : max(uniqueZones)
        subplot(2*m,m,p)
        cla
        iZ = zoneIn==uniqueZones(p);
        x = delay(iZ);
        y = stayGo(iZ);
        z = nPellets(iZ);
        v = V(iZ);
        uniqueN = unique(z(:));
        hold on
        scatterplotc(x(:),y(:)+randn(length(y),1)/20,z(:),'crange',[min(nPellets(:))-1 max(nPellets(:))+1],'plotchar','.');
        plot(th(uniqueZones(p)),0.5,'ko')
        for n=1:length(uniqueN);
            iN = z==uniqueN(n);
            th2 = nanmean(v(iN))*uniqueN(n)*thAll;
            text(th2,0.5,sprintf('%d',uniqueN(n)),'color','k')
        end
        xlabel('Delay')
        ylabel('Stay/Go')
        hold off
    end
    subplot(2,1,2)
    cla
    hold on
    scatterplotc(delay(:),stayGo(:)+randn(length(stayGo(:)),1)/20,nPellets(:),'crange',[min(nPellets(:))-1 max(nPellets(:))+1],'plotchar','.');
    plot(thAll,0.5,'ko')
    xlabel('Delay')
    ylabel('Stay/Go')
    caxis([min(nPellets(:))-1 max(nPellets(:))+1]);
    cbh=colorbar;
    set(get(cbh,'ylabel'),'string',sprintf('nPellets'));
    hold off
end

V = V(1:max(nT),:);
U = U(1:max(nT),:);
Ue = Ue(1:max(nT),:);

if any(sz>1)
    if length(sz)==2 && any(sz==1)
        sz = sz(sz~=1);
    end
    V = reshape(V,[max(nT) sz]);
    U = reshape(U,[max(nT) sz]);
    Ue = reshape(Ue,[max(nT) sz]);
else
    V = V(:);
    U = U(:);
    Ue = Ue(:);
end