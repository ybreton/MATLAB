function GCobj = wrap_timeGC_analysis(CSCs,t0,window,varargin)
% Wrapper to perform the MVGC multivariate Granger Causality calculations
% on time domain data.
% Requires the MVGC toolbox.
% GCobj = wrap_GC_analysis(CSCs,t0,window)
% where     GCobj            is a Granger Causality analysis structure with fields
%                .params     parameters in use for the analysis (see optional arguments below)
%                .window     time window for each trial (window input argument)
%                .trialTimes list of trial start times (t0 input argument)
%                .fs         sampling frequency (1/dT)
%                .T          time stamps window(1):dT:window(2)
%                .nvars      number of variables (length of CSCs cell array)
%                .nobs       number of observations (length of T)
%                .ntrials    number of trials (length of t0)
%                .X          nvars x nobs x ntrials matrix of signal values.
%`               .AIC        Akaike Information Criterion for model
%                .BIC        Bayesian Information Criterion for model
%                .moAIC      model order of AIC-best model
%                .moBIC      model order of BIC-best model
%                .morder     model order used for GC analysis
%                .VAR        nvars x nvars x nlags matrix of VAR
%                               coefficients, where VAR(i,j,k) is the VAR
%                               coefficient TO signal i FROM signal j at
%                               lag k
%                .SIG        nvars x nvars symmetrical matrix of covariance
%                               of residuals
%                .AutoCovSeq nvars x nvars x nlags matrix of autocovariances 
%                               where AutoCovSeq(i,j,k) is the
%                               autocovariance TO signal i FROM signal j at
%                               lag k-1
%                .AutoCovInfo Information about the autocovariance sequence
%                               analysis
%                .TimePairwiseConditionalGC
%                            nvars x nvars matrix of time-domain Granger
%                            Causalities for pairwise-conditional GC
%                            analysis, where TimePairwiseConditionalGC(i,j)
%                            is the causality of signal j TO signal i.
%                .pval       p-value of the GC values
%                .sig        significance of the p-value after correcting
%                               for multiple comparisons
%
%       CSCs                 is a cell array of continuously-sampled
%                               channel tsd's; one for each signal source
%       t0                   is a vector of start times for each trial
%       window               is a [tStart tEnd] vector of the window to
%                               consider for each trial, or a [0 window]
%                               scalar of the extent of the trial to
%                               consider from trial start
%
% OPTIONAL ARGUMENTS:
% ******************
%
% plotFlag  (default true)
%   specifies whether to plot 2 figures (true to plot, false to skip):
%   - the AIC/BIC values as a function of time lag (model order)
%   - the GC matrix, p-values for the GC values, and their significance
%
% These arguments will be saved in GCobj object under the "params" field.
%
% morder    (default 'AIC')  
%   model order to use ('AIC', 'BIC' or supplied numerical value)
% momax     (default 20)     
%   maximum model order for model order estimation
% regmode   (default 'OLS')  
%   VAR model estimation regression mode ('OLS' or 'LWR')
% icregmode (default 'LWR')  
%   information criteria regression mode ('LWR' or 'OLS')
% acmaxlags (default [])
%   maximum autocovariance lags (empty for automatic calculation)
% tstat     (default 'F')     
%   statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
% alpha     (default 0.05)   
%   significance level for significance test
% mhtc      (default 'FDR')  
%   multiple hypothesis test correction (see routine 'significance')
%
% The following will be saved in GCobj object as their own field.
%
% names     (default {'Signal1', 'Signal2', ...})
%   names of each CSC signal.
% dT        (default 0.002)
%   time step interval within window
%
%

plotFlag  = true;   % plot the figures.

morder    = 'AIC';  % model order to use ('AIC', 'BIC' or supplied numerical value)
momax     = 20;     % maximum model order for model order estimation
regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)
acmaxlags = [];     % maximum autocovariance lags (empty for automatic calculation)
tstat     = 'F';     % statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
alpha     = 0.05;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')

names = cell(length(CSCs),1); % signal names
for iCSC=1:length(names)
    names{iCSC} = sprintf('Signal%d',iCSC);
end

dT = 0.002;

process_varargin(varargin);

GCobj.names = names;
GCobj.params.morder = morder;
GCobj.params.momax = momax;
GCobj.params.regmode = regmode;
GCobj.params.icregmod = icregmode;
GCobj.params.acmaxlags = acmaxlags;
GCobj.params.tstat = tstat;
GCobj.params.alpha = alpha;
GCobj.params.mhtc = mhtc;

if numel(window)==1
    window = sort([0 window]);
end
GCobj.window = window;
GCobj.trialTimes = t0(:);
disp(['Running GC analysis on ' num2str(length(CSCs)) ' CSCs for ' num2str(length(GCobj.trialTimes(:))) ' trials.']);

GCobj.dT = dT;
GCobj.fs = 1/GCobj.dT;
GCobj.T = window(1):GCobj.dT:window(2);

GCobj.nvars = length(CSCs);
GCobj.nobs = length(GCobj.T);
GCobj.ntrials = length(GCobj.trialTimes);

GCobj.X = arrangeCSCbyTrial(CSCs,GCobj.T,t0);

disp('Calculating information criteria and model orders...')
[GCobj.AIC,GCobj.BIC,GCobj.moAIC,GCobj.moBIC] = tsdata_to_infocrit(GCobj.X,momax,icregmode);

if plotFlag
    figure(1); clf;
    plot_tsdata([GCobj.AIC GCobj.BIC]',{'AIC','BIC'},1/GCobj.fs);
    title('Model order estimation');
    drawnow
end

if strcmpi(morder,'AIC')
    morder = GCobj.moAIC;
    fprintf('\nusing AIC best model order = %d\n',morder);
elseif strcmpi(morder,'BIC')
    morder = GCobj.moBIC;
    fprintf('\nusing BIC best model order = %d\n',morder);
else
    fprintf('\nusing specified model order = %d\n',morder);
end

bombed=true;
while bombed && morder>0
    disp(['Model Order ' num2str(morder)])
    disp('Calculating VAR coefficients...')
    [GCobj.VAR,GCobj.SIG] = tsdata_to_var(GCobj.X,morder,regmode);
    assert(~isbad(GCobj.VAR),'VAR estimation failed');

    disp('Calculating autocovariance sequence...')
    [GCobj.AutoCovSeq,GCobj.AutoCovInfo] = var_to_autocov(GCobj.VAR,GCobj.SIG,acmaxlags);
    if GCobj.AutoCovInfo.error~=0
        bombed=true;
        morder=morder-1;
        disp(GCobj.AutoCovInfo.errmsg)
    else
        bombed=false;
    end
end
GCobj.morder = morder;
var_info(GCobj.AutoCovInfo,true); % report results (and bail out on error)

disp('Calculating time-domain pairwise-conditional Granger causalities...')
GCobj.TimePairwiseConditionalGC = autocov_to_pwcgc(GCobj.AutoCovSeq);
assert(~isbad(GCobj.TimePairwiseConditionalGC,false),'GC calculation failed');

disp('Testing Granger causality null hypotheses...')
GCobj.pval = mvgc_pval(GCobj.TimePairwiseConditionalGC,morder,GCobj.nobs,GCobj.ntrials,1,1,GCobj.nvars-2,tstat); % take careful note of arguments!
GCobj.sig  = significance(GCobj.pval,alpha,mhtc);

for iName=1:length(names)
    GCobj.to.(names{iName}) = false(size(GCobj.TimePairwiseConditionalGC));
    GCobj.to.(names{iName})(iName,:) = true;
    GCobj.from.(names{iName}) = false(size(GCobj.TimePairwiseConditionalGC));
    GCobj.from.(names{iName})(:,iName) = true;
end

if plotFlag
    figure(2); clf;
    subplot(1,3,1);
    set(gca,'fontsize',12)
    plot_pw(GCobj.TimePairwiseConditionalGC);
    for iName=1:length(names)
        text(iName,iName,names{iName},'VerticalAlignment','middle','HorizontalAlignment','center','rotation',45,'fontsize',10)
    end
    set(gca,'xticklabel',[])
    set(gca,'yticklabel',[])
    colorbar
    title('Pairwise-conditional GC');
    subplot(1,3,2);
    set(gca,'fontsize',12)
    plot_pw(GCobj.pval);
    for iName=1:length(names)
        text(iName,iName,names{iName},'VerticalAlignment','middle','HorizontalAlignment','center','rotation',45,'fontsize',10)
    end
    set(gca,'xticklabel',[])
    set(gca,'yticklabel',[])
    colorbar;
    caxis([0 min(0.05,max(caxis))])
    title('p-values');
    subplot(1,3,3);
    set(gca,'fontsize',12)
    plot_pw(GCobj.sig);
    set(gca,'xticklabel',[])
    set(gca,'yticklabel',[])
    cbh=colorbar;
    set(cbh,'ytick',[0 1])
    set(cbh,'yticklabel',{'ns' ['p < ' num2str(alpha)]})
    for iName=1:length(names)
        text(iName,iName,names{iName},'VerticalAlignment','middle','HorizontalAlignment','center','rotation',45,'fontsize',10)
    end
    title('Significance')
    drawnow
end

GCobj.SethCausalDensity = nanmean(GCobj.TimePairwiseConditionalGC(:));
