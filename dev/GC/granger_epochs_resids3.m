function [F12, F21, Fall, f, fs, fvec, Xrange, cdensity, Pval, Sig, params] = granger_epochs_resids3(windowlength, morder, varargin)
% 2015-05-04. JJS.
% this version pulls the precalculated residuals from each session folder
% to speed up processing time.

%% Inintialize
disp('working');
%% Prep and format the data
format short
% [ofc vstr fs] = prepCSCs2('decimatefactor', 0);
%
% % First Order Differencing
% ofc = tsd(ofc.T(1:end-1), diff(ofc.D));
% vstr = tsd(vstr.T(1:end-1), diff(vstr.D));
% % Downsampling
% ofc = tsd(downsample(ofc.range,4), downsample(ofc.data,4));
% vstr = tsd(downsample(vstr.range,4), downsample(vstr.data,4));
% fs = fs/4;

nvars = 2; % number of time series. In the case with only ofc and vstr, nvars == 2.
s1 = 'ofc'; s2 = 'vstr';

regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)
% morder    = 'AIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
% momax     = 20;     % maximum model order for model order estimation
acmaxlags = '';   % maximum autocovariance lags (empty for automatic calculation). In the demo, this value happens to be equal to the number of observations in a single trial.
tstat     = '';     % statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
alpha     = 0.05;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')
fres      = 300;     % frequency resolution (empty for automatic calculation)
ntrials   = 1;
doSave = 0;
process_varargin(varargin);

%% Set analysis parameters
SSN = GetSSN('SingleSession');
load(strcat(SSN, '-WS_residuals.mat'));
fs = 1/residsOFC.dt;
nobs      = round(fs*windowlength);   % number of observations per trial
disp(strcat('nobs =', num2str(nobs)));
nbins = floor(length(residsOFC.data)/nobs);
X = cell(1,nbins);
centerTime = round(nobs/2);
% note*** Need to add timestamps to the output
for iT = 1:nbins-windowlength;
    disp(iT)
    X{iT} = nan(2, nobs*windowlength, 1);
    if iT == 1;
        datatouse = 1:nobs;
    else
        datatouse = (iT-1)*nobs+1:iT*nobs;
    end
    
    x = residsOFC.D(datatouse);
    X{iT}(1,:,:) = x;
    y = residsVSTR.D(datatouse);
    X{iT}(2,:,:) = y;
    
    Ind = datatouse(centerTime);
    Xrange(iT) = residsVSTR.T(Ind);
    
    if sum(sum(isnan(X{iT}(1,:,:))))>0; warning('1 or more NaNs in OFC data'); end
    if sum(sum(isnan(X{iT}(2,:,:))))>0; warning('1 or more NaNs in VSTR data'); end
end
%% Parameters

params.s1 = s1;
params.s2 = s2;
params.regmode = regmode;
params.icregmode = icregmode;
params.morder = morder;
params.morderdetermination = 'user specificed input';
params.acmaxlags = acmaxlags;
params.tstat = tstat;
params.alpha = alpha;
params.mhtc = mhtc;
params.fres = fres;
params.ntrials = ntrials;
params.nvars = nvars;

for iT = 1:nbins - windowlength;
    disp(iT)
    % Estimate VAR model of selected order from data.
    [A{iT},SIG{iT}] = tsdata_to_var(X{iT},morder,regmode);
    % Check for failed regression
    assert(~isbad(A{iT}),'VAR estimation failed');
    
    %% Autocovariance calculation (A5)
    [G{iT},info{iT}] = var_to_autocov(A{iT},SIG{iT},acmaxlags);
    var_info(info{iT},true); % report results (and bail out on error)
    
    %% Granger causality calculation: frequency domain (A14)
    f{iT} = autocov_to_spwcgc(G{iT},fres);
    % Check for failed spectral GC calculation
    assert(~isbad(f{iT},false),'spectral GC calculation failed');
    
    clf
    lam = plot_spw(f{iT},fres);
%     subplot(2,2,2)
%     c = axis;
%     axis([c(1) 300 c(3) c(4)]);
%     title('Spectral pairwise G-causality: vstr --> ofc')
%     subplot(2,2,3)
%     c = axis;
%     axis([c(1) 300 c(3) c(4)]);
%     title('Spectral pairwise G-causality: ofc --> vstr')
    fvec = lam;
%     h = gca;
%     fn = strcat(SSN, '-', 'GCtimeseries', num2str(windowlength), '-fres', num2str(fres), '.mat');
%     saveas(h, fn, 'fig'); disp('spectra fig saved');
    
    %% Granger causality calculation: time domain  (<mvgc_schema.html#3 |A13|>)
    % Calculate time-domain pairwise-conditional causalities - this just requires
    % the autocovariance sequence.
    F{iT} = autocov_to_pwcgc(G{iT});
    % disp(F);
    % Check for failed GC calculation
    assert(~isbad(F{iT},false),'GC calculation failed');
    % Significance test using theoretical null distribution, adjusting for multiple hypotheses.
    pval{iT} = mvgc_pval(F{iT},morder,nobs,ntrials,1,1,nvars-2,tstat); % take careful note of arguments!
    Pval.ofc(iT) = pval{iT}(2,1); Pval.vstr(iT) = pval{iT}(1,2);
    sig{iT}  = significance(pval{iT},alpha,mhtc);
    Sig.ofc(iT) = sig{iT}(2,1); Sig.vstr = sig{iT}(1,2);
    
    F12(iT) = F{iT}(2,1); disp(strcat('ofc-->vstr =', num2str(F12(iT))));
    F21(iT) = F{iT}(1,2); disp(strcat('vstr-->ofc =', num2str(F21(iT))));
    
    % For good measure we calculate Seth's causal density (cdensity) measure - the mean
    % pairwise-conditional causality. We don't have a theoretical sampling
    % distribution for this.
    cdensity(iT) = mean(F{iT}(~isnan(F{iT})));
    %     fprintf('\ncausal density = %f\n',cdensity{iT});
    
    %% Granger causality calculation: frequency domain -> time-domain  (<mvgc_schema.html#3 |A15|>)
    % Check that spectral causalities average (integrate) to time-domain
    % causalities, as they should according to theory.
    fprintf('\nchecking that frequency-domain GC integrates to time-domain GC... \n');
    Fint = smvgc_to_mvgc(f{iT}); % integrate spectral MVGCs
    mad = maxabs(F{iT}-Fint);
    madthreshold = 1e-5;
    if mad < madthreshold
        fprintf('maximum absolute difference OK: = %.2e (< %.2e)\n',mad,madthreshold);
    else
        fprintf(2,'WARNING: high maximum absolute difference = %e.2 (> %.2e)\n',mad,madthreshold);
    end
end

Fall = F12;
Fall(2,:) = F21;

% xrange = 1:length(F12);
% yrange = [1 2];

if doSave == 1;
    fn = strcat(SSN, '-', 'GCtimeseries', num2str(windowlength), '-fres', num2str(fres), '.mat');
    save(fn, 'F12', 'F21', 'Fall', 'f', 'fs', 'Xrange', 'cdensity', 'Pval', 'Sig', 'params');
    disp('data saved');
end

end

