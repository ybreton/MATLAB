function sdOut = RRsdAnalysis(sd,varargin)
% Runs through the gamut of sd = fcn(sd) functions for restaurant row.
% Fieldnames:
%         EnteringCPTime: [1xTrials double]
%       EnteringZoneTime: [1xTrials double]
%           ExitZoneTime: [1xTrials double]
%          ExitingCPTime: [1xTrials double]
%                ExpKeys: [1x1 struct]
%            FeederDelay: [1xTrials double]
%             FeederList: [1xTrials double]
%            FeederTimes: [1xTrials double]
%             FeederTone: 1000
%     FeederToneIncrease: 250
%           FeedersFired: [1xRewards double]
%                  IdPhi: [Trialsx1 double]
%         InZoneDistance: 230
%                   Laps: [1xTrials double]
%           NextZoneTime: [1xTrials double]
%                      S: {Cellsx1 cell}
%         SessionEndTime: 1.5265e+04
%       SessionStartTime: 1.1670e+04
%        SubsessOffTrack: 1.5265e+04
%         SubsessOnTrack: 1.1670e+04
%             Subsession: 1
%             Thresholds: [1xTrials double]
%           ToneDuration: 0.1000
%              ToneTimes: [1xTones double]
%              TotalLaps: 50
%           TotalPellets: 228
%                 Weight: 287.8000
%                  World: [1x1 struct]
%              ZoneDelay: [1xTrials double]
%                 ZoneIn: [1xTrials double]
%              curvature: [1x1 tsd]
%                curvmax: [Trialsx1 double]
%               curvtime: [Trialsx1 double]
%                     fc: {Cellsx1 cell}
%                     fn: {1xCells cell}
%               isNotVTE: [Trialsx1 logical]
%                  isVTE: [Trialsx1 logical]
%               isregret: [Trialsx1 double]
%           isregretCtl1: [Trialsx1 double]
%           isregretCtl2: [Trialsx1 double]
%           maxTimeToRun: 3600
%               nPellets: [1xTrials double]
%                  skips: 89
%                 stayGo: [1xTrials double]
%              threshold: [Trialsx1 double]
%                  value: [Trialsx1 double]
%                      x: [1x1 tsd]
%                      y: [1x1 tsd]
%                 zIdPhi: [Trialsx1 double]
%             zoneThresh: [17.5000 14 3 25]
%                zonetsd: [1x1 tsd]
%                Flavors: {'Cherry'  'Banana'  'Plain'  'Chocolate'}
%           MADthreshold: 6.0511
%        MEDIANthreshold: 17.4670
%      MARGINALthreshold: 17.6415
%           pelletEarned: [1xTrials double]
%               sessTime: 3.5943e+03
%                   RtRf: 0.0634
%             cumPellets: [1xTrials double]
%               instRtRf: [Trialsx1 double]
%              mazeTheta: [1x1 tsd]
%             mazeRadius: [1x1 tsd]
%                  px2cm: 0.2819
%                  cm2px: 3.5476
%                    xcm: [1x1 tsd]
%                    ycm: [1x1 tsd]
%                     dx: [1x1 tsd]
%                     dy: [1x1 tsd]
%                    ddx: [1x1 tsd]
%                    ddy: [1x1 tsd]
%                      v: [1x1 tsd]
%                      a: [1x1 tsd]
%                      C: [1x1 tsd]
%                ctltime: [1xTrials double]
%           maxcurvangle: [Trialsx1 double]
%             Linearized: [1x1 struct]

threshVTE = 0.5; % minimum zIdPhi of VTE lap
flavors = {'Cherry' 'Banana' 'Plain' 'Chocolate'};
process_varargin(varargin);

sd0 = sd;
for iSess=1:length(sd0)
    if length(sd0)>1
        fprintf('Sub-session %.0f\n',iSess);
    else
        disp('Single-session restaurant row:')
    end
    sd = sd0(iSess);
    
    sd.Flavors = flavors;
    
    disp('Threshold...')
    sd = sdHeavisideSigmoidHybrid(sd);
    
    disp('MAD, median, and zone-marginal...')
    sd.MADthreshold = nanmad(unique(sd.threshold));
    sd.MEDIANthreshold = nanmedian(unique(sd.threshold));
    sd.MARGINALthreshold = fitHeavisideSigmoidHybrid(sd.ZoneDelay(:),sd.stayGo(:));
    
    disp('Reinforcement rate...')
    sd = sdRtRf(sd);
    
    disp('Angle and radius about annularized maze...')
    x = tsd(sd.x.range,sd.x.data-sd.World.MazeCenter.x);
    y = tsd(sd.y.range,sd.y.data-sd.World.MazeCenter.y);
    sd.mazeTheta = tsd(x.range, atan2(y.data,x.data));
    sd.mazeRadius= tsd(x.range, sqrt(x.data.^2+y.data.^2));
    
    disp('Calculate x and y in cm...')
    sd.px2cm = RRpx2cm(sd,1);
    sd.cm2px = 1./sd.px2cm;
    sd.xcm = tsd(sd.x.range,sd.x.data*sd.px2cm);
    sd.ycm = tsd(sd.y.range,sd.y.data*sd.px2cm);
    
    nxbins = round(max(sd.xcm.data)-min(sd.xcm.data))/4; % 4cm per bin
    nybins = round(max(sd.ycm.data)-min(sd.ycm.data))/4; % 4cm per bin
    
    disp('Velocity and acceleration...')
    sd = sdVelocity(sd);

    disp('Curvature...')
    sd = sdCurvature(sd);

    disp('Time of max curvature...')
    sd = sdMaxCurvature(sd);

    disp('Control time...')
    sd.ctltime = sd.EnteringZoneTime+(sd.ExitZoneTime-sd.EnteringZoneTime)/2;

    disp('Finding angle of maximum curvature...')
    sd = sdMaxcurvangle(sd);

    disp('Identifying regret instances...')
    sd = sdRegret(sd);
    fprintf('%.0f regret instances, %.0f instances of bad luck, %.0f true disappointment instances.\n',nansum(sd.isregret),nansum(sd.isregretCtl1),nansum(sd.isregretCtl2))

    disp('zIdPhi...')
    sd = zIdPhi(sd);

    disp('VTE...')
    sd.isVTE = sd.zIdPhi>threshVTE;
    sd.isNotVTE = sd.zIdPhi<=threshVTE;
    fprintf('%.0f VTE instances, %.0f non-VTE instances.\n',nansum(sd.isVTE),nansum(sd.isNotVTE))

    disp('Value...')
    sd.value = round((sd.threshold(:)-sd.ZoneDelay(:))*10)/10;

    disp('Zone occupancy tsd...')
    sd = sdZoneInTsd(sd,'Rtime',[0 5]);
    
    disp('Linearized position...')
    sd = sdRRlinearize(sd,'nxbins',nxbins,'nybins',nybins);
    
    sdOut(iSess) = sd;
end