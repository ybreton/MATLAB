function allTimes = RROW_allTimes(fd, varargin)
% Wrapper to go through file directories and pull in staySkip proportions by flavor
% INPUT
%   fd = list of directories
% OUTPUT
%   

% variables
DayLimit = '';
MouseLimit = '';
ConditionLimit = '';
conditions = {'saline','cocaine'};
parms = {'skip','enter','quit','enterToQuit','enterToEarn','earn','work'};

process_varargin(varargin);
nParms = length(parms);

% Build base
allTimes.flavors = {};
allTimes.mice = {};
allTimes.conditions = {};

for iP = 1:nParms
    allTimes.time.(parms{iP}) = [];
    allTimes.offer.(parms{iP}) = [];
    allTimes.mouse.(parms{iP}) = [];
    allTimes.day.(parms{iP}) = [];
    allTimes.flavor.(parms{iP}) = [];
    allTimes.condition.(parms{iP}) = [];
end

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
      
    
    % find mouse
    mouseName = sd.keys.SSN(1:4);
    myID = find(strcmp(mouseName, allTimes.mice));
    if isempty(myID)
        allTimes.mice{end+1} = mouseName;
        myID = length(allTimes.mice);
    end
        
    % get and check flavors
    if isempty(allTimes.flavors)
        allTimes.flavors = sd.keys.Flavors;
    else
        assert(all(strcmp(allTimes.flavors, sd.keys.Flavors)));
    end
    
   
    % add today's work for SkipTime
    keep = ~isnan(sd.taskEvents.SkipTime);
    nSkip = length(sd.taskEvents.SkipTime(keep));
    
    allTimes.time.skip = cat(1, allTimes.time.skip, sd.taskEvents.SkipTime(keep));
    allTimes.offer.skip = cat(1, allTimes.offer.skip, sd.taskEvents.Offer(keep));
    allTimes.mouse.skip = cat(1, allTimes.mouse.skip, repmat(myID, nSkip,1));
    allTimes.flavor.skip = cat(1, allTimes.flavor.skip, sd.taskEvents.Flavor(keep));
    allTimes.day.skip = cat(1, allTimes.day.skip, repmat(sd.keys.DayOfStudy,nSkip,1));
    allTimes.condition.skip = cat(1, allTimes.condition.skip, repmat(strmatch(sd.keys.Condition,conditions,'exact'), nSkip, 1));        
    
    % add today's work for EnterTime
    keep = ~isnan(sd.taskEvents.EnterTime);
    nEnter = length(sd.taskEvents.EnterTime(keep));
    
    allTimes.time.enter = cat(1, allTimes.time.enter, sd.taskEvents.EnterTime(keep));
    allTimes.offer.enter = cat(1, allTimes.offer.enter, sd.taskEvents.Offer(keep));
    allTimes.mouse.enter = cat(1, allTimes.mouse.enter, repmat(myID, nEnter,1));
    allTimes.flavor.enter = cat(1, allTimes.flavor.enter, sd.taskEvents.Flavor(keep));
    allTimes.day.enter = cat(1, allTimes.day.enter, repmat(sd.keys.DayOfStudy,nEnter,1));
    allTimes.condition.enter = cat(1, allTimes.condition.enter, repmat(strmatch(sd.keys.Condition,conditions,'exact'), nEnter, 1));        
    


  
    
    
    % add today's work for EnterToQuit
    keep = ~isnan(sd.taskEvents.QuitTime);
    nenterToQuitTime = length(sd.taskEvents.EnterTime(keep));
            
    allTimes.time.enterToQuit = cat(1, allTimes.time.enterToQuit, sd.taskEvents.EnterTime(keep));
    allTimes.offer.enterToQuit = cat(1, allTimes.offer.enterToQuit, sd.taskEvents.Offer(keep));
    allTimes.mouse.enterToQuit = cat(1, allTimes.mouse.enterToQuit, repmat(myID, nenterToQuitTime,1));
    allTimes.flavor.enterToQuit = cat(1, allTimes.flavor.enterToQuit, sd.taskEvents.Flavor(keep));
    allTimes.day.enterToQuit = cat(1, allTimes.day.enterToQuit, repmat(sd.keys.DayOfStudy,nenterToQuitTime,1));
        
    
    
    
    % add today's work for EnterToEarn
    keep = ~isnan(sd.taskEvents.EarnTime);
    nenterToEarnTime = length(sd.taskEvents.EnterTime(keep));
    
    allTimes.time.enterToEarn = cat(1, allTimes.time.enterToEarn, sd.taskEvents.EnterTime(keep));
    allTimes.offer.enterToEarn = cat(1, allTimes.offer.enterToEarn, sd.taskEvents.Offer(keep));
    allTimes.mouse.enterToEarn = cat(1, allTimes.mouse.enterToEarn, repmat(myID, nenterToEarnTime,1));
    allTimes.flavor.enterToEarn = cat(1, allTimes.flavor.enterToEarn, sd.taskEvents.Flavor(keep));
    allTimes.day.enterToEarn = cat(1, allTimes.day.enterToEarn, repmat(sd.keys.DayOfStudy,nenterToEarnTime,1));
        
        
  
    
    % add today's work for QuitTime   
    keep = ~isnan(sd.taskEvents.QuitTime);
    nQ = length(sd.taskEvents.QuitTime(keep));
    
    allTimes.time.quit = cat(1, allTimes.time.quit, sd.taskEvents.QuitTime(keep));
    allTimes.offer.quit = cat(1, allTimes.offer.quit, sd.taskEvents.Offer(keep));
    allTimes.mouse.quit = cat(1, allTimes.mouse.quit, repmat(myID, nQ,1));
    allTimes.flavor.quit = cat(1, allTimes.flavor.quit, sd.taskEvents.Flavor(keep));
    allTimes.day.quit = cat(1, allTimes.day.quit, repmat(sd.keys.DayOfStudy,nQ,1));
    
    
    
    
    % add today's work for EarnTime   
    keep = ~isnan(sd.taskEvents.EarnTime);
    nEarn = length(sd.taskEvents.EarnTime(keep));
    
    allTimes.time.earn = cat(1, allTimes.time.earn, sd.taskEvents.EarnTime(keep));
    allTimes.offer.earn = cat(1, allTimes.offer.earn, sd.taskEvents.Offer(keep));
    allTimes.mouse.earn = cat(1, allTimes.mouse.earn, repmat(myID, nEarn,1));
    allTimes.flavor.earn = cat(1, allTimes.flavor.earn, sd.taskEvents.Flavor(keep));
    allTimes.day.earn = cat(1, allTimes.day.earn, repmat(sd.keys.DayOfStudy,nEarn,1));
    

    
    % add today's work for WorkTime   
    keep = ~isnan(sd.taskEvents.WorkTime);
    nW = length(sd.taskEvents.WorkTime(keep));
    allTimes.time.work = cat(1, allTimes.time.work, sd.taskEvents.WorkTime(keep));
    allTimes.offer.work = cat(1, allTimes.offer.work, sd.taskEvents.Offer(keep));
    allTimes.mouse.work = cat(1, allTimes.mouse.work, repmat(myID, nW,1));
    allTimes.flavor.work = cat(1, allTimes.flavor.work, sd.taskEvents.Flavor(keep));
    allTimes.day.work = cat(1, allTimes.day.work, repmat(sd.keys.DayOfStudy,nW,1));
 

    
end

    function FillOneElement(keep, n, t)
        allTimes.time.skip = cat(1, allTimes.time.skip, sd.taskEvents.SkipTime(keep));
    allTimes.offer.skip = cat(1, allTimes.offer.skip, sd.taskEvents.Offer(keep));
    allTimes.mouse.skip = cat(1, allTimes.mouse.skip, repmat(myID, nSkip,1));
    allTimes.flavor.skip = cat(1, allTimes.flavor.skip, sd.taskEvents.Flavor(keep));
    allTimes.day.skip = cat(1, allTimes.day.skip, repmat(sd.keys.DayOfStudy,nSkip,1));
    allTimes.condition.skip = cat(1, allTimes.condition.skip, repmat(strmatch(sd.keys.Condition,conditions,'exact'), nSkip, 1));        
    end
 
end % function 