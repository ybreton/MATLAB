function ADs = compile_FPT_adjusting_delays(varargin)
%
%
%
%
%
%

process_varargin(varargin);

fn = FindFiles('*-sd.mat');
for f = 1 : length(fn)
    [pn,filename,ext] = fileparts(fn{f});
    pushdir(pn);
    
    load([filename ext])
    sd = add_logit_to_sd(sd);
    save([filename '-logit.mat'],'sd');
    
    popdir;
    
end

fn = FindFiles('*-sd-logit.mat');
LastRatName = '';
c = 0;
ADs(f,f) = struct('RatName','','PelletRatio',nan,'Threshold',nan,'Negative',0,'Unbiased',0);
for f = 1 : length(fn)
    [pn,filename,ext] = fileparts(fn{f});
    pushdir(pn);
    RatName = filename(1:4);
    if ~strcmp(RatName,LastRatName)
        c = c+1;
        r = 1;
        X = [];
        Y = [];
        clf
    else
        r = r+1;
    end
    
    load([filename ext])
    Laps = 1:length(sd.ZoneIn);
    D = sd.ZoneDelay(Laps>max(Laps)-20);
    % Delay on last 20 laps.
    D = D(sd.ZoneIn(Laps>max(Laps)-20)==sd.DelayZone);
    % Chosen delay on delayed side on last 20 laps.
    
    ADs(r,c).RatName = RatName;
    ADs(r,c).PelletRatio = round(10.^(abs(log10(sd.World.nPleft/sd.World.nPright))));
    
    ADs(r,c).Threshold = nanmean(D);
    ADs(r,c).Negative = sd.logit.b(2)<0;
    ADs(r,c).Unbiased = sum(double(sd.ZoneIn==sd.DelayZone))/length(sd.ZoneIn)>0.05 & sum(double(sd.ZoneIn==sd.DelayZone))/length(sd.ZoneIn)<0.95;
    ADs(r,c).InRange = ADs(r,c).Threshold<=30;
    LastRatName = RatName;
    popdir;
end
