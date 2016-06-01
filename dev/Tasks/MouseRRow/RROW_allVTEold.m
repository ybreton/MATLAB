function allVTE = RROW_allVTEold(fd, varargin)
% Wrapper to go through file directories and pull in staySkip proportions by flavor
% INPUT
%   fd = list of directories
% OUTPUT
%   

% variables
DayLimit = '';
process_varargin(varargin);
MouseLimit = '';
process_varargin(varargin);
ConditionLimit = '';
process_varargin(varargin);


% Build base
allVTE.flavors = {};
allVTE.mice = {};

allVTE.VTE.skip = [];
allVTE.offer.skip = [];
allVTE.mouse.skip = [];
allVTE.day.skip = [];
allVTE.flavor.skip = [];


allVTE.VTE.enter = [];
allVTE.offer.enter = [];
allVTE.mouse.enter = [];
allVTE.day.enter = [];
allVTE.flavor.enter = [];


allVTE.VTE.enterToQuit = [];
allVTE.offer.enterToQuit = [];
allVTE.mouse.enterToQuit = [];
allVTE.day.enterToQuit = [];
allVTE.flavor.enterToQuit = [];


allVTE.VTE.enterToEarn = [];
allVTE.offer.enterToEarn = [];
allVTE.mouse.enterToEarn = [];
allVTE.day.enterToEarn = [];
allVTE.flavor.enterToEarn = [];


allVTE.VTE.quit = [];
allVTE.offer.quit = [];
allVTE.mouse.quit = [];
allVTE.day.quit = [];
allVTE.flavor.quit = [];


allVTE.VTE.earn = [];
allVTE.offer.earn = [];
allVTE.mouse.earn = [];
allVTE.day.earn = [];
allVTE.flavor.earn = [];


allVTE.VTE.work = [];
allVTE.offer.work = [];
allVTE.mouse.work = [];
allVTE.day.work = [];
allVTE.flavor.work = [];








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
    myID = find(strcmp(mouseName, allVTE.mice));
    if isempty(myID)
        allVTE.mice{end+1} = mouseName;
        myID = length(allVTE.mice);
    end
        
    % get and check flavors
    if isempty(allVTE.flavors)
        allVTE.flavors = sd.keys.Flavors;
    else
        assert(all(strcmp(allVTE.flavors, sd.keys.Flavors)));
    end
    
      
    
    sd.RROW_zIdPhi = RROW_zIdPhi(sd);
    
    
    % add today's work for SkipTime
    keep = ~isnan(sd.taskEvents.SkipTime);
    nSkip = length(sd.taskEvents.SkipTime(keep));
    
    allVTE.VTE.skip = cat(1, allVTE.VTE.skip, sd.RROW_zIdPhi.zIdPhi(keep));
    allVTE.offer.skip = cat(1, allVTE.offer.skip, sd.taskEvents.Offer(keep));
    allVTE.mouse.skip = cat(1, allVTE.mouse.skip, repmat(myID, nSkip,1));
    allVTE.flavor.skip = cat(1, allVTE.flavor.skip, sd.taskEvents.Flavor(keep));
    allVTE.day.skip = cat(1, allVTE.day.skip, repmat(sd.keys.DayOfStudy,nSkip,1));
        
    
    % add today's work for EnterTime
    keep = ~isnan(sd.taskEvents.EnterTime);
    nEnter = length(sd.taskEvents.EnterTime(keep));
    
    allVTE.VTE.enter = cat(1, allVTE.VTE.enter, sd.RROW_zIdPhi.zIdPhi(keep));
    allVTE.offer.enter = cat(1, allVTE.offer.enter, sd.taskEvents.Offer(keep));
    allVTE.mouse.enter = cat(1, allVTE.mouse.enter, repmat(myID, nEnter,1));
    allVTE.flavor.enter = cat(1, allVTE.flavor.enter, sd.taskEvents.Flavor(keep));
    allVTE.day.enter = cat(1, allVTE.day.enter, repmat(sd.keys.DayOfStudy,nEnter,1));
    


  
    
    
    % add today's work for EnterToQuit
    keep = ~isnan(sd.taskEvents.QuitTime);
    nenterToQuitTime = length(sd.taskEvents.EnterTime(keep));
            
    allVTE.VTE.enterToQuit = cat(1, allVTE.VTE.enterToQuit, sd.RROW_zIdPhi.zIdPhi(keep));
    allVTE.offer.enterToQuit = cat(1, allVTE.offer.enterToQuit, sd.taskEvents.Offer(keep));
    allVTE.mouse.enterToQuit = cat(1, allVTE.mouse.enterToQuit, repmat(myID, nenterToQuitTime,1));
    allVTE.flavor.enterToQuit = cat(1, allVTE.flavor.enterToQuit, sd.taskEvents.Flavor(keep));
    allVTE.day.enterToQuit = cat(1, allVTE.day.enterToQuit, repmat(sd.keys.DayOfStudy,nenterToQuitTime,1));
        
    
    
    
    % add today's work for EnterToEarn
    keep = ~isnan(sd.taskEvents.EarnTime);
    nenterToEarnTime = length(sd.taskEvents.EnterTime(keep));
    
    allVTE.VTE.enterToEarn = cat(1, allVTE.VTE.enterToEarn, sd.RROW_zIdPhi.zIdPhi(keep));
    allVTE.offer.enterToEarn = cat(1, allVTE.offer.enterToEarn, sd.taskEvents.Offer(keep));
    allVTE.mouse.enterToEarn = cat(1, allVTE.mouse.enterToEarn, repmat(myID, nenterToEarnTime,1));
    allVTE.flavor.enterToEarn = cat(1, allVTE.flavor.enterToEarn, sd.taskEvents.Flavor(keep));
    allVTE.day.enterToEarn = cat(1, allVTE.day.enterToEarn, repmat(sd.keys.DayOfStudy,nenterToEarnTime,1));
        
        
  
    
    % add today's work for QuitTime   
    keep = ~isnan(sd.taskEvents.QuitTime);
    nQ = length(sd.taskEvents.QuitTime(keep));
    
    allVTE.VTE.quit = cat(1, allVTE.VTE.quit, sd.RROW_zIdPhi.zIdPhi(keep));
    allVTE.offer.quit = cat(1, allVTE.offer.quit, sd.taskEvents.Offer(keep));
    allVTE.mouse.quit = cat(1, allVTE.mouse.quit, repmat(myID, nQ,1));
    allVTE.flavor.quit = cat(1, allVTE.flavor.quit, sd.taskEvents.Flavor(keep));
    allVTE.day.quit = cat(1, allVTE.day.quit, repmat(sd.keys.DayOfStudy,nQ,1));
    
    
    
    
    % add today's work for EarnTime   
    keep = ~isnan(sd.taskEvents.EarnTime);
    nEarn = length(sd.taskEvents.EarnTime(keep));
    
    allVTE.VTE.earn = cat(1, allVTE.VTE.earn, sd.RROW_zIdPhi.zIdPhi(keep));
    allVTE.offer.earn = cat(1, allVTE.offer.earn, sd.taskEvents.Offer(keep));
    allVTE.mouse.earn = cat(1, allVTE.mouse.earn, repmat(myID, nEarn,1));
    allVTE.flavor.earn = cat(1, allVTE.flavor.earn, sd.taskEvents.Flavor(keep));
    allVTE.day.earn = cat(1, allVTE.day.earn, repmat(sd.keys.DayOfStudy,nEarn,1));
    

    
    % add today's work for WorkTime   
    keep = ~isnan(sd.taskEvents.WorkTime);
    nW = length(sd.taskEvents.WorkTime(keep));
    
    allVTE.VTE.work = cat(1, allVTE.VTE.work, sd.RROW_zIdPhi.zIdPhi(keep));
    allVTE.offer.work = cat(1, allVTE.offer.work, sd.taskEvents.Offer(keep));
    allVTE.mouse.work = cat(1, allVTE.mouse.work, repmat(myID, nW,1));
    allVTE.flavor.work = cat(1, allVTE.flavor.work, sd.taskEvents.Flavor(keep));
    allVTE.day.work = cat(1, allVTE.day.work, repmat(sd.keys.DayOfStudy,nW,1));
 

    
end

end % function
