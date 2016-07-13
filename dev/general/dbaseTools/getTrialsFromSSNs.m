function [nTrials,nSubsess] = getTrialsFromSSNs(directories,initFcn)

sz=size(directories);
directories=directories(:);
nTrials = nan(sz);
nSubsess = nan(sz);
disp('Pre-processing...')
h = timedProgressBar('getTrialsFromSSNs',length(directories));
for iSSN=1:length(directories)
    fd0 = directories{iSSN};
    if ~isempty(fd0)
        pushdir(fd0);
        sd = initFcn('addSpikes',false);
        nSubsess(iSSN) = length(sd);
        for iSubsess=1:nSubsess(iSSN)
            sd0 = sd(iSubsess);
            nTrials(iSSN) = max(nTrials(iSSN),numel(sd0.EnteringZoneTime));
        end
        popdir;
    end
    h=h.update();
end
h.close();