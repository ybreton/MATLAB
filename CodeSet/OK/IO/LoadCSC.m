function [CSCout,NumberSamples,nBlocks] = LoadCSC(filename,varargin)

% CSC = LoadCSC(filename);
% returns a tsd containing the timestamp and CSC data
% ncst
% 5/15/2003 JCJ modified to specify units (ts) in tsd
% 5/8/2007 MvdM added conversion to s
% 2012-01-23 AndyP modified for 2012 code_set.  CSCout is in seconds

ExtractMode = 1;
D = [];
process_varargin(varargin);
%FieldSelection = [1 1 1 1 1]; %[Timestamps, Channel Numbers, Sample Frequency, Number of Valid Samples, Samples]
%ExtractHeader = 1;
switch ExtractMode
	case 1; ExtractionVector=1; %all data
	case 2; ExtractionVector=D; % D is a 2x1 vector of indices indicating endpoints of data to extract
	case 3; ExtractionVector=D; % D is a Nx1 vector of indices (can be temporally unordered)
	case 4; ExtractionVector=D; % D is a 2x1 vector of timestamps indicating endpoints of data to extract
	case 5; ExtractionVector=D; % D is a Nx1 vector of timestamps (can be temporally unordered)
	otherwise; error('unknown extraction mode');
end
if ExtractionVector~=1 && isempty(D); error('unknown extraction vector'); end
[TimeStamps, ~, ~, ~, Samples,~] = Nlx2MatCSC( filename, [1 1 1 1 1], 1, ExtractMode, ExtractionVector);
%[TimeStamps, ~, ~, ~, Samples,~] = Nlx2MatCSC( filename, FieldSelection, ExtractHeader, ExtractMode, ExtractionVector);
TimeDiff = median(diff(TimeStamps));
nBlocks = size(Samples,2);
rollover = find(diff(TimeStamps) < 0, 1);
if ~isempty(rollover)
	warning('negative ts found');
	for iX = 1:length(rollover)
		TimeStamps(rollover(iX)+1:end) = TimeStamps(rollover(iX)+1:end) + (TimeStamps(rollover(iX)) - TimeStamps(rollover(iX) + 1)) + TimeDiff;
	end
end
TimeStamps = TimeStamps*(10^-6);
TimeDiff = median(diff(TimeStamps));
NumberSamples = length(Samples(:,1));
Times = (0:NumberSamples - 1)*(TimeDiff/NumberSamples);
T1 = repmat(Times',1,length(TimeStamps));
T2 = repmat(TimeStamps,NumberSamples,1);
CSCtimes = T2 + T1;
CSCout = tsd(CSCtimes(:)',Samples(:))';
