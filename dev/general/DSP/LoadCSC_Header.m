function Header = LoadCSC_Header(filename,varargin)
% Loads the header of the CSC file.

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

[~, ~, ~, ~, ~, NlxHeader] = Nlx2MatCSC( filename, [1 1 1 1 1], 1, ExtractMode, ExtractionVector);

% -HardwareSubSystemName 
% -HardwareSubSystemType 
% -SamplingFrequency 
% -ADMaxValue 
% -ADBitVolts 
% -NumADChannels
% -ADChannel
% -InputRange 
% -InputInverted
% -DSPLowCutFilterEnabled
% -DspLowCutFrequency
% -DspLowCutNumTaps 
% -DspLowCutFilterType 
% -DSPHighCutFilterEnabled 
% -DspHighCutFrequency 
% -DspHighCutNumTaps 
% -DspHighCutFilterType 
% -DspDelayCompensation
% -DspFilterDelay_µs
fields = {  'AcqEntName'
            'FileType'
            'RecordSize'
            'HardwareSubSystemName'
            'HardwareSubSystemType'
            'SamplingFrequency'
            'ADMaxValue'
            'ADBitVolts'
            'NumADChannels'
            'ADChannel'
            'InputRange'
            'InputInverted'
            'DSPLowCutFilterEnabled'
            'DspLowCutFrequency'
            'DspLowCutNumTaps'
            'DspLowCutFilterType'
            'DSPHighCutFilterEnabled'
            'DspHighCutFrequency'
            'DspHighCutNumTaps'
            'DspHighCutFilterType'
            'DspDelayCompensation' %+2, with trailing space [~]
            'DspFilterDelay'}; %+4, with trailing _us[~]
numerics = [0
            0
            1
            0
            0
            1
            1
            1
            1
            1
            1
            0
            0
            1
            1
            0
            0
            1
            1
            0
            0
            1];
        
for iF=1:length(fields)
    start = regexpi(NlxHeader,fields{iF});
    idx = ~cellfun(@isempty,start);
    hr = find(idx,1,'first');
    start = can2mat(start);
    if iF<length(fields)
        start(hr) = start(hr)+length(fields{iF})+1;
    else
        start(hr) = start(hr)+length(fields{iF})+3;
    end
    value = NlxHeader{hr}(start(hr):end);
    value = strrep(value,' ','');
    if numerics(iF)==1
        value = str2double(value);
    else
        if strcmpi(value,'True')
            value = true;
        end
        if strcmpi(value,'False')
            value = false;
        end
    end
    Header.(fields{iF}) = value;
end