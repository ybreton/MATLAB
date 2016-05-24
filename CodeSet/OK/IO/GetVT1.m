function [x,y] = GetVT1(varargin)
%2012-01-18 AndyP
%Simple function to load nvt video tracker files

LoadVT = 1;

process_varargin(varargin);

[~, SSN, ~] = fileparts(pwd);

if exist(strcat(SSN, '-vt.mat'), 'file')==2;
	fVT1 = FindFile(strcat(SSN,'-vt.mat'));
	warning off MATLAB:unknownObjectNowStruct
	load(fVT1);
	if ~exist('x','var')>=1;
		x=vt1_xLum;  %#ok<*NASGU>
		y=vt1_yLum;
	end
elseif exist(strcat(SSN, 'VT1.Nvt'), 'file')==2;
	fVT1 = FindFile(strcat(SSN, 'VT1.Nvt'));
	[~,x,y] = LoadVT_lumrg(fVT1);
else
	fVT1 = FindFile('*-vt.mat');
	if isempty(fVT1); fVT1 = FindFile('*1.Nvt'); end
end

assert(~isempty(fVT1), 'Cannot find video tracker file');

if isstruct(x) && isstruct(y);
	x = tsd(x.t,x.data);
	y = tsd(y.t,y.data);
end
end


