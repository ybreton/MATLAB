function RR_SUM_V1P0 = summarize_restaurant_row(varargin)
% Behavioural summary of restaurant row.
% Produces a table with columns
% 'SESSION NUMBER' 'LAPS COMPLETED' 'TRIAL' 'PROBABILITY' 'DELAY' 'NUMBER OF PELLETS' 'ZONE NUMBER' 'FEEDER ZONE' 'TIME IN' 'TIME LEFT' 'FEEDER ENTRY' 'REWARD DELIVERED' 'VDIFF' 'CUM SKIPS' 'LAST FEEDER TIME'
% for the specified sessions.
%
% OPTIONAL ARGUMENTS:
% timescale = 1e-6              Convert workspace times to seconds.
% ZF = 10                       Zone code for feeder site check.
% SSN = FindFiles('RR-*.mat')   Sessions to analyze.
% C                             Choice point X,Y locations.
% F                             Feeder point X,Y locations.
% window = 2                    Time window for velocity data (secs).
% saveWS = false                Save RR_SUM_V1P0 to workspace.
%
%

timescale = 1e-6;
ZF = 10;
SSN = FindFiles('RR-*.mat');
C = {[398 135],[393 301],[214 291],[222 134]};
F = {[489,60],[484,385],[129,374],[121,54]};
window = 2;
saveWS = false;
process_varargin(varargin);
if ischar(SSN)
    SSN = {SSN};
end

HEADER = {'SESSION NUMBER' 'LAPS COMPLETED' 'TRIAL' 'PROBABILITY' 'DELAY' 'NUMBER OF PELLETS' 'ZONE NUMBER' 'FEEDER ZONE' 'TIME IN' 'TIME LEFT' 'FEEDER ENTRY' 'REWARD DELIVERED' 'VDIFF' 'CUM SKIPS' 'LAST FEEDER TIME' 'TIME SINCE LAST ATE'};
DATA = [];

common = SSN{1};

% Set up projection vectors U,W.
U = zeros(4,2);
W = zeros(4,2);
for z = 1 : 3
    U(z,:) = F{z}-C{z};
    W(z,:) = C{z+1}-C{z};
end
U(4,:) = F{4}-C{4};
W(4,:) = C{1}-C{4};
% Set up unit projections u,w.
nU = zeros(4,1);
nW = zeros(4,1);
for z = 1 : 4
    nU(z) = sqrt(dot(U(z,:),U(z,:)));
    nW(z) = sqrt(dot(W(z,:),W(z,:)));
end
% u is unit projection vector toward current feeder.
% w is unit projection vector toward next zone.
u = U./(repmat(nU,1,2));
w = W./(repmat(nW,1,2));
RowHeader = cell(0,1);
for f = 1 : length(SSN)
    fn = SSN{f};
    common = findCommonPath(common,SSN{f});
    dn = fileparts(fn);
    idx = regexpi(dn,'\');
    RRRRDDMMYYYY = dn(max(idx)+1:end);
    
    pushdir(dn);
    disp(dn);
    Sess = load(fn);
    
    nvtfn = FindFiles('R*-vt*.mat','CheckSubdirs',0);
    if isempty(nvtfn)
        nvt2mat;
        nvtfn = FindFiles('R*-vt*.mat','CheckSubdirs',0);
        nvt=load(nvtfn{1});
    else
        nvt=load(nvtfn{1});
    end
    if isfield(nvt,'Vt')
        x = tsd(nvt.Vt.x.t,nvt.Vt.x.data);
        y = tsd(nvt.Vt.y.t,nvt.Vt.y.data);
    end
    if isfield(nvt,'x')&isfield(nvt,'y')
        x = tsd(nvt.x.range,nvt.x.data);
        y = tsd(nvt.y.range,nvt.y.data);
    end
    
    if ~isfield(Sess,'ZoneDelay')
        Sess.ZoneDelay = ones(length(Sess.ZoneIn),1);
    else
        if length(Sess.ZoneDelay)<length(Sess.ZoneIn)
            ZoneDelay = nan(length(Sess.ZoneIn),1);
            k = 0;
            for r = 1 : length(Sess.ZoneIn)
                if Sess.ZoneIn(r)>ZF
                    ZoneDelay(r) = Sess.ZoneDelay(k);
                else
                    k = k+1;
                    ZoneDelay(r) = Sess.ZoneDelay(k);
                end 
            end
            Sess.ZoneDelay = ZoneDelay;
        end
        
    end
    if ~isfield(Sess,'ZoneProbability')
        Sess.ZoneProbability = ones(length(Sess.ZoneIn),1);
    end
    if ~isfield(Sess,'FireFeeder')
        Sess.FireFeeder = true(length(Sess.ZoneIn),1);
    end
    if ~isfield(Sess,'nPelletsPerDrop')
        Sess.nPelletsPerDrop = Sess.nPellets;
        if isfield(Sess,'nPelletsHigh') & isfield(Sess,'feederHigh')
            Sess.nPelletsPerDrop = ones(1,4)*Sess.nPellets;
            Sess.nPelletsPerDrop(Sess.feederHigh) = Sess.nPelletsHigh;
        end
    end
    if isfield(Sess,'nPelletsPerDrop')
        if numel(Sess.nPelletsPerDrop)==1
            Sess.nPelletsPerDrop = repmat(Sess.nPelletsPerDrop,4,1);
        end
        if numel(Sess.nPelletsPerDrop)<=length(Sess.ZoneIn)
            Sess.nPelletsPerDrop = repmat(Sess.nPelletsPerDrop(:),ceil(length(Sess.ZoneIn)/4),1);
        end
    end
    if all(Sess.FireFeeder)
        Sess.FireFeeder = true(4,length(Sess.ZoneIn));
    end
    lap = -1;
    sessDat = nan(length(Sess.ZoneIn),length(HEADER));
    lastAct = nan;
    LFT = nan;
    CumSkips = 0;
    FeederK = 0;
    NoFeederZone = all(Sess.ZoneIn<ZF);
    for t = 1 : length(Sess.ZoneIn)
        if Sess.ZoneIn(t)==1
            lap = lap+1;
        end
        
        
        ZN = mod(Sess.ZoneIn(t),ZF);
        ZP = Sess.ZoneProbability(t);
        ZD = Sess.ZoneDelay(t);
        NP = Sess.nPelletsPerDrop(t);
        FZ = Sess.ZoneIn(t)>=ZF;
        Tin = Sess.EnteringZoneTime(t)*timescale;
        try
            if Sess.ZoneIn(t+1)<ZF
                % Next zone is not feeder
                Tout = Sess.EnteringZoneTime(t+1)*timescale;
            else
                % Next zone is feeder
                Tout = Sess.EnteringZoneTime(t+2)*timescale;
            end
        catch exception
            % There is no t+1, or t+2.
            lastPosTime = max(x.range);
            lastPelletTime = max(Sess.FeederTimes*timescale);
            
            Tout = min([Sess.EnteringZoneTime(t)*timescale lastPosTime lastPelletTime]);
        end
        if t<length(Sess.ZoneIn)
            NextZone = Sess.ZoneIn(t+1);
        end
        % Skip: did not wait for duration of delay or did not enter the feeder zone.
        % Entry: neither of those things.
        Tspent = Tout-Tin;
        FeederTry = (NextZone>=ZF&&Sess.ZoneIn(t)<ZF) || Sess.ZoneIn(t)>=ZF;
        Waited = Tspent>=ZD;
        if all(Sess.ZoneDelay==0) && any(Sess.ZoneProbability~=1)
            % there is no delay.
            Entry = FeederTry;
        elseif any(Sess.ZoneDelay~=0) && all(Sess.ZoneProbability==1)
            % there is no risk.
            Entry = Waited;
        else
            % there is both risk and delay.
            Entry = Waited & FeederTry;
        end
        
        
        % Reward: Entered and feeder fired.
        Rew = Entry & Sess.FireFeeder(ZN,lap+1);
        
        % Vdiff, defined only if not at feeder site.
        if ~FZ & (Tin+window)>min(x.range) & Tin<max(x.range)
            xt = x.restrict(Tin,Tin+window);
            yt = y.restrict(Tin,Tin+window);
            time = sort(xt.range);
            d = xt.data;
            xt = tsd(time,d);
            time = sort(yt.range);
            d = yt.data;
            yt = tsd(time,d);
            if length(d(~isnan(d)))>1
                dx = dxdt(xt);
                dy = dxdt(yt);
                V = tsd(dx.range,[dx.data dy.data]);
                Vdiff0 = nan(length(V.D),1);
                for timestamp = 1 : length(V.D)
                    Vdiff0(timestamp) = dot(V.D(timestamp,:),u(ZN,:))-dot(V.D(timestamp,:),w(ZN,:));
                end
                Vdiff = nanmean(Vdiff0);
            else
                Vdiff = nan;
            end
        else
            Vdiff = nan;
        end
        
        % Cumulative skips:
        if isnan(lastAct) || lastAct == 1
            CumSkips = 0;
        else
            CumSkips = CumSkips + 1;
        end
        lastAct = Entry;
        
        % Last Feeder Fire time:
        idPreNow = Sess.FeederTimes*timescale<=Tin;
        LFT = max(Sess.FeederTimes(idPreNow))*timescale;
        if isempty(LFT)
            LFT = nan;
        end
        
        TimeSinceLastAte = Tin-LFT;
        
        sessDat(t,1) = f;
        sessDat(t,2) = lap;
        sessDat(t,3) = t;
        sessDat(t,4) = ZP;
        sessDat(t,5) = ZD;
        sessDat(t,6) = NP;
        sessDat(t,7) = ZN;
        sessDat(t,8) = FZ;
        sessDat(t,9) = Tin;
        sessDat(t,10) = Tout;
        sessDat(t,11) = Entry;
        sessDat(t,12) = Rew;
        
        sessDat(t,13) = Vdiff;
        sessDat(t,14) = CumSkips;
        sessDat(t,15) = LFT;
        sessDat(t,16) = TimeSinceLastAte;
        rowDat{t,1} = RRRRDDMMYYYY;
    end
    
    popdir;
    DATA = [DATA;
        sessDat];
    RowHeader = vertcat(RowHeader,rowDat);
    clear sessDat rowDat
end

commonDir = fileparts(common);
curDir = cd;

RR_SUM_V1P0.NAME = commonDir;
RR_SUM_V1P0.HEADER.Col = HEADER;
RR_SUM_V1P0.HEADER.Row = RowHeader;
RR_SUM_V1P0.DATA = DATA;
RR_SUM_V1P0.SSN = SSN;
RR_SUM_V1P0.window = window;

if saveWS | nargout < 1
    cd(commonDir)
    save('RR_SUM_V1P0.mat','RR_SUM_V1P0')
    cd(curDir)
end

function common = findCommonPath(A,B)

Aparts = unique([0 regexpi(A,'\') length(A)]);
Bparts = unique([0 regexpi(B,'\') length(B)]);
common = '';
for part = 1 : min(length(Aparts),length(Bparts))-1
    Astr = A(Aparts(part)+1:Aparts(part+1));
    Bstr = B(Bparts(part)+1:Bparts(part+1));
    if strcmpi(Astr,Bstr)
        % Astr and Bstr match.
        common = [common Astr];
    end
end