function [filename, params] = saveResiduals(filename, varargin)
%2015-05-02. JJS.
%   Calculates the residuals for pre-selected OFC and vStr CSCs after
%   differencing the data and performing ARIMA [25 1];
arima_order = [25 1];
downsamplefactor = 4;
process_varargin(varargin);

params.arima_order = arima_order;
params.downsamplefactor = downsamplefactor;

fd = FindFiles('*keys.m');
for iSess = 1:length(fd);
    pushdir(fileparts(fd{iSess}));
    SSN = GetSSN('SingleSession');
    disp(SSN)
    [ofc vstr Fs] = prepCSCs2;
    % First Order Differencing
    ofc1 = tsd(ofc.T(1:end-1), diff(ofc.D));
    vstr1 = tsd(vstr.T(1:end-1), diff(vstr.D));
    % Downsampling
    ofc2 = tsd(downsample(ofc1.range,downsamplefactor), downsample(ofc1.data,downsamplefactor));
    vstr2 = tsd(downsample(vstr1.range,downsamplefactor), downsample(vstr1.data,downsamplefactor));
    assert(length(ofc.data)==length(vstr.data))
    % ARIMA modeling
    tic
    disp('calculating ARIMA model');
    mOFC = armax(ofc2.data, arima_order);
    tempOFC = pe(mOFC, ofc2.data);
    residsOFC = tsd(ofc2.range, tempOFC);
    mVSTR = armax(vstr2.data, arima_order);
    tempVSTR = pe(mVSTR, vstr2.data);
    residsVSTR = tsd(vstr2.range, tempVSTR);
    toc
    
    fn = strcat(SSN, '-', filename, '.mat');
    save(fn, 'residsOFC','residsVSTR', 'Fs', 'params');
    disp('data saved');    
end

