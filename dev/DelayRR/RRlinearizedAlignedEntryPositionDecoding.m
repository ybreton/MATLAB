function [m,bins,Angles] = RRlinearizedAlignedEntryPositionDecoding(trials,sd,B,varargin)
% Returns mean decoded probability of each location, linearized by angular
% distance to zone entry, within a time window of zone entry, for each
% trial.
% 
% [m,bins,Angles] = RRlinearizedAlignedEntryPositionDecoding(laps,sd,B)
% where     m       is nBins x nTrials matrix of mean decoded probability
%                       in each bin of angular distance from zone entry for
%                       each trial.
%           bins    is nBins x nTrials matrix of angular distance from zone
%                       entry values.
%           Angles  is a structure with fields
%               .nextZone
%               .prevZone
%               .oppZone
%                       providing information about angular distance to
%                       next, previous, and opposite zones, respectively.
%
%           trials  is a nTrials vector of trial numbers to extract,
%           sd      is a standard session data structure array to use,
%           B       is a structure array produced by bayesian decoding.
%
% if trials is empty, will do the angular-distance linearized, aligned,
% mean decoded probability for each trial.
%
% OPTIONAL ARGUMENTS:
% ******************
% window    (default 1)     is the time window within which to average
%                               decoding
% nBins     (default 64)    is the number of angular distance bins to use
% nZones    (default 4)     is the number of zones
% x         (default sd.x)  is a tsd of x positions to use,
% y         (default sd.y)  is a tsd of y positions to use,
% t         (default sd.EnteringCPTime)
%                           is a vector of time stamps with which to begin
%                           the decoding window,
% exclTimes (default empty) is a vector of time stamps to exclude.
%

window=1;
nBins = 64;
nZones = 4;
x = sd.x;
y = sd.y;
t = sd.EnteringCPTime;
exclTimes = [];
process_varargin(varargin);
if isempty(trials)
    trials = 1:length(t);
end

nTrials = length(trials);

xBins = linspace(B.min(1),B.max(1),B.nBin(1));
yBins = linspace(B.min(2),B.max(2),B.nBin(2));
xCentre = mean(xBins);
yCentre = mean(yBins);
centre = [xCentre;yCentre];

EntryXY = nan(2,nZones);
for iZ=1:nZones
    idx = sd.ZoneIn==iZ;
    xEntry = x.data(sd.EnteringCPTime(idx));
    yEntry = y.data(sd.EnteringCPTime(idx));
    EntryXY(:,iZ) = [nanmedian(xEntry); nanmedian(yEntry)];
end

curZone = 1:nZones;
lastZone = [curZone(end) curZone(1:end-1)];
nextZone = [curZone(2:end) curZone(1)];
oppZone = [curZone(3:end) curZone(1:2)];
angNext = nan(4,1);
angPrev = nan(4,1);
angOpp = nan(4,1);
for iZ=1:4
    A = EntryXY(:,iZ);
    N = EntryXY(:,nextZone(iZ));
    L = EntryXY(:,lastZone(iZ));
    O = EntryXY(:,oppZone(iZ));
    angNext(iZ) = angularDistance(A-centre,N(1)-centre(1),N(2)-centre(2));
    angPrev(iZ) = angularDistance(A-centre,L(1)-centre(1),L(2)-centre(2));
    angOpp(iZ) = angularDistance(A-centre,O(1)-centre(1),O(2)-centre(2));
end

angNext = nanmean(zero2twoPiAngle(angNext));
angPrev = nanmean(zero2twoPiAngle(angPrev));
angOpp = nanmean(zero2twoPiAngle(angOpp));
angNext = negPi2PiAngle(angNext);
angPrev = negPi2PiAngle(angPrev);
angOpp = negPi2PiAngle(angOpp);

%%
m = nan(nBins,nTrials);
bins = nan(nBins,nTrials);
for iTrl = 1 : nTrials
    lapNum = trials(iTrl);
    [m(:,iTrl),bins(:,iTrl)] = RRavgDecodeAngle(B,x,y,t(lapNum),window,'exclTimes',exclTimes);
end
Angles.nextZone = angNext;
Angles.prevZone = angPrev;
Angles.oppZone = angOpp;