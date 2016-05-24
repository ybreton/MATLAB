function [VTE,AllIdPhi,z,I] = ProbRR_VTE_4x20(varargin)
%
%
%
%
%

%%%%%%%%%%%%%%%%%%%
% VARARGIN
%
% 'ds'  directories to search and analyze.
%%%%%%%%%%%%%%%%%%%

fn = FindFiles('R*-*-vt1.mat');
for f = 1 : length(fn)
    ds{f} = fileparts(fn{f});
end
ds = unique(ds);

process_varargin(varargin);


AllIdPhi = [];
for d = 1 : length(ds)
    cur_dir = ds{d};
    pushdir(cur_dir);
    id = max(regexpi('\',cur_dir));
    SSN = cur_dir(id+1:end);
    
    fn = FindFiles('*-vt1.mat');
    entire_session = aggregate_subsessions('RR');
    load(fn{1})
    % timestamps not sorted.
    Tx = sort(x.range);
    Ty = sort(y.range);
    x = tsd(Tx,x.data);
    y = tsd(Ty,y.data);
    
    % Vector of start and stop times for each choice point.
    lastZone = nan;
    tStart = [];
    tStop = [];
    pellets = [];
    probability = [];
    entered = [];
    skipped = [];
    for c = 1 : length(entire_session.data.ZoneIn)-1
        curZone = entire_session.data.ZoneIn(c);
        if entire_session.data.ZoneIn(c)<10 % Zone entered.
            tStart = [tStart entire_session.data.EnteringZoneTime(c)*1e-6];
            tStop = [tStop entire_session.data.EnteringZoneTime(c+1)*1e-6];
            pellets = [pellets entire_session.data.ZonePellets(c)];
            probability = [probability entire_session.data.ZoneProbability(c)];
            entered = [entered entire_session.data.ZoneIn(c+1)>10];
            skipped = [skipped entire_session.data.ZoneIn(c+1)<10];
            lastZone = curZone;
        end
    end
    sd.EnteringCPTime = tStart;
    sd.ExitingCPTime = tStop;
    sd.x = x;
    sd.y = y;
    
    sd = zIdPhi(sd);
    z = sd.zIdPhi;
    I = sd.IdPhi;
    AllIdPhi = [AllIdPhi; I(:)];
    
    VTE(d).NAME = SSN;
    VTE(d).HEADER = {'SESSION NUMBER' 'Pr' 'Nr' 'Entered' 'Skipped' 'IdPhi' 'zIdPhi'};
    VTE(d).DATA = [ones(length(z),1) probability(:) pellets(:) double(entered(:)) double(skipped(:)) I(:) z(:)];
    
    popdir;
end