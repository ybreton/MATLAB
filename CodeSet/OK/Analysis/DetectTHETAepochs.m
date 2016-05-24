function [T]=DetectTHETAepochs(sd,CSC,T,varargin)
% 2012-05-16 AndyP
% Detects theta epochs based on the theta/delta power ratio.
%
% [T]=DetectTHETAepochs(sd,CSC,T,varargin);
%
% INPUTS
%
% sd - structure, lab-standard 'session data' structure containing fields
% pertaining to one session
% CSC -  tsd input with units (A.U. by [s]) from a continuously sampled channel (CSC) 
% 
% OUTPUTS
%
% T   - structure with 8 fields
%      1.  CSC - tsd (range [s] data [A.U.]) filtered CSC
%      2.  TDratio - theta-to-delta ratio for each timestep [s] of the CSC
%      3.  Indx - index of tStart for each timestep [s] of the CSC (i.e. if
%      tStart is a 100x1 double with one timestamp to denote the beginning
%      of each lap, then Indx returns the lap on which each timestep was recorded [1 1 1, 2 2 2 2, 3 3, ..., 99 99, 100 100 100 100]);
%      4.  TDratio_cutoff - TDratio < TDratio_cutoff are nan'ned out 
%      5.  Trange - 1x2 double theta filter frequencies [Hz]  
%      6.  Drange - 1x2 double delta filter frequencies [Hz]  
%      7.  EMGrange - 1x2 double EMG filter frequencies [Hz]  
%      8.  FiltOrder
%
% VARARGIN OPTIONS
%   FiltOrder 1x1 double   order of FIR filter
%   Trange 1x2 double      double theta filter frequencies [Hz] 
%   Drange 1x2 double      delta filter frequencies [Hz]  
%   EMGrange 1x2 double    double EMG filter frequencies [Hz]  
%   TDcutoff 1x1 double    TDratio < TDratio_cutoff are nan'ned out 
%   maxTDratio 1x1 double  nan out TDratio below threshold (not in theta)
%   maxEMG 1x1 double      nan out TDratio below threshold (noisy EMG in CSC data)   
%   tStart Nx1, tStop Nx1,  where N is a list of times in [s] in ascending numerical order
%   mask 1x1 binary,  if 'true' timestamps outside of tStart and tStop are nan'ned out

FiltOrder  = 256; % order of FIR filter
Trange = [6 10]; % [Hz] theta [low high] bandpass. 
Drange = [2 5];  % [Hz] delta [low high] bandpass. 
EMGrange=[180 400]; % [Hz] EMG [low high] bandpass. 
TDcutoff = 4; % Theta/Delta < TDcutoff are nan'ned out
maxTDratio=2E5; % Theta/Delta > maxTDratio are nan'ned out
maxEMG=2E5; % if EMG power > maxEMG, Theta/Delta at this timestamp are nan'ned out
cutoff=0.99; % filtered CSC data > cutoff*max(CSC) are nan'ned out
tStart=sd.EnteringCPTime; % list of starting times [s] to restrict CSC
tStop=sd.EnteringZoneTime; % list of ending times [s] to restrict CSC 
mask=1;
process_varargin(varargin);

%%%%%%%%%%
% checks %
%%%%%%%%%%
if nargin>=3 && ~isempty(nargin(3));
assert(all(Trange==T.Trange),'Trange mismatch');
assert(FiltOrder==T.FiltOrder,'FiltOrder mismatch');
end
assert(isa(CSC,'tsd'),'second input CSC must be a tsd object');
assert(all((tStop-tStart)>0),'there are negative times in the tStart/tStop timestamps');
assert(1/CSC.dt/FiltOrder < 5,'must downsample CSC and/or increase filter order to discriminate theta from delta'); 
assert(EMGrange(1)>150,'EMG low frequency cutoff is too low');
%------------------
CSC=CSC.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack); %restrict to time on track

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate power at each band %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EMGrange=[EMGrange(1), min(floor(1/CSC.dt()/2),EMGrange(2))];
nT = CSC.range;
CSC1 = CSC.data;
CSC1(CSC1>=cutoff.*max(CSC1))=nan;
CSC1(CSC1<=cutoff.*min(CSC1))=nan;
[~, Th]=InstSig(CSC,Trange(1),Trange(2),FiltOrder); % theta instantaneous amplitude (power)
[~, D]=InstSig(CSC,Drange(1),Drange(2),FiltOrder); % delta instantaneous amplitude (power)
[~, EMG]=InstSig(CSC,EMGrange(1),EMGrange(2),FiltOrder); % EMG instantaneous amplitude (power)

TDratio = Th.data./D.data; %compute theta/delta ratio

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   nan-out unwanted timestamps  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TDratio(isnan(CSC1))=nan; % nan out CSC above threshold
TDratio(EMG.data>maxEMG)=nan; % nan out EMG above threshold
TDratio(TDratio<TDcutoff | TDratio>maxTDratio)=nan; % nan out TDratio below (not in theta) or above (noise) threshold
CSC1(isnan(TDratio))=nan;
CSC1 = tsd(nT,CSC1);
if mask
CSC1 = CSC1.mask(tStart,tStop,0);
[~,~,~,Indx]=histcn(CSC1.range,tStart); % sort CSC1 by tStart
else
	Indx = []; %#ok<UNRCH>
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  construct output structure %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T.CSC=CSC1;
T.TDratio=TDratio;
T.Indx=Indx;
T.TDratio_cutoff=TDcutoff;
T.Trange=[Trange(1) Trange(2)];
T.Drange=[Drange(1) Drange(2)];
T.EMGrange=[EMGrange(1) EMGrange(2)];
T.FiltOrder=FiltOrder;
end