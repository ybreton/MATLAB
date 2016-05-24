function TFout = read_runfile(txt,varargin)
%
%
%

LapIndicator = 'Lap';
CorrectLap = '(CORRECT)';
ErrorLap = '(ERROR)';
process_varargin(varargin);

fid=fopen(txt);

tline = fgetl(fid);
TFout = [];
while ischar(tline)
    id = strncmpi(tline,LapIndicator,length(LapIndicator));
    if id
        id = regexpi(tline,LapIndicator);
        id2 = regexpi(tline,'(');
        lap = tline(length(LapIndicator)+1:min(id2)-1);
        lapnum = str2double(lap);
        
        idCorrect = regexpi(tline,CorrectLap);
        idError = regexpi(tline,ErrorLap);
        if ~isempty(idCorrect) && isempty(idError)
            % CORRECT LAP
            TFout(lapnum) = 1;
        elseif isempty(idCorrect) && ~isempty(idError)
            % INCORRECT LAP
            TFout(lapnum) = 0;
        else
            % Error in file.
            TFout(lapnum) = nan;
        end
        
    end
    
    tline = fgetl(fid);
end

fclose(fid);
TFout = TFout(:);