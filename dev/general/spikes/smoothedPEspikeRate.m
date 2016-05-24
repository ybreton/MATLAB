function spikeRateFcn = smoothedPEspikeRate(S,t,varargin)
% Produces a smoothed, peri-event spike rate as estimated by
% (mean number of spikes in bin per trial)/(size of bin)
% and smoothed by a Gaussian kernel across entire peri-event window with a
% Gaussian spread of 50ms.
% spikeRateFcn = smoothedPEspikeRate(S,t)
% where         spikeRateFcn            is a tsd of the smoothed spike rate
%
%               S                       is a ts of spike times, or
%                                       is a cell array of ts spike times
%               t                       is a vector of event times for peri-
%                                           event calculation
% OPTIONAL ARGUMENTS:
% window        (default [-2 5])        window for peri-event calculation
% dt            (default 0.01)          bin size for spike rate, in sec
% sigma         (default 50/1000)       width of Gaussian smoother, in sec
%

window = [-2 5];
dt = 0.01;
sigma = 50/1000;
process_varargin(varargin);

if iscell(S)
    idx = (find(cellfun(@(S) isa(S,'ts'), S(:))))';
    nCell = length(idx);
    
    disp(['Processing ' num2str(nCell) ' elements of spike rate cell array.'])
    spikeRateFcn = cell(length(S(:)),1);
    for iC=idx;
        if length(S{iC}.data)>1
            SRt = calculateSR(S{iC},t,window,dt,sigma);
            spikeRateFcn{iC} = SRt;
        else
            warning(['Empty ts of spike times on cell ' num2str(iC)])
        end
    end
    spikeRateFcn = reshape(spikeRateFcn,size(S));
elseif isa(S,'ts')
    spikeRateFcn = calculateSR(S,t,window,dt,sigma);
else
    error('Spike times must be a ts array or cell array of ts.')
end


function SRt = calculateSR(S,t,window,dt,sigma)

peth = spikePETH(S,t,'window',window,'dt',dt);
nSpikes = nan(length(peth.range),length(t));
for iT=1:length(t)
    tPeth = spikePETH(S,t(iT),'window',window,'dt',dt);
    nSpikes(:,iT) = tPeth.data;
end

mSpikes = nanmean(nSpikes,2);
mRt = mSpikes./peth.dt;
Rt = tsd(peth.range,mRt);
SRt = smooth(Rt,sigma,diff(window));