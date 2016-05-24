function [fh,fh2,fh3]=plot_ProbRR_VTE_hists(VTE)
% produces 3 figures,   one of the log(IdPhi) across all passes,
%                       one of the log(IdPhi) for entered passes,
%                       one of the log(IdPhi) for skipped passes.
%
%
%

overalldat = [];
for f = 1 : length(VTE)
    overalldat = [overalldat; VTE(f).DATA];
end
idEx = overalldat(:,6)<=0;
overalldat(idEx,:) = [];

uniqueP = unique(overalldat(:,2));
nrows = ceil(sqrt(length(uniqueP)));
ncols = ceil(length(uniqueP)/nrows);

fh = gcf;
clf
for p = 1 : length(uniqueP)
    probability = uniqueP(p);
    id = overalldat(:,2)==probability;
    subplot(nrows,ncols,p)
    hold on
    title(sprintf('All passes,\nP=%.1f',probability))
    hist(log10(overalldat(id,6)),ceil(sqrt(size(overalldat(id,:),1))))
    hold off
    set(gca,'xlim',[1 3.5])
end

fh2 = figure;
clf
entrydat = overalldat(overalldat(:,4)==1,:);
for p = 1 : length(uniqueP)
    probability = uniqueP(p);
    id = entrydat(:,2)==probability;
    subplot(nrows,ncols,p)
    hold on
    title(sprintf('Entered Passes,\nP=%.1f',probability))
    hist(log10(entrydat(id,6)),ceil(sqrt(size(entrydat(id,:),1))))
    hold off
    set(gca,'xlim',[1 3.5])
end

fh3 = figure;
clf
skipdat = overalldat(overalldat(:,5)==1,:);
for p = 1 : length(uniqueP)
    probability = uniqueP(p);
    id = skipdat(:,2)==probability;
    subplot(nrows,ncols,p)
    hold on
    title(sprintf('Skipped Passes,\nP=%.1f',probability))
    hist(log10(skipdat(id,6)),ceil(sqrt(size(entrydat(id,:),1))))
    hold off
    set(gca,'xlim',[1 3.5])
end