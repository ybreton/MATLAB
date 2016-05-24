function sd = sdRegret(sd,varargin)
% Adds fields to standard data structure 
%   isregret        with boolean indicating regret instance,
%                       LastSkipped & Last<Thresh-window & Current>Thresh+window
%   isregretCtl1    with boolean indicating disappointment instance controlling
%                       for the same action (bad luck)
%                       LastSkipped & Last>Thresh+window & Current>Thresh+window
%   isregretCtl2    with boolean indicating disappointment instance controlling
%                       for the same reward (true disappointment)
%                       ~LastSkipped& Last<Thresh-window & Current>Thresh+window
% OPTIONAL ARGUMENTS:
% ******************
% window            (default 1)
%   minimum deviation of delay from threshold to be counted as "good" or
%   "bad".
%

window = 1;
process_varargin(varargin);

sd = sdThresholds(sd);

V = sd.threshold(:)-sd.ZoneDelay(:);
% V will be positive for good offers, negative for bad offers.

lastV = V(1:end-1);
curV = V(2:end);
lastSG = sd.stayGo(1:end-1);
lastSG = lastSG(:);

% regret: 
%   skipped last, last was good deal, current offer bad
sd.isregret =     [nan; (lastSG==0) & (lastV > window) & (curV < -window)];
% regretCtl1 (bad luck): 
%   skipped last, last was bad deal, current offer bad deal
sd.isregretCtl1 = [nan; (lastSG==0) & (lastV < -window)  & (curV < -window)];
% regretCtl2 (true disappointment):
%   stayed last, last was good deal, current offer bad
sd.isregretCtl2 = [nan; (lastSG==1) & (lastV > window) & (curV < -window)];