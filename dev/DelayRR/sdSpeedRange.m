function sdOut = sdSpeedRange(sd,varargin)
% adds fields
% .maxSpeed             maximum finite (unsigned) speed
% .minSpeed             minimum nonzero (unsigned) speed
% .medianSpeed          median (unsigned) running speed
% .avgSpeed             average (unsigned) running speed
% to standard session data structure.
%
% OPTIONAL ARGUMENTS:
% ******************
% Enter = 'EnteringZoneTime';       Field with entering zone time
% Exit = 'ExitZoneTime';            Field with exiting zone time
% zeroSpeed = 0;                    Minimum nonzero speed, in px/sec
% infSpeed = inf;                   Maximum finite speed, in px/sec
% runMin = 10;                      Minimum running speed, in px/sec
% runMax = inf;                     Maximum running speed, in px/sec
%
Enter = 'EnteringZoneTime';
Exit = 'ExitZoneTime';
zeroSpeed = 0;
infSpeed = inf;
runMin = 10;
runMax = inf;
process_varargin(varargin);

for iS=1:length(sd)
    sd0 = sd(iS);
    
    nTrls = max(length(sd.(Enter)),length(sd.(Exit)));
    
    In = nan(nTrls,1);
    In(1:length(sd.(Enter))) = sd.(Enter);
    In = max(In,sd0.ExpKeys.TimeOnTrack);
    
    Out = nan(nTrls,1);
    Out(1:length(sd.(Exit))) = sd.(Exit);
    Out = min(Out,sd0.ExpKeys.TimeOffTrack);
    
    sd0.maxSpeed = nan(nTrls,1);
    sd0.minSpeed = nan(nTrls,1);
    sd0.medianSpeed = nan(nTrls,1);
    sd0.avgSpeed = nan(nTrls,1);
    
    dx = dxdt(sd0.x);
    dy = dxdt(sd0.y);
    
    for iTrl=1:length(In)
        vx = data(dx.restrict(In(iTrl),Out(iTrl)));
        vy = data(dy.restrict(In(iTrl),Out(iTrl)));
        speed = sqrt(vx.^2+vy.^2);
        
        if ~isempty(speed(speed<infSpeed))
            sd0.maxSpeed(iTrl) = nanmax(speed(speed<infSpeed));
        end
        if ~isempty(speed(speed>zeroSpeed))
            sd0.minSpeed(iTrl) = nanmin(speed(speed>zeroSpeed));
        end
        if ~isempty(speed(speed>runMin&speed<runMax))
            sd0.medianSpeed(iTrl) = nanmedian(speed(speed>runMin&speed<runMax));
            sd0.avgSpeed(iTrl) = nanmean(speed(speed>runMin&speed<runMax));
        end
    end
    
    sdOut(iS) = sd0;
end