function handlingTime = RRGetHandlingTime(sdfn,varargin)
%
%
%
%

maxLaps = 200;
process_varargin(varargin);

handlingTime = nan(size(sdfn,1),maxLaps*4);
nc = 0;
for f = 1 : size(sdfn,1)
    fd = fileparts(sdfn{f});
    pushdir(fd);
    
    load(sdfn{f})
    sg = RRGetStaygo(sdfn{f});
    k = 0;
    for trial = 1 : length(sd.EnteringZoneTime)-1
        if sg(trial)==1
            k = k+1;
            t0 = sd.FeederTimes(k);
            t1 = sd.EnteringZoneTime(trial+1);
            
            handlingTime(f,trial) = t1-t0;
        end
    end
    nc = max(nc,length(sd.EnteringZoneTime));
    
    popdir;
end

handlingTime = handlingTime(:,1:nc);