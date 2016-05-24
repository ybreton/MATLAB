function [ofc vstr fs] = prepCSCs2(varargin)
%2014-09-10. JJS. Loads and prepares the ofc and vstr CSC files that are
%specified as 'good' in the keys file for analysis of granger causality for
%a single session.

detrend = 0;
process_varargin(varargin);

% tic
EvalKeys;
[CSCoutOFC,~,~] = LoadCSC(ExpKeys.OFCcsc); ofc = CSCoutOFC;
[CSCoutVSTR,~,~] = LoadCSC(ExpKeys.VSTRcsc); vstr = CSCoutVSTR;
% restrict to time on track
ofc = ofc.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
vstr = vstr.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
assert(length(ofc.data)==length(vstr.data));
assert(ofc.dt == vstr.dt);

% remove dc shifts in voltage
if detrend == 1;
    OFCdata=locdetrend(ofc.data, 1/ofc.dt, [1 0.5]);
    VSTRdata=locdetrend(vstr.data, 1/vstr.dt, [1 0.5]);
    ofc = tsd(ofc.range, OFCdata);
    vstr = tsd(vstr.range, VSTRdata);
end

assert(length(ofc.data) == length(vstr.data))
fs = 1/ofc.dt;
assert((1/ofc.dt)==(1/vstr.dt))

if sum(isnan(ofc.D))>0;
    warning('1 or more NaNs in OFC data');
end
if sum(isnan(vstr.D))>0;
    warning('1 or more NaNs in VSTR data');
end

% ofc = ctsd(ofc);
% vstr = ctsd(vstr);

% toc

end

