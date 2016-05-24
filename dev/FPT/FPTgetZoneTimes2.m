function [EnteringZoneTime,ExitZoneTime] = FPTgetZoneTimes2(sd,varargin)
% Returns entering and exiting zone times inferred from sd.x, sd.y.
% Uses rectangular boxes for zone definitions.
%
%
%
debug = false;
process_varargin(varargin);
VertDistance = [sd.InZoneDistance(1) abs(sd.Coord.RF_y-sd.Coord.LF_y)/3 sd.InZoneDistance(3) sd.InZoneDistance(4)]; 
HorizDistance = [abs(sd.Coord.CP_x-sd.Coord.SoM_x)/3 abs(sd.Coord.CP_x-sd.Coord.SoM_x)/2 abs(sd.Coord.CP_x-sd.Coord.SoM_x)/4 abs(sd.Coord.CP_x-sd.Coord.SoM_x)/4];
% y<=Zy+VertDistance & y>=Zy-VertDistance
% x<=Zx+HorizDistance & x>=Zx-HorizDistance
EnteringZoneTime = nan(4,sd.TotalLaps+1);
ExitZoneTime = nan(4,sd.TotalLaps+1);
lastZone = nan;
curZone = nan;
inZone = false;
exitZone = false;
lap = 0;
state = [1 1 0 0];
cmap = [0 1 0;
        0 0 1;
        1 0 0;
        1 0 0];

Zx = [sd.Coord.SoM_x;
      sd.Coord.CP_x;
      sd.Coord.RF_x;
      sd.Coord.LF_x];
Zy = [sd.Coord.SoM_y;
      sd.Coord.CP_y;
      sd.Coord.RF_y;
      sd.Coord.LF_y];

T = sd.x.range;
X = sd.x.data(T);
Y = sd.y.data(T);
idnan = isnan(X)|isnan(Y);
T = T(~idnan);
X = X(~idnan);
Y = Y(~idnan);
dt = sd.x.dt;
X0 = tsd(T,X);
Y0 = tsd(T,Y);

% d = sqrt((repmat(X,1,4)-repmat(Zx',length(X),1)).^2+(repmat(Y,1,4)-repmat(Zy',length(Y),1)).^2);
Z = FindZone(X,Y,Zx,Zy,VertDistance,HorizDistance);

lastOcc = nan;
for iT = 1 : length(T)
    x = X(iT);
    y = Y(iT);
%     D = d(iT,:);
    z = Z(iT,:);
    if ~isnan(x)&&~isnan(y)
        if debug
            clf
            plot(sd.x.data,sd.y.data,'-','color',[0.8 0.8 0.8])
            hold on
            plot(x,y,'k.')
            theta = linspace(-pi,pi,64);
            for iZ=1:length(Zx)
                x0 = Zx(iZ)+HorizDistance(iZ)*cos(theta);
                y0 = Zy(iZ)+VertDistance(iZ)*sin(theta);
                if state(iZ)==2
                    plot(x0,y0,'-','color',cmap(iZ,:),'linewidth',2);
                elseif state(iZ)==1
                    plot(x0,y0,'-','color',cmap(iZ,:),'linewidth',0.5);
                elseif state(iZ)==0
                    plot(x0,y0,':','color',cmap(iZ,:),'linewidth',0.5);
                end
            end
            hold off
            title(sprintf('Lap %.0f, Zone %.0f (last zone %.0f)\nT=%.2f',lap,curZone,lastZone,T(iT)));
            set(gca,'xlim',[0 720])
            set(gca,'ylim',[0 480])
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            drawnow
        end
        
%         I = find(D(:)<InZoneDistance);
        I = find(z);
        
        if numel(I)==1
            % one zone.
            if inZone
                curZone = I;
            end
            if lastOcc==3 && curZone==4 || lastOcc==4 && curZone==3
                lap = lap+1;
                state = [0 0 0 0];
                state(I) = 2;
                lastOcc = curZone;
            end
            if state(I)==1
                curZone = I;
                if curZone==1 || (lap==0 && isnan(lastZone) && curZone==2)
                    lap = lap+1;
                end
                EnteringZoneTime(I,lap) = T(iT);
                state = [0 0 0 0];
                state(I) = 2;
                inZone = true;
                exitZone = false;
                
                lastZone = curZone;
            end
        end
        if lastZone ~= curZone && ~isnan(lastZone)
            if state(lastZone)==2
                ExitZoneTime(lastZone,lap) = T(iT-1);
                lastOcc = lastZone;
            end
            
            state = [0 0 0 0];
            % prime the next zone:
            switch lastZone
                case 1
                    state(2) = 1;
%                     state(3) = 1;
%                     state(4) = 1;
                case 2
                    state(3) = 1;
                    state(4) = 1;
                case 3
                    state(1) = 1;
%                     state(4) = 1;
                case 4
                    state(1) = 1;
%                     state(3) = 1;
            end
            
        end
        
        if isempty(I)
            % limbo.
            curZone = nan;
        end
    end
end

% Now for special restrictions:
% - (x,y) into zone 2 (CP) must be 
%       x1>CP_x+InZoneDistance(2) x2<=CP_x+InZoneDistance(2), if moving right to left: CP_x < SoM_x
%       x1>CP_x-InZoneDistance(2) x2>=CP_x-InZoneDistance(2), if moving left to right: CP_x > SoM_x

for iLap=1:size(EnteringZoneTime,2)
    Tin = EnteringZoneTime(2,iLap);
    if ~isnan(Tin)
        x1 = nanmean(data(X0.restrict(Tin-2,Tin)));
        x2 = nanmean(data(X0.restrict(Tin,Tin+0.1)));

        if sd.Coord.CP_x<sd.Coord.SoM_x
            StartRight = x1>sd.Coord.CP_x+HorizDistance(2);
            EnterLeft = x2<=x1;
            if ~(StartRight&&EnterLeft)
                disp(['Entered CP from above or below on lap ' num2str(iLap)])
                EnteringZoneTime(iLap) = nan;
            end
        end
        if sd.Coord.CP_x>sd.Coord.SoM_x
            StartLeft = x1<sd.Coord.CP_x-HorizDistance(2);
            EnterRight = x2>=x1;
            if ~(StartLeft&&EnterRight)
                disp(['Entered CP from above or below on lap ' num2str(iLap)])
                EnteringZoneTime(iLap) = nan;
            end
        end
    end
end

function Zone = FindZone(x,y,Zx,Zy,VertDistance,HorizDistance)
% Returns nPos x nZones matrix.

LBx = repmat(x(:),1,length(Zx))>=repmat(Zx(:)'-HorizDistance(:)',length(x),1);
UBx = repmat(x(:),1,length(Zx))<=repmat(Zx(:)'+HorizDistance(:)',length(x),1);
LBy = repmat(y(:),1,length(Zy))>=repmat(Zy(:)'-VertDistance(:)',length(y),1);
UBy = repmat(y(:),1,length(Zy))<=repmat(Zy(:)'+VertDistance(:)',length(y),1);

Zone = LBx&UBx&LBy&UBy;

