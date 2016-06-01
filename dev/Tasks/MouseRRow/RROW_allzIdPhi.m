function allVTE = RROW_allzIdPhi(fd, varargin)
% Wrapper to go through file directories and pull in zIdPhi by
% earn/skip/quit
% INPUT
%   fc = list of directories
% OUTPUT
%   staySkip = structure with number of stays by flavor, number skips by
%   flavor, etc.

% variables
DayLimit = '';
process_varargin(varargin);
MouseLimit = '';
process_varargin(varargin);
ConditionLimit = '';
process_varargin(varargin);

% Build base
allVTE.isEarn = [];
allVTE.isQuit = [];
allVTE.isEnter = [];
allVTE.isSkip = [];
allVTE.zIdPhi = [];

% Step through directories
nD = length(fd);
for iD = 1:nD
    sd = mouseRROWTaskInit(fd{iD});
    
    
    if (isempty(ConditionLimit) || ...
            strncmp(sd.keys.Condition,ConditionLimit,length(ConditionLimit)))
        if (isempty(MouseLimit) || ...
                strncmp(sd.keys.SSN,MouseLimit,length(MouseLimit)))
            if (isempty(DayLimit) || ...
                    ismember(sd.keys.DayOfStudy,str2num(DayLimit)))
                disp(sd.keys.SSN);
            else
                
                continue;
            end
            
            
        else
            
            continue;
            
        end
    else
        continue
    end
      
    % add today's work  
    sd = RROW_zIdPhi(sd);
    
    isQuit = ~isnan(sd.taskEvents.QuitTimeStamp);
    isEarn = ~isnan(sd.taskEvents.EarnTimeStamp);
    isEnter = ~isnan(sd.taskEvents.EnterTimeStamp);
    isSkip = ~isnan(sd.taskEvents.SkipTimeStamp);

    allVTE.isQuit = cat(1, allVTE.isQuit, isQuit);
    allVTE.isEarn = cat(1, allVTE.isEarn, isEarn);
    allVTE.isEnter = cat(1, allVTE.isEnter, isEnter);
    allVTE.isSkip = cat(1, allVTE.isSkip, isSkip);
    
    allVTE.zIdPhi = cat(1, allVTE.zIdPhi, sd.zIdPhi);
    
end
allVTE.isQuit = logical(allVTE.isQuit);
allVTE.isEarn = logical(allVTE.isEarn);
allVTE.isEnter = logical(allVTE.isEnter);
allVTE.isSkip = logical(allVTE.isSkip);


end % function
