function ARIMA = wrap_ARIMA_modelPE(csc,varargin)
% Returns the differenced, downsampled, ARIMA-model prediction error for
% Granger causality calculations.
% ARIMA = wrap_ARIMA_model(csc)
% where     ARIMA   is a tsd of the detrended, differenced, downsampled,
%                       ARIMA-error model prediction error
%
%           csc     is a tsd of the CSC to use
%
% OPTIONAL ARGUMENTS:
% ******************
% downsampleFactor  (default 1)
%           Factor by which to downsample the CSCs.
% arima_order       (default [25 1])
%           Order of the ARIMA error model (Na,Nc), where
%           A(q)y(t) = e(t)
%           current output depends on past output and error
%
% 2015-10-28 YAB: Adapted from saveResiduals from JJS.
%

arima_order = [25 1];
downsampleFactor = 1;
window = 1;
winstep = 0.5;
process_varargin(varargin);

if iscell(csc)
    cscList = csc;
elseif isa(csc,'ts')
    cscList = {csc};
else
    error('CSC input must be a tsd or a cell array of tsd''s.')
end
clear csc

ARIMA = cell(size(cscList));
for iF=1:numel(cscList)
    if ~isempty(cscList{iF})
        disp([inputname(1) '{' num2str(iF) '}']);
        t = cscList{iF}.range;
        d = cscList{iF}.data;
        dt = cscList{iF}.dt;
        disp(['de-trending DC drifts in ' num2str(window) 's windows stepping in ' num2str(winstep) 's steps...'])
        dDetrend = locdetrend(d, 1/dt, [window winstep]);
        cscD1 = tsd(t(1:end-1), diff(dDetrend));
        disp(['downsampling by a factor of ' num2str(downsampleFactor) '...'])
        cscD1dwn = CSC_downsample(cscD1,'factor',downsampleFactor);
        disp(['calculating ARIMA model...']);
        modelSys = armax(cscD1dwn.data, arima_order);
        disp('calculating ARIMA model prediction error... ');
        modelPE = pe(modelSys, cscD1dwn.data);
        ARIMA{iF} = tsd(cscD1dwn.range, modelPE);
    end
end
if numel(ARIMA)==1
    ARIMA = ARIMA{1};
end