function VTE = get_ProbRR_zIdPhi_from_vt1(varargin)
%
%
%
%

vt1fn = FindFiles('*-vt1.mat');
process_varargin(varargin);

load(vt1fn{1},'x','y')

[CPentryTimes,CPexitTimes,CPentered] = ProbRR_cp_entry(x,y);

sd.x = x;
sd.y = y;
sd.EnteringCPTime = CPentryTimes;
sd.ExitingCPTime = CPexitTimes;
sd.CPZone = CPentered;

VTE = zIdPhi(sd);

