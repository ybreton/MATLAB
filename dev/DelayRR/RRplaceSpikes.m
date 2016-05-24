function [H,sd] = RRplaceSpikes(sd,varargin)
% Returns 2D histogram of spike places on maze.
% H = RRplaceSpikes(sd)
% where     H       is xBins x yBins x nClu matrix of 2D histogram values
%           
%           sd      is a standard session data structure for restaurant
%                       row.
%
% [H,sd] = RRplaceSpikes(sd)
% will add field 
%
% OPTIONAL ARGUMENTS:
% ******************
% xBins     (default 48)    number of bins for x position
% yBins     (default 32)    number of bins for y position
%
%

xBins = 48;
yBins = 32;
process_varargin(varargin);

SSN = sd(1).ExpKeys.SSN;
disp(['Accumulating 2D place histogram, SSN ' SSN]);
nS = length(sd(1).S);
disp([num2str(nS) ' spike clusters.'])

X = sd.x;
Y = sd.y;
T = X.range;
x0 = X.data;
y0 = Y.data;
idnan = isnan(X.data)|isnan(Y.data);
T0 = T(~idnan);
X0 = x0(~idnan);
Y0 = y0(~idnan);
xScale = linspace(0,720,xBins);
yScale = linspace(0,480,yBins);

H = nan(yBins,xBins,nS);
for iS = 1 : length(sd.S);
    fn = sd.fn{iS};
    disp(fn);
    S = sd.S{iS};
    
    Stimes = S.range;
    Mx = nan(length(Stimes),1);
    My = nan(length(Stimes),1);
    for iT = 1 : length(Stimes)
        dev = abs(Stimes(iT)-T0);
        [~,id] = min(dev);
        id = round(mean(id));
        Mx(iT) = X0(id);
        My(iT) = Y0(id);
    end

    h = histcn([Mx My],xScale,yScale);
    H(:,:,iS) = h';
end

if nargout>1
    if length(sd)>1
        for iSubsess = 1 : length(sd)-1
            timeOnTrack(iSubsess) = sd(iSubsess).SessionStartTime;
            timeOffTrack(iSubsess) = sd(iSubsess+1).SessionStartTime;
        end
        timeOnTrack(length(sd)) = sd(iSubsess).SessionStartTime;
        timeOffTrack(length(sd)) = sd(end).ExpKeys.TimeOffTrack+sd.x.dt;
        
        for iSubsess = 1 : length(sd)
            H = nan(yBins,xBins,nS);
            for iS = 1 : length(sd.S)
                fn = sd.fn{iTT};
                disp(fn);
                S = sd.S(iTT);

                Stimes = S.range;
                idSubsess = Stimes>=timeOnTrack(iSubsess) & Stimes<timeOffTrack(iSubsess);
                Stimes = Stimes(idSubsess);
                Mx = nan(length(Stimes),1);
                My = nan(length(Stimes),1);
                for iT = 1 : length(Stimes)
                    dev = abs(Stimes(iT)-T0);
                    [~,id] = min(dev);
                    id = round(mean(id));
                    Mx(iT) = X0(id);
                    My(iT) = Y0(id);
                end

                h = histcn([Mx My],xScale,yScale);
                H(:,:,iS) = h';
            end
            sd(iSubsess).firingPlaceHist = H;
        end
    else
        sd.firingPlaceHist = H;
    end
end