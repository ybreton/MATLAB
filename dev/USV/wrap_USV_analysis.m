function [AllRegretUSV,AllNoRegretUSV,AllSkipUSV,AllStayUSV] = wrap_USV_analysis(varargin)

fd = pwd;
fField = 'FreqDiff';
pField = 'PowerDiff';
ToneDuration = 0.1;
Window = 0.6;
process_varargin(varargin);

compile_regret_usv('fd',fd,'window',Window)
filter='*-regretUSV.mat';
AllRegretUSV = wrap_USV_condition_analysis(filter,'regretUSV',fField,pField,'fd',fd,'ToneDuration',ToneDuration,'Window',Window);

filter = '*-noregretUSV.mat';
AllNoRegretUSV = wrap_USV_condition_analysis(filter,'noregretUSV',fField,pField,'fd',fd,'ToneDuration',ToneDuration,'Window',Window);

compile_rejoice_usv('fd',fd,'window',Window,'multiplier',1e-6)
filter='*-rejoiceUSV.mat';
AllRegretUSV = wrap_USV_condition_analysis(filter,'rejoiceUSV',fField,pField,'fd',fd,'ToneDuration',ToneDuration,'Window',Window);

filter = '*-norejoiceUSV.mat';
AllNoRegretUSV = wrap_USV_condition_analysis(filter,'norejoiceUSV',fField,pField,'fd',fd,'ToneDuration',ToneDuration,'Window',Window);

compile_stayskip_usv('fd',fd,'window',Window)
filter = '*-skipUSV.mat';
AllSkipUSV = wrap_USV_condition_analysis(filter,'skipUSV',fField,pField,'fd',fd,'ToneDuration',ToneDuration,'Window',Window);

filter = '*-stayUSV.mat';
AllStayUSV = wrap_USV_condition_analysis(filter,'stayUSV',fField,pField,'fd',fd,'ToneDuration',ToneDuration,'Window',Window);

plot_USV_crosscorrel(AllRegretUSV.F(1,:),AllRegretUSV.D);
set(get(gca,'title'),'string',sprintf('Regret\n(%.1fs to %.1fs)',ToneDuration,Window))
plot_USV_crosscorrel(AllNoRegretUSV.F(1,:),AllNoRegretUSV.D)
set(get(gca,'title'),'string',sprintf('No Regret\n(%.1fs to %.1fs)',ToneDuration,Window))
Rmat_regret = corrcoef(AllRegretUSV.D,'rows','pairwise');
Rmat_noregret = corrcoef(AllNoRegretUSV.D,'rows','pairwise');
imagesc(AllRegretUSV.F(1,:),AllRegretUSV.F(1,:),Rmat_regret-Rmat_noregret)
colorbar
caxis([-1 1])
title('Regret correlation - No Regret correlation')
% baseline = repmat(mean(AllNoRegretUSV.D),size(AllRegretUSV.D,1),1);
% plot_USV_crosscorrel(AllRegretUSV.F(1,:),AllRegretUSV.D,'baseline',baseline)
% set(get(gca,'title'),'string',sprintf('Regret - Mean No Regret\n(Power from 0.1 to the end - Power from 0 to 0.1s)'))
% 
% baseline = repmat(mean(AllRegretUSV.D),size(AllNoRegretUSV.D,1),1);
% plot_USV_crosscorrel(AllNoRegretUSV.F(1,:),AllNoRegretUSV.D,'baseline',baseline)
% set(get(gca,'title'),'string',sprintf('No Regret - Mean Regret\n(Power from 0.1 to the end - Power from 0 to 0.1s)'))

plot_USV_crosscorrel(AllSkipUSV.F(1,:),AllSkipUSV.D)
set(get(gca,'title'),'string',sprintf('Skips\n(%.1fs to %.1fs)',ToneDuration,Window))
plot_USV_crosscorrel(AllStayUSV.F(1,:),AllStayUSV.D)
set(get(gca,'title'),'string',sprintf('Stay\n(%.1fs to %.1fs)',ToneDuration,Window))

Rmat_skip = corrcoef(AllSkipUSV.D,'rows','pairwise');
Rmat_stay = corrcoef(AllStayUSV.D,'rows','pairwise');
imagesc(AllSkipUSV.F(1,:),AllSkipUSV.F(1,:),Rmat_skip-Rmat_stay)
colorbar
caxis([-1 1])
title('Skip correlation - Stay correlation')
% baseline = repmat(mean(AllStayUSV.D),size(AllSkipUSV.D,1),1);
% plot_USV_crosscorrel(AllSkipUSV.F(1,:),AllSkipUSV.D,'baseline',baseline)
% set(get(gca,'title'),'string',sprintf('Skip - Mean Stay\n(Power from 0.1 to the end - Power from 0 to 0.1s)'))
% 
% baseline = repmat(mean(AllSkipUSV.D),size(AllStayUSV.D,1),1);
% plot_USV_crosscorrel(AllStayUSV.F(1,:),AllStayUSV.D,'baseline',baseline)
% set(get(gca,'title'),'string',sprintf('Stay - Mean Skip\n(Power from 0.1 to the end - Power from 0 to 0.1s)'))

compile_spectrograms;