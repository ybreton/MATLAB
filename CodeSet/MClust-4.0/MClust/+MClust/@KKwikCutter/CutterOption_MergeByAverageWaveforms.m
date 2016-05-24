function CutterOption_MergeByAverageWaveforms(self)

% CutterOptions_MergeByAverageWaveforms(self)

MCS = MClust.GetSettings();

C0 = self.whoHasFocus;

nClu = length(self.Clusters);
F = figure('Tag', MCS.DeletableFigureTag, 'position',get(0,'screensize'));
nX = ceil(sqrt(nClu));
for iC = 1:nClu
    C1 = self.Clusters{iC};
    MSE = mean((C0.mWV(:)-C1.mWV(:)).^2);
	corr = corrcoef(C0.mWV(:), C1.mWV(:)); corr = corr(1,2);
    subplot(nX, nX, iC);
    plot(C0.xrange, C0.mWV, 'b', C1.xrange, C1.mWV, 'r');
    title(sprintf('%s: corr = %.2f, log MSE=%.2f', C1.name, corr, log(MSE)));
    set(gca, 'XTick', [], 'YTick', [], 'YLim', MCS.AverageWaveform_ylim);
end

names = cellfun(@(x)x.name, self.Clusters, 'UniformOutput', false);
[clustersToMerge, OK] = listdlg('ListString', names, 'PromptString', 'ClustersToMerge');
if OK && ~isempty(clustersToMerge)
    if streq(C0.mergeSet, '--')
        C0.mergeSet = C0.name;
    end
    for iC = 1:length(clustersToMerge)
        self.Clusters{clustersToMerge(iC)}.mergeSet = C0.mergeSet;
        self.Clusters{clustersToMerge(iC)}.keep = C0.keep;
    end
end

delete(F);
self.ReGo();
end
