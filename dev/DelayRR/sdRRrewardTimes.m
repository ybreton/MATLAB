function sdOut = sdRRrewardTimes(sd)
% Returns a 1 x nTrials vector of times reward was delivered (sd.rewardTime) 
% a 1 x nTrials vector of reward type delivered (sd.rewardType)
% a 1 x nTrials vector of reward amount delivered (sd.rewardQty)

for f = 1:length(sd)
    sd0 = sd(f);
    
    sd0.rewardTime = nan(1,length(sd0.stayGo));
    sd0.rewardType = nan(1,length(sd0.stayGo));
    sd0.rewardQty = zeros(1,length(sd0.stayGo));
        
    sd0.rewardTime(sd0.stayGo==1) = sd0.FeederTimes;
    sd0.rewardType(sd0.stayGo==1) = sd0.FeedersFired;
    sd0.rewardQty(sd0.stayGo==1) = sd0.nPellets(sd0.stayGo==1);
    
    sdOut(f) = sd0;
end