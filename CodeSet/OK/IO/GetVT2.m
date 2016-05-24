function [x,y] = GetVT2(varargin)
%2012-01-18 AndyP
%Simple function to load nvt video tracker files

LoadVT = 1;

process_varargin(varargin);

[~, SSN, ~] = fileparts(pwd);

if exist(strcat(SSN, '-vt2.mat'), 'file')==2;
	fVT2 = FindFile(strcat(SSN,'-vt2.mat'));
	warning off MATLAB:unknownObjectNowStruct
	load(fVT2);
	if ~exist('x','var')>=1;
		x=vt2_xLum;  %#ok<*NASGU>
		y=vt2_yLum;
	end
elseif exist(strcat(SSN, 'VT2.Nvt'), 'file')==2;
	fVT2 = FindFile(strcat(SSN, 'VT2.Nvt'));
	[x,y] = LoadVT0_lumrg(fVT2);
else
	fVT2 = FindFile('*-vt2.mat');
	if isempty(fVT2); fVT2 = FindFile('*2.Nvt'); end
end

assert(~isempty(fVT2), 'Cannot find video tracker file');

x = tsd(x.t,x.data);
y = tsd(y.t,y.data);
end


