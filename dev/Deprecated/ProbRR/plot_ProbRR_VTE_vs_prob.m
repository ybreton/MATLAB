function fh = plot_ProbRR_VTE_vs_prob(VTE,thresh)
% Produces a histogram of all IdPhi values, the Log[IdPhi] as a function of
% probability of reinforcement, and the proportion of IdPhi values above a
% critical threshold thresh.
%
%
%

fh = gcf;

overalldat = [];
for f = 1 : length(VTE)
    overalldat = [overalldat; VTE(f).DATA];
end
idEx = overalldat(:,6)<=0;
overalldat(idEx,:) = [];

subplot(2,2,3)
title(sprintf('I d\\phi - Prob correlation'))
hold on
plot(overalldat(:,2),log10(overalldat(:,6)),'k.','markersize',16)
xlabel(sprintf('Probability of Reinforcement'))
ylabel(sprintf('Log_{10} [I d\\phi]'))
set(gca,'xlim',[-0.05 1.05])
hold off

subplot(2,2,4)
title(sprintf('Proportion High [I d\\phi] - Prob correlation'))
hold on
uniqueProbs = unique(overalldat(:,2));
for p = 1 : length(uniqueProbs)
    id = overalldat(:,2)==uniqueProbs(p);
    pdat = overalldat(id,:);
    id2 = log10(pdat(:,6))>thresh;
    y = sum(double(id2))/size(pdat,1);
    plot(uniqueProbs(p),y,'k.','markersize',16)
end
xlabel(sprintf('Probability of Reinforcement'))
ylabel(sprintf('Proportion Log_{10} [I d\\phi] > %.1f',thresh))

set(gca,'xlim',[-0.05 1.05])
hold off

subplot(2,1,1)
hold on
hist(log10(overalldat(:,6)),ceil(sqrt(size(overalldat,1))))
xlabel(sprintf('Log_{10} [I d\\phi]'))
ylabel('Number of passes')
hold off