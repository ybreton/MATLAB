function fh = plot_matching_pred_probs(varargin)
%
%
%
%

nZones = 4;
process_varargin(varargin);

fn = FindFiles('RR-*.mat');

Rf(11).DATA = [];
r(11).DATA = [];
Rf(11).p = [];
r(11).p = [];
for f = 1 : length(fn)
    filename = fn{f};
    path = fileparts(filename);
    pushdir(path);
    
    vars = load(filename);
    
    start_time = vars.EnteringZoneTime(1);
    idInArm = vars.ZoneIn>10;
    fire_feeders = vars.FireFeeder(1:length(vars.EnteringZoneTime));
    feeder_arm_times = vars.EnteringZoneTime(idInArm&fire_feeders);
    feederProbability = vars.ZoneProbability(idInArm&fire_feeders);
    ArmZone = mod(vars.ZoneIn(idInArm&fire_feeders),10);
    if numel(vars.nPelletsPerDrop)==1
        nPelletsPerDrop = repmat(vars.nPelletsPerDrop,nZones,1);
    end
    for c = 1 : length(ArmZone)
        pelletsDelivered(c) = vars.nPelletsPerDrop(ArmZone(c));
    end
    feeder_fire_times = vars.FeederTimes;
    
    [RReinf,RResp] = matching_law_probs(start_time,feeder_arm_times,feederProbability,pelletsDelivered,feeder_fire_times);
    
    for p = 1 : length(RReinf)
        Rf(p).DATA = [Rf(p).DATA(:)' RReinf(p).DATA(:)'];
        Rf(p).Prob = RReinf(p).Prob;
    end
    for p = 1 : length(RResp)
        r(p).DATA = [r(p).DATA(:)' RResp(p).DATA(:)'];
    end
    
    popdir;
end

for p = 1 : length(Rf)
    obtained_rate_reinforcement(p) = mean(Rf(p).DATA,2);
    rate_of_responding(p) = mean(r(p).DATA,2);
    probs(p) = Rf(p).Prob;
end

relative_Rf = obtained_rate_reinforcement/sum(obtained_rate_reinforcement);
relative_rr = rate_of_responding/sum(rate_of_responding);

scatter(log10(obtained_rate_reinforcement),log10(rate_of_responding),20,probs)
caxis([probs(1) probs(end)])
cbh = colorbar;
set(get(cbh,'ylabel'),'string','Probability')
xlabel(sprintf('Log_{10} [Rate of Reinforcement]'))
ylabel(sprintf('Log_{10} [Rate of Response]'))
