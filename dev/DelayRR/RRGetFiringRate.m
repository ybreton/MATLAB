function sd = RRGetFiringRate(sd)
% Adds fields
% .mISI
% .ByTarget.mISI
% to sd, with mean inter-spike intervals in sd.S and sd.ByTarget.S, and
% .nSpikes
% .ByTarget.nSpikes
% with number of spikes fired.
%
%
%

sd = RRassignSpikesToTargets(sd);

sd.ByTarget.mISI = nan(size(sd.ByTarget.S));
sd.ByTarget.nSpikes = nan(size(sd.ByTarget.S));
for iC=1:size(sd.ByTarget.S,2)
    for iR=1:sd.ByTarget.nCells(iC)
        S = sd.ByTarget.S{iR,iC};
        isi = diff(S.data);
        m = nanmean(isi);
        
        sd.ByTarget.mISI(iR,iC) = m;
        sd.ByTarget.nSpikes(iR,iC) = length(S.data);
    end
end

sd.mISI = nan(size(sd.S));
sd.nSpikes = nan(size(sd.S));
for iR=1:length(sd.S)
    S = sd.S{iR};
    isi = diff(S.data);
    m = nanmean(isi);
    sd.mISI(iR) = m;
    sd.nSpikes(iR) = length(S.data);
end