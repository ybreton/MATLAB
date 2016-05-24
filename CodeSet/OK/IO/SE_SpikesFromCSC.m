function SE_SpikesFromCSC(fnCSC, varargin)

% SE_SpikesFromCSC(fnCSC, parameters)
%
%   paramaters
%     fnSE = [fnCSC - xtCSC + '.csc2se']
%     filterSpikes = true % if true then filters CSC around each spike with 
%        bandpass FIR filter constructed from FilterOrder, LFCutoff, HFCutoff
%     FilterOrder = 128
%     LFCutoff = 600 % Hertz
%     HFCutoff = 6000 % Hertz
% 
%     Threshold = 50 % currently in microVolts
%     minTweenSpikes = 8; % minimum number of samples between spikes
%     preThresh = 8; % number of samples to include before threshold
%     nSamp = 64; % length of csc to pull out with each spike
%     
%     alignTo = 'peak', 'valley', 'either', 'none' (if empty, then defaults
%     to none).  Defaults to 'either';
%   
%     recordsRange = [] % if empty then do whole CSC.  If not, do range of
%        records.  Good for debugging.
%
%     timestampUnit = 1e-6  % Cheetah marks time in microseconds
% VERSION 2.1

% V1.0 first tests
% V1.1 fixed bug in can only filter from start condition
% V2.0 threshold in uV
% V2.1 added alignto flag


%% Parameters
%     fnSE = [fnCSC - xtCSC + '.csc2se']

filterSpikes = true;
filterOrder = 128;
LFCutoff = 600; % Hertz
HFCutoff = 6000; % Hertz

Threshold = 50; % currently in arbitrary units
minTweenSpikes = 12; 
preThresh = 8; % samples before threshold
nSamp = 64; % sample size
alignSamp = 24;
alignTo = 'either';
     
recordsRange = [];

timestampUnit = 1e-6;

debugDisplay = false;

[fd, fnSE, ~] = fileparts(fnCSC);
fnSE = fullfile(fd, [fnSE '.csc2se']);

process_varargin(varargin);

%% Load 

if isempty(recordsRange)
    [T, Fs, csc, H] = Nlx2MatCSC( fnCSC, [1 0 1 0 1], true, 1, [] );
else
    [T, Fs, csc, H] = Nlx2MatCSC( fnCSC, [1 0 1 0 1], true, 2, recordsRange );
end

assert(all(Fs==mean(Fs)));  % check that data is as expected
Fs = mean(Fs); 
DT = 1./Fs;

% construct time series
t = nan(size(csc));
for iT = 1:length(T)
    t(1:512,iT) = T(iT)*timestampUnit+(1:512)*DT;
end

% reshape to single vector
csc = reshape(csc, numel(csc),1);  
t = reshape(t, numel(t), 1);


%% derivative
% calculate derivative
dcsc = [abs(diff(csc)); nan];

%% find spike times
% find voltage and convert threshold to voltage
s =  H(strncmp('-ADBitVolts ', H, length('-ADBitVolts ')));
uV = sscanf(s{1}, '-ADBitVolts %f')/1e-6;
thorn = Threshold/uV;  % convert to V
fprintf('Using threshold of %.0f uV which is %.0f Nlynx units.\n', Threshold, thorn);

aboveThresh = dcsc > thorn;

spIX = find(aboveThresh(2:end) & ~aboveThresh(1:end-1))-1;

d = [nan; diff(spIX)];
spIX(d<minTweenSpikes) = [];
nSp = length(spIX);
  
%%  Make Filter
if filterSpikes
    LFcutoff = LFCutoff/(1/DT/2);
    HFcutoff = HFCutoff/(1/DT/2);
    F = fir1(filterOrder, [LFcutoff HFcutoff], 'bandpass');
end

%% Make Spike space for filtering
postThresh = nSamp - preThresh - 1;
filtPRE = 4*filterOrder;
filtPOST = 4*filterOrder;

spikeWV = nan(nSp, nSamp);
spikeT = nan(nSp,1);

fprintf('Processing %d spikes...\n', nSp);
for iSp = 1:nSp
    if nSp > 10000 
        if mod(iSp,1000)==0; fprintf('%d', mod(floor(iSp/1000),10)); end
    elseif nSp > 1000 
        if mod(iSp,100)==0;  fprintf('%d', mod(floor(iSp/100),10)); end
    elseif mod(iSp,10)==0;  fprintf('%d', mod(floor(iSp/10),10));
    end
    
    if spIX(iSp) < preThresh % too early to detect        
        continue; 
    elseif spIX(iSp) + nSamp - preThresh > length(csc) % too late to detect
        continue;
    elseif spIX(iSp) < filtPRE % can only filter from start
        [spikeT(iSp), spikeWV(iSp,:)] = prepSpike(1, spIX(iSp)+filtPOST, spIX(iSp));
    elseif spIX(iSp) + filtPOST > length(csc) % can only filter to end
        [spikeT(iSp), spikeWV(iSp,:)] = prepSpike(spIX(iSp)-filtPRE, length(csc), spIX(iSp));
    else % found one
        [spikeT(iSp), spikeWV(iSp,:)] = prepSpike(spIX(iSp)-filtPRE, spIX(iSp)+filtPOST, spIX(iSp));
    end
 end
fprintf('\n');

% clean out the nans
keep = ~isnan(spikeT);
spIX = spIX(keep);
spikeT = spikeT(keep);
spikeWV = spikeWV(keep,:);
nSp = length(spikeT);

%% plotit
if debugDisplay
    clf
    plot(t,csc);
    hold on;
    for iSp = 1:length(spIX)
        plot(spikeT(iSp)+DT*[0:(nSamp-1)],spikeWV(iSp,:) + csc(spIX(iSp)),'r','LineWidth',2);
    end
end

%% Write it

fpSE = fopen(fnSE,'wb');
assert(fpSE ~= -1, 'Could not open %s for writing.', fnSE);
assert(fpSE>0);
fwrite(fpSE, nSp, 'int');
fwrite(fpSE, nSamp, 'int');
for iSp = 1:nSp
    fwrite(fpSE, spikeT(iSp), 'double');
    fwrite(fpSE, spikeWV(iSp,:), 'double');
end
fclose(fpSE);

%------------------------------------------------------------------------
%------------------------------------------------------------------------
%------------------------------------------------------------------------
%------------------------------------------------------------------------
function [spikeT, spikeWV] = prepSpike(filterStart, filterEnd, thornIX)
    % limit CSC to filterStart...filterEnd, filter if necessary
    % find peak in waveform 
    % align to peak
    
    S = csc(filterStart : filterEnd) - csc(thornIX);
    if filterSpikes
        S = filtfilt(F, 1, S); 
    end    
    [peak, peakIX] = max(S(thornIX-filterStart+1 + [-preThresh:postThresh]));
    [valley, valleyIX] = min(S(thornIX-filterStart+1 + [-preThresh:postThresh]));
    switch upper(alginTo)
        case 'PEAK'
            alignIX = peakIX + (thornIX -filterStart+1) - preThresh;
        case 'VALLEY'
            alignIX =  valleyIX + (thornIX -filterStart+1) - preThresh;
        case {'EITHER', 'BOTH'}
            if peak > -valley
                alignIX = peakIX + (thornIX -filterStart+1) - preThresh;
            else
                alignIX =  valleyIX + (thornIX -filterStart+1) - preThresh;
            end
        otherwise
            alignIX = thornIX;
    end
    spikeT = t(filterStart + alignIX - alignSamp);
    spikeWV = S(alignIX - alignSamp + [1:nSamp]);
end

end
