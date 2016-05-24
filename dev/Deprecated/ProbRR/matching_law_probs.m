function [RReinf,RResp] = matching_law_probs(start_time,feeder_arm_times,feederProbability,pelletsDelivered,feeder_fire_times,varargin)
% According to Herrnstein's Matching Law,
% r1/(r1+r2) = Rf1/(Rf1+Rf2)
% where r1 and r2 are rates of responding, and
%       Rf1 and Rf2 are the obtained rates of reinforcement.
% A transformation of this is
% r1^A/(sum(ri^A)) = Rf1^A/(sum(Rfi^A))

nFeeders = 4;
probList = 0:0.1:1;
process_varargin(varargin);

for p = 1 : length(probList)
    id = feederProbability == probList(p);
    % the rate of reinforcement is A/delivery times.
    probFireTimes = feeder_fire_times(id);
    probPelletsGiven = pelletsDelivered(id);
    
    deltaT = diff([start_time(:);probFireTimes(:)]);
    RReinf(p).Prob = probList(p);
    RReinf(p).DATA = probPelletsGiven(:)./(deltaT(:)*1e-6);
    
    % the rate of responding is 1/entry times.
    probEntryTimes = feeder_arm_times(id);
    deltaT = diff([start_time(:);probEntryTimes(:)]);
    RResp(p).Prob = probList(p);
    RResp(p).DATA = 1./(deltaT*1e-6);
end