function sd = RRregret(sd)
% Adds fields for logical instances of regret and each disappointment control.
% regret: Last-Skipped Good/Now-Gets Bad
% disapp1: Last-Stayed Good/Now-Gets Bad
% disapp2: Last-Skipped Bad/Now-Gets Bad
% Also adds list of trial indices on which events happened.

nT = length(sd.EnteringZoneTime);
sd.stayGo = RRGetStaygo(sd);
sd.shouldSkip = RRIdentifyShouldSkip(sd);
sd.shouldStay = RRIdentifyShouldStay(sd);

sd.stayGo = sd.stayGo(1:nT);
sd.shouldSkip = sd.shouldSkip(1:nT);
sd.shouldStay = sd.shouldStay(1:nT);

sd.regret = nan(1,nT);
sd.disapp1 = nan(1,nT);
sd.disapp2 = nan(1,nT);

sd.regret(2:nT) = (sd.shouldStay(1:nT-1)==1&sd.stayGo(1:nT-1)==0)&sd.shouldSkip(2:nT)==1;
sd.disapp1(2:nT) = (sd.shouldStay(1:nT-1)==1&sd.stayGo(1:nT-1)==1)&sd.shouldSkip(2:nT)==1;
sd.disapp2(2:nT) = (sd.shouldSkip(1:nT-1)==1&sd.stayGo(1:nT-1)==0)&sd.shouldSkip(2:nT)==1;

sd.RegretTrials = find(sd.regret==1);
sd.Disapp1Trials = find(sd.disapp1==1);
sd.Disapp2Trials = find(sd.disapp2==1);
