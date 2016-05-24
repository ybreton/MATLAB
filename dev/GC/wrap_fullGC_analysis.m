function GCobj = wrap_fullGC_analysis(CSCs,t0,window,varargin)
% Wrapper to perform the MVGC multivariate Granger Causality calculations
% on time domain data and SMVGC multivariate Granger Causality calculations
% on frequency domain (spectral) data.
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
%                .GC
%                   .MVGC
%                           Structure of time-domain Multi-Variate Granger
%                           Causalities for pairwise-conditional GC
%                           analysis
%                        .Causalities
%                            nvars x nvars matrix of time-domain Granger
%                            Causalities for pairwise-conditional GC
%                            analysis, where GC.MVGC(i,j)
%                            is the causality TO signal i FROM signal j.
%                        .to.(name)
%                            nvars x nvars boolean indicating causalities
%                            TO signal
%                        .from.(name)
%                            nvars x nvars boolean indicating causalities
%                            FROM signal
%                       .pval       
%                            p-value of the GC values
%                       .sig        
%                            significance of the p-value after correcting
%                            for multiple comparisons
%                       .SethCausalDensity
%                            Seth's Causal Density
%                   .SMVGC   
%                           Structure of frequency-domain (Spectral)
%                           Multi-Variate Granger Causalities for
%                           pairwise-conditional GC analysis
%                         .Raw
%                            nvars x nvars x nfreqs matrix of raw
%                            frequency-domain (Spectral) Granger 
%                            Causalities for pairwise-conditional GC
%                            analysis, where GC.SMVGC(i,j,k)
%                            is the causality of TO signal i FROM signal j
%                            for frequency bin k.
%                         .Fraw
%                            nvars x nvars x nfreqs array of frequencies
%                            used for raw SMVGC causalities in SMVGC.Raw.
%                         .Causalities
%                            nvars x nvars x nfreqs matrix of mean
%                            frequency-domain (Spectral) Granger 
%                            Causalities for pairwise-conditional GC
%                            analysis, where GC.SMVGC(i,j,k)
%                            is the causality of TO signal i FROM signal j
%                            for frequency bin k.
%                         .F
%                            nvars x nvars x nfreqs array of frequency
%                            lower bounds in each bin for the mean
%                            causalities in SMVGC.Causalities.
%                         .to.(name)
%                            nvars x nvars x nfreqs boolean indicating
%                            causalities TO signal
%                         .from.(name)
%                            nvars x nvars x nfreqs boolean indicating
%                            causalities FROM signal
%                         .IntegralSMVGC
%                            Integral of the frequency-domain (Spectral)
%                            Granger Causalities
%                   .MaxAbsDev
%                            Maximum absolute deviation of integral of
%                            SMVGC from MVGC.
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
%   specifies whether to plot 3 figures (true to plot, false to skip):
%   - the AIC/BIC values as a function of time lag (model order)
%   - the GC matrix, p-values for the GC values, and their significance
%   - To/From grid of GC values vs frequency ([0, F_nyquist], in fres
%   steps)
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
% fres      (default [])
%   resolution of frequency-domain GC (empty for automatic calculation)
% madthreshold (default 1e-5)
%   threshold median absolute deviation of integral of frequency-domain
%   (Spectral) MVGC to the time-domain MVGC.
%   
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

fres = [];

madthreshold = 1e-5;

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

[X,missingSignals] = arrangeCSCbyTrial(CSCs,GCobj.T,t0);
nSignals = length(CSCs);
signals = 1:nSignals;
goodSignal = signals(~missingSignals);
for iSignal=1:length(goodSignal)
    GCobj.X(goodSignal(iSignal),:,:) = X(iSignal,:,:);
end
GCobj.missingSignals = missingSignals;
GCobj.goodSignals = ~missingSignals;

if plotFlag
    %nCSCs x nTS x nTrials
    figure(1);
    clf
    m = nanmean(X,3);
    s = nanstderr2(X,0,3);
    cmap=hsv(size(m,1));
    hold on
    sh = nan(size(m,1),2);
    for iSignal=1:size(m,1)
        sh(iSignal,:)=ShadedErrorbar(GCobj.T',m(iSignal,:)',s(iSignal,:)','color',cmap(iSignal,:));
    end
    legend(sh(:,1),names);
    xlabel('Time')
    ylabel('CSC')
    hold off
    drawnow
end

disp('Calculating information criteria and model orders...')
[GCobj.AIC,GCobj.BIC,GCobj.moAIC,GCobj.moBIC] = tsdata_to_infocrit(GCobj.X(goodSignal,:,:),momax,icregmode);

if plotFlag
    figure(2); clf;
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
    [VAR,SIG] = tsdata_to_var(GCobj.X(goodSignal,:,:),morder,regmode);
    
    disp('Calculating autocovariance sequence...')
    [AutoCovSeq,AutoCovInfo] = var_to_autocov(VAR,SIG,acmaxlags);
    if AutoCovInfo.error~=0
        bombed=true;
        morder=morder-1;
        disp(AutoCovInfo.errmsg)
    else
        bombed=false;
    end
end
assert(~isbad(VAR),'VAR estimation failed');

%add these to the GC object.
GCobj.VAR = nan(nSignals,nSignals,morder);
GCobj.AutoCovSeq = nan(nSignals,nSignals,size(AutoCovSeq,3));
for iSignal1=1:length(goodSignal)
    for iSignal2=1:length(goodSignal)
        GCobj.VAR(goodSignal(iSignal1),goodSignal(iSignal2),:) = VAR(iSignal1,iSignal2,:);
        GCobj.AutoCovSeq(goodSignal(iSignal1),goodSignal(iSignal2),:) = AutoCovSeq(iSignal1,iSignal2,:);
    end
end
GCobj.SIG = nan(nSignals,nSignals);
GCobj.SIG(goodSignal,goodSignal) = SIG;
GCobj.AutoCovInfo = AutoCovInfo;

GCobj.morder = morder;
var_info(GCobj.AutoCovInfo,true); % report results (and bail out on error)

disp('Calculating time-domain pairwise-conditional Granger causalities...')
t0 = clock;
MVGC = autocov_to_pwcgc(AutoCovSeq);
assert(~isbad(MVGC,false),'GC calculation failed');
t1 = clock;
disp(['Time-domain MVGC took ' num2str(etime(t1,t0)) ' sec.'])
%add to GC object
GCobj.GC.MVGC.Causalities = nan(nSignals,nSignals);
GCobj.GC.MVGC.Causalities(goodSignal,goodSignal) = MVGC;

disp('Testing Granger causality null hypotheses...')
GCobj.GC.MVGC.pval = mvgc_pval(GCobj.GC.MVGC.Causalities,morder,GCobj.nobs,GCobj.ntrials,1,1,GCobj.nvars-2,tstat); % take careful note of arguments!
GCobj.GC.MVGC.sig  = significance(GCobj.GC.MVGC.pval,alpha,mhtc);

for iName=1:length(names)
    GCobj.GC.MVGC.to.(names{iName}) = false(size(GCobj.GC.MVGC.Causalities));
    GCobj.GC.MVGC.to.(names{iName})(iName,:) = true;
    GCobj.GC.MVGC.from.(names{iName}) = false(size(GCobj.GC.MVGC.Causalities));
    GCobj.GC.MVGC.from.(names{iName})(:,iName) = true;
end

if plotFlag
    figure(3); clf;
    subplot(1,3,1);
    set(gca,'fontsize',12)
    plot_pw(GCobj.GC.MVGC.Causalities);
    for iName=1:length(names)
        text(iName,iName,names{iName},'VerticalAlignment','middle','HorizontalAlignment','center','rotation',45,'fontsize',10)
    end
    set(gca,'xticklabel',[])
    set(gca,'yticklabel',[])
    colorbar
    title('Pairwise-conditional GC');
    subplot(1,3,2);
    set(gca,'fontsize',12)
    plot_pw(GCobj.GC.MVGC.pval);
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
    plot_pw(GCobj.GC.MVGC.sig);
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

GCobj.GC.MVGC.SethCausalDensity = nanmean(GCobj.GC.MVGC.Causalities(:));

disp('Calculating frequency-domain Granger Causality...')
t0 = clock;
SMVGC = autocov_to_spwcgc(GCobj.AutoCovSeq(goodSignal,goodSignal,:));
t1 = clock;
disp(['Frequency-domain SMVGC took ' num2str(etime(t1,t0)) ' sec.'])
fresDef = size(SMVGC,3);
assert(~isbad(SMVGC,false),'spectral GC calculation failed');

if isempty(fres)
    fres = fresDef;
end

GCobj.GC.SMVGC.Raw = nan(nSignals,nSignals,fresDef);
for iSignal1 = 1:length(goodSignal)
    for iSignal2 = 1:length(goodSignal)
        GCobj.GC.SMVGC.Raw(goodSignal(iSignal1),goodSignal(iSignal2),:) = SMVGC(iSignal1,iSignal2,:);
    end
end
Fraw = linspace(0,GCobj.fs/2,fresDef+1);
Fraw = Fraw(1:end-1);

GCobj.GC.SMVGC.Fraw = repmat(reshape(Fraw,1,1,fresDef),[nSignals,nSignals,1]);

GCobj.GC.SMVGC.Causalities = nan(nSignals,nSignals,fres);
fLo = linspace(0,GCobj.fs/2,fres+1);
fHi = fLo+nanmedian(diff(fLo));
for iF=1:fres
    for iSignal1 = 1:length(goodSignal)
        for iSignal2 = 1:length(goodSignal)
            id = GCobj.GC.SMVGC.Fraw(iSignal1,iSignal2,:)>=fLo(iF)&GCobj.GC.SMVGC.Fraw(iSignal1,iSignal2,:)<fHi(iF);
            S = SMVGC(iSignal1,iSignal2,id);
            GCobj.GC.SMVGC.Causalities(goodSignal(iSignal1),goodSignal(iSignal2),iF) = nanmean(S);
        end
    end
end
F = linspace(0,GCobj.fs/2,fres+1);
F = F(1:end-1);
GCobj.GC.SMVGC.F = repmat(reshape(F,1,1,fres),[nSignals,nSignals,1]);

GCobj.params.fres = fres;

for iName=1:length(names)
    GCobj.GC.SMVGC.to.(names{iName}) = false(size(GCobj.GC.SMVGC.Causalities));
    GCobj.GC.SMVGC.to.(names{iName})(iName,:,:) = true;
    GCobj.GC.SMVGC.from.(names{iName}) = false(size(GCobj.GC.SMVGC.Causalities));
    GCobj.GC.SMVGC.from.(names{iName})(:,iName,:) = true;
end

if plotFlag
    figure(4); clf;
    plot_spw(GCobj.GC.SMVGC.Causalities,GCobj.fs);
    for iSignalTo=1:size(GCobj.GC.SMVGC.Causalities,1)
        for iSignalFrom=1:size(GCobj.GC.SMVGC.Causalities,2)
            if iSignalTo~=iSignalFrom
                pn = (iSignalTo-1)*size(GCobj.GC.SMVGC.Causalities,2)+iSignalFrom;
                subplot(size(GCobj.GC.SMVGC.Causalities,1),size(GCobj.GC.SMVGC.Causalities,2),pn)
                yh=ylabel(sprintf('%s -> %s',names{iSignalFrom},names{iSignalTo}));
                set(yh,'fontsize',12)
            end
        end
    end
    drawnow
end

disp('Checking that frequency-domain GC integrates to time-domain GC...');
Fint = smvgc_to_mvgc(SMVGC); % integrate spectral MVGCs
mad = maxabs(MVGC-Fint);
disp(['Max(Integral of SMVGC) - MVGC: ' num2str(mad) ', threshold ' num2str(madthreshold)])
GCobj.GC.SMVGC.IntegralSMVGC = Fint;
GCobj.GC.MaxAbsDev = mad;
GCobj.params.madthreshold = madthreshold;