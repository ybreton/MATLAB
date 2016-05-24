function [FeedersFired, FeederTimes] = DD6_FixFeedersFired(FeederTimes, FeedersFired, ZoneIn, TotalLaps)
% 2011-09-22 AEP
% 2013-02-20 AndyP
% DD6 saves a timestamp in the DD.mat file for all Feeder Firing times and
% records which feeder fired.  However, nothing is saved when a feeder is
% skipped.  This function fills in feeder skips with a '0'.
% INPUTS
% FeederTimes, FeedersFired, TotalLaps, ZoneIn
% OUTPUTS
% FeedersFired    A vector of size (1,TotalLaps) with values of 1(RF) 3(LF) or 0 (Feeder Skip)
% FeederTimes     A vector of size (1,TotalLaps) with timestamps when feeders fired
% skipFF            An integer double that records the number of feeder skips

% Get Data from Mat File
temp1 = FeedersFired;  %all operations are carrier out in temp files
temp2 = FeederTimes;
skipFF=0;
SSN=GetSSN;
%handles case where FeedersFired is correct but FeederTimes is not

if length(FeedersFired)==TotalLaps && length(FeederTimes)<TotalLaps || strcmp(SSN,'R230-2011-10-01')
	%% 2013-02-20 AndyP
	
	
	if strcmp(SSN,'R230-2011-09-26'); % [56,81]
		missed = [56,81];
	end
	
	if strcmp(SSN,'R230-2011-09-27'); % [1,3,11,78,92,95,99]
		missed = [1,3,11,78,92,95,99];
	end
	
	if strcmp(SSN,'R230-2011-09-28'); % [1,28,34]
		missed =[1,28,34];
	end
	
	if strcmp(SSN,'R230-2011-09-29'); % [26,44,65]
		missed =[26,44,65];
	end
	
	if strcmp(SSN,'R230-2011-10-01'); % [101]
		missed =[100,101];
		temp1=[temp1,0];
	end
	
	if strcmp(SSN,'R230-2011-10-02'); % [1,13,16,23,86]
		missed =[1,13,16,23,86];
	end
	
	if strcmp(SSN,'R230-2011-10-03'); % 76
		missed =76;
	end
	
	if strcmp(SSN,'R230-2011-10-05'); % [1,70]
		missed =[1,70];
	end
	
	if strcmp(SSN,'R230-2011-10-06'); % [16,60]
		missed =[16,60];
	end
	
	if strcmp(SSN,'R230-2011-10-07'); % [8]
		missed =8;
	end
	
	if strcmp(SSN,'R230-2011-10-08'); % [1,12,15,18]
		missed =[1,12,15,18];
	end
	
	if strcmp(SSN,'R230-2011-10-09'); % [56,67]
		missed =[56,67];
	end
	
	if strcmp(SSN,'R230-2011-10-10'); % [2,6,10,13,16,20]
		missed =[2,6,10,13,16,20];
	end
	
	if strcmp(SSN,'R230-2011-10-11'); % [7,9,34]
		missed =[7,9,34];
	end
	
	if strcmp(SSN,'R230-2011-10-14'); % [1,3]
		missed =[1,3];
	end
	
	if strcmp(SSN,'R230-2011-10-15'); % [25,42]
		missed =[25,42];
	end
	
	if strcmp(SSN,'R230-2011-10-16'); % [19]
		missed = 19;
	end
	
	if strcmp(SSN,'R230-2011-10-18'); % [1,3,17]
		missed =[1,3,17];
	end
	
	
	if missed(1)==1; temp2=[0,temp2]; missed(1)=[]; end
	if missed(end)==TotalLaps; temp2=[temp2,0]; missed(end)=[]; end
	nM = length(missed);
		for iM=1:nM
		temp2=[temp2(1:missed(iM)-1),0,temp2(missed(iM):end)];
	end
	
%handles case where both FeedersFired and FeederTimes are not correct
elseif length(FeedersFired)~=TotalLaps && length(FeederTimes)~=TotalLaps && ~strcmp(SSN,'R230-2011-10-01') 
	
	
	% Insert '0' for Feeder Skips
	% handles the first lap
	
	if ZoneIn(1)==4 && FeedersFired(1)==3;
		temp1 = [0, FeedersFired(1:end)];
		temp2 = [0, FeederTimes(1:end)];
		skipFF = skipFF + 1;
	end
	if ZoneIn(1)==3 && FeedersFired(1)==4;
		temp1 = [0, FeedersFired(1:end)];
		temp2 = [0, FeederTimes(1:end)];
		skipFF = skipFF + 1;
	end
	
	%counts from lap 2 to the number of laps - the number of 'filled in' laps.
	for iL=2:(TotalLaps-skipFF);
		if iL > length(FeedersFired); break; end;
		if ZoneIn(iL)==3 && FeedersFired(iL-skipFF)==1; %skipped LF on lap iL
			temp1=[temp1(1:iL-1), 0, FeedersFired(iL-skipFF:end)]; %lap 1:iL-1 are OK.  Add a 0 for a FeederSkip on lap iL.
			temp2=[temp2(1:iL-1), 0, FeederTimes(iL-skipFF:end)];
			skipFF = skipFF +1;
		end
		if ZoneIn(iL)==4 && FeedersFired(iL-skipFF)==3; %%skipped RF on lap iL
			temp1=[temp1(1:iL-1), 0, FeedersFired(iL-skipFF:end)]; %lap 1:iL-1 are OK.  Add a 0 for a FeederSkip on lap iL.
			temp2=[temp2(1:iL-1), 0, FeederTimes(iL-skipFF:end)];
			skipFF = skipFF + 1;
		end
		if iL >= TotalLaps-skipFF; break; end
	end
	%handles if last laps are skipped
	if length(temp1) < TotalLaps
		temp1(end+TotalLaps-length(temp2)) = 0;
	end
	if length(temp2) < TotalLaps
		temp2(end+TotalLaps-length(temp2)) = 0;
	end
end


% OUTPUTS
FeedersFired = temp1;
FeederTimes = temp2;
end

