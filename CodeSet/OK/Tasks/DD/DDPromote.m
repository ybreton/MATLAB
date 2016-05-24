function [ ] = DDPromote(varargin)
% 2011-02-14 AEP
% 2012-07-25 AndyP updated function calls to DD_PlotVT1, DD_PlotVT2,
% DD_CreateKeys
% This function promotes one (D)elay (D)iscounting session.
% INPUTS
% Takes VT1 and VT2 data from current directory
% Prompts user for additional input to create keys file
% OUTPUTS
% R###_YYYY_MM_DD_keys.m    KEYS file
% R###-YYYY-MM-DD-vt.mat    RVT1 mat file restricted to time on track
% R###-YYYY-MM-DD-VT2.mat   VT2 mat file restricted to time on track
% SUBFUNCTIONS
% DD_PlotVT1
% DD_PlotVT2
% LoadVT_lumrg
% LoadVT_lumrg_ANTI_restricted    
% GetSSN
% process_varargin
% DECLARATIONS
% Conditionals
GinputIt = 0; % if GinputIt==1, use GUI to click on time on and time off track.  if GinputIt==0, manually enter these times.
process_varargin(varargin);
SSN = GetSSN('SingleSession');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Video Tracker 2 Data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fVT2 = strcat(SSN, '-VT2.nvt');
assert(~exist(fVT2,'file')==0, 'video tracker 2 file not found');
[x2,y2]=LoadVT_lumrg(fVT2);
DD_PlotVT2(x2,y2);
[OUT] = CheckIt; BustIt = ~OUT; flag = 1;
while BustIt == 1;
	% Prompt user for the pixels to remove from the video tracker file
	while BustIt==1 && flag==1;
		xm = input('Enter Xmin < X:          ', 's'); if isempty(xm); xm = '0'; end
		xM = input('Enter Xmax > X:          ', 's'); if isempty(xM); xM = '0'; end
		ym = input('Enter Ymin < Y:          ', 's'); if isempty(ym), ym = '0'; end
		yM = input('Enter Ymax > Y:          ', 's'); if isempty(yM); yM = '0'; end
		xm = str2double(xm); xM = str2double(xM); ym = str2double(ym); yM = str2double(yM);
		if xm < xM && ym < yM && xm > -1 && ym > -1 && xM > -1 &&yM > -1;
			flag = 0;
		else flag = 1; fprintf(' Values can not be negative or non-numeric.  \n  Xmin must be less than Xmax, Ymin must be less than Ymax. \n');
		end
	end
	%------------------
	if BustIt==1;
		[x2,y2] = LoadVT_lumrg_ANTI_restricted(fVT2, xm, xM, ym, yM);
		fprintf('Ghost Pixels have been removed from the luminance channel \n');
	end
	if BustIt==1;
		DD_PlotVT2(x2,y2); [OUT] = CheckIt; BustIt = ~OUT; flag = ~OUT;
	end
end %end while exitFlag
fprintf('VT2 Data accepted.\n'); clf;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Restricting Things to time on track %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exitFlag =0; %exits while loop
while exitFlag == 0;
	fVT1 = strcat(SSN, '-VT1.nvt');
	assert(~exist(fVT1,'file')==0, 'video tracker 1 file not found');
	[x,y]=LoadVT_lumrg(fVT1);
	% Prompt user for time on track and time off track
	%------------------
	if GinputIt ==0;
		[x,y]=LoadVT_lumrg(fVT1);
		DD_PlotVT1(x,y);
		t0 = input('Enter time ON track:     ', 's');
		if isempty(t0); t0 = '0'; end
		clf;
		[x,y]=LoadVT_lumrg(fVT1); DD_PlotVT1(x,y);
		t1 = input('Enter time OFF track:          ', 's');
		if isempty(t1); t1 = '0'; end
		t0 = floor(str2double(t0));
		t1 = ceil(str2double(t1));
	end
	%------------------
	if GinputIt ==1
		clf;
		[x,y]=LoadVT_lumrg(fVT1);
		DD_PlotVT1(x,y);
		fprintf('Click to enter time ON track.  \n  Use upper plot (x.range vs x.data) \n');
		pause; IO = ginput;
		if ~isempty(IO); t0 = IO(1,2); else exitFlag = 0; end %#ok<NASGU>
		clf;
		DD_PlotVT1(x,y);
		fprintf('Click to enter time OFF track.  \n  Use upper plot (x.range vs x.data) \n');
		pause; IO=ginput;
		if ~isempty(IO); t1 = IO(1,2); else exitFlag = 0; end %#ok<NASGU>
		fprintf('time ON track = %d, time OFF track = %d  \n', round(t0), round(t1));
		t0 = floor(t0); t1 = ceil(t1);
	end
	%------------------
	%check that user input is correct
	if t0 >= t1; exitFlag=0; fprintf('t0 can not be greater than t1! \n');
	elseif t0 ==0; exitFlag=0; fprintf('t0 not entered \n');
	elseif t1==0; exitFlag = 0; fprintf('t1 not entered \n');
	else exitFlag=1;
	end
	if exitFlag==1
		%Restricting to time on track
		x = x.restrict(t0, t1); y = y.restrict(t0, t1);
		x2 = x2.restrict(t0, t1); y2 = y2.restrict(t0, t1);
		clf; DD_PlotVT1(x,y); [exitFlag] = CheckIt;
		if exitFlag==1; fprintf('VT1 Data accepted \n'); close; end
	else fprintf('There was an error in time ON/OFF track data entry.\n');
	end
end
%%%%%%%%%%%%%%%%%%%%%%
% Save *vt.mat files %
%%%%%%%%%%%%%%%%%%%%%%

VT1FileName = strcat(fVT1(1:strfind(fVT1,'.')-1), '.mat'); %remove trailing 1 from file name for backwards compatibility
save(VT1FileName, 'x', 'y'); clear x y

VT1FileName = strcat(fVT2(1:strfind(fVT2,'.')-1), '.mat'); %remove trailing 1 from file name for backwards compatibility
x = x2; y = y2; %#ok<NASGU>
save(VT1FileName, 'x', 'y');

%%%%%%%%%%%%%%%%%%%%
% Create Keys file %
%%%%%%%%%%%%%%%%%%%%
DD_CreateKeys('TimeOnTrack', t0, 'TimeOffTrack', t1);
end
%------------------
function[OUT] = CheckIt % This function asks the user if the input 'fh' is ok, returns a binary flag 'OUT'
exitFlag = 0; %exits while loop
while exitFlag ==0;
	OUT = input('Ok?     ', 's');
	if isempty(OUT); OUT = ''; end
	if strcmp(OUT, 'Yes') || strcmp(OUT, 'Y') || strcmp(OUT, 'YES') || strcmp(OUT, 'y') || strcmp(OUT, '1') || strcmp(OUT, 'yes') || strcmp(OUT, ' 1') || strcmp(OUT, '1 ')|| strcmp(OUT, '1  ')|| strcmp(OUT, '  1') || strcmp(OUT, ' 1 ')
		OUT = 1; exitFlag = 1;
	elseif strcmp(OUT, 'No') || strcmp(OUT, 'N') || strcmp(OUT, 'NO') || strcmp(OUT, 'n') || strcmp(OUT, '0') || strcmp(OUT, 'no') || strcmp(OUT, ' 0') || strcmp(OUT, '0 ')|| strcmp(OUT, '0  ')|| strcmp(OUT, '  0') || strcmp(OUT, ' 0 ')
		OUT = 0; exitFlag =1;
	else
		fprintf('Error, valid responses are: (Yes, Y, YES, y, yes, 1) \n OR (No, N, NO, n, no, 0) \n');
	end
end
end

