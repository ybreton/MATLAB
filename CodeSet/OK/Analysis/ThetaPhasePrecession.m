function [precession, meanThetaPhase] = ThetaPhasePrecession(S, cscTheta, varargin)
% ThetaPrecession(sd, csc, varargin)
% 
%
% INPUTS
%   S = set of cells - assumes restricted to (TimeOnTrack, TimeOffTrack)
%   cscTheta = csc with Theta - assumes restricted to (TimeOnTrack, TimeOffTrack)
%
% OUTPUTS
%   precession = difference in mean theta phase aligned to spikes
%   meanThetaPhase = mean spiking phase of theta cycle
% all outputs are aligned to the spikes input
% 
% PARAMETERS
%    p2p = true % align theta to peaks (fissure) or troughs (cell layer)
%    cscSWR = csc to find SW to restrict them out (skips if not provided)
%    windowSWR = +/- window around which to remove spikes, default=0.1s
%    minFreq, maxFreq = frequency limit for Theta cycles (skips if max < min);
%    minThetaDeltaRatio = zscored TD ratio to use (skips if is nan);

minFreq = 5;
maxFreq = 13;
cscSWR = [];
windowSWR = 0.1;
minThetaDeltaRatio = 0;
p2p = true;

sd = [];  % for debugging purposes only

process_varargin(varargin);

%% setup

nCells = length(S);

%% calculate theta markers
[IFtheta, IAtheta, IPtheta, ~] = InstSig_theta(cscTheta);
thetaEdges = ThetaCycleBins(IPtheta, 'p2p', p2p);
nCycles = length(thetaEdges.data);

thetaID = LapTSD(thetaEdges, thetaEdges.data);
thetaID_T = thetaID.range;
thetaID_D = thetaID.data;


%% remove spikes within 100 ms of a sharp wave
if ~isempty(cscSWR)
    [~, IAripple, ~, ~] = InstSig_sharpwaves(cscSWR);
    tSWR = FindSWRTimes(IAripple);
    for iS = 1:length(S)
        S{iS} =S{iS}.remove(tSWR.data-windowSWR, tSWR.data+windowSWR);
    end
end

%% find only good theta cycles
goodCycle = true(size(thetaID_T));

% need to remove rails

% theta/delta ratio
if isnan(minThetaDeltaRatio)
    [~, IAdelta, ~, ~] = InstSig_delta(cscTheta);
    ratioThetaDelta = log(IAtheta.data(thetaEdges.range)./IAdelta.data(thetaEdges.range));
    ratioThetaDelta = (ratioThetaDelta - mean(ratioThetaDelta))/std(ratioThetaDelta);
    goodCycle = goodCycle & ratioThetaDelta > minThetaDeltaRatio;
end

% theta freq OK
if maxFreq > minFreq
    goodCycle = goodCycle & IFtheta.data(thetaEdges) > minFreq & IFtheta.data(thetaEdges) < maxFreq;
end

% clean it up
thetaID_D(~goodCycle) = nan;
thetaID = tsd(thetaID_T, thetaID_D);

%%  calculate precession

meanThetaPhase = cell(nCells,1);
meanThetaTime = cell(nCells,1);
precession = cell(nCells,1);
precessionSpeed = cell(nCells,1);
for iS = 1:length(S)
    meanThetaPhase{iS} = histcn(thetaID.data(S{iS}), 1:nCycles, 'AccumData', IPtheta.data(S{iS}), 'Fun', @circ_mean);
    meanThetaTime{iS} = histcn(thetaID.data(S{iS}), 1:nCycles, 'AccumData', thetaEdges.data(S{iS}), 'Fun', @min);
    keep = meanThetaTime{iS} > 0;
    meanThetaPhase{iS} = tsd(meanThetaTime{iS}(keep), meanThetaPhase{iS}(keep));
    precession{iS} = tsd(meanThetaPhase{iS}.range, [nan; diff(unwrap(meanThetaPhase{iS}.data))]);

    %   precessionSpeed = precession / time between samples - not returned
    %   because not really useful
    precessionSpeed{iS} = tsd(meanThetaPhase{iS}.range, [nan; diff(unwrap(meanThetaPhase{iS}.data))]./[nan; diff(meanThetaTime{iS}(keep))]);
end

end

%====================================
%====================================

%%
%% Load data
% sd = TaskInit;
% csc = LoadCSC(sd.ExpKeys.goodTheta);
% csc = csc.Restrict(sd.ExpKeys.TimeOnTrack, sd.ExpKeys.TimeOffTrack);
% csc = csc.restrict(sd.ExpKeys.TimeOnTrack, sd.ExpKeys.TimeOffTrack);

%=====================================
%%
% for iC = 2:length(sd.S);
% clf; plot(sd.x.data, sd.y.data, '.', 'color', [0.5 0.5 0.5]); hold on
% plot(sd.x.data(sd.S{iC}), sd.y.data(sd.S{iC}), 'k.');
% scatter(sd.x.data(p{iC}.range), sd.y.data(p{iC}.range), 50, m{iC}.data, 'filled');
% title(num2str(iC));
% colorbar
% pause;
% end