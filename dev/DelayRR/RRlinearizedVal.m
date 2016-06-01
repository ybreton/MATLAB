function L = RRlinearizedVal(sd,x,y,varargin)
% Converts the (x,y) position obtained at time t to a linearized version L
% using the sd.Linearized data in sd.
% L = RRlinearizedVal(sd,t,x,y)

trialTypeField = 'stayGo';
trialTypeList = [0 1];
trialTypes = {'Skip' 'Stay'};
debug = false;
process_varargin(varargin);

CoM = [sd.World.MazeCenter.x, sd.World.MazeCenter.y];
Entry = [sd.World.ZoneLocations.x(:), sd.World.ZoneLocations.y(:)];
Feeder = [sd.World.FeederLocations.x(:), sd.World.FeederLocations.y(:)];
nextX = sd.World.ZoneLocations.x([2:end, 1]);
nextY = sd.World.ZoneLocations.y([2:end, 1]);
Exit = [nextX(:), nextY(:)];

L = nan(length(x),1);
D = nan(length(x),size(Feeder,1),2);
P = nan(length(x),size(Feeder,1),2);
for iD=1:length(x)
    for iZ=1:size(Feeder,1)
        TF = Feeder(iZ,:) - Entry(iZ,:);
        N1 = TF/norm(TF);

        TX = Exit(iZ,:) - Feeder(iZ,:);
        N2 = TX/norm(TX);

        xy1 = [x(iD) y(iD)] - Entry(iZ,:);
        xy2 = [x(iD) y(iD)] - Feeder(iZ,:);

        p1 = xy1*N1';
        p2 = xy2*N2';

        r1 = (xy1 - repmat(p1,[1 size(TF,2)]).*repmat(N1,[size(xy1,1) 1]));
        r2 = (xy2 - repmat(p2,[1 size(TX,2)]).*repmat(N2,[size(xy2,1) 1]));

        d1 = norm(r1);
        d2 = norm(r2);
        
        % Make distances infinite if angle of xy is not between entry angle
        % and exit angle with respect to CoM.
        PhiEntry = atan2(Entry(iZ,2)-CoM(2), Entry(iZ,1)-CoM(1));
        PhiXY = atan2(y(iD)-CoM(2), x(iD)-CoM(1));
        PhiExit = atan2(Exit(iZ,2)-CoM(2), Exit(iZ,1)-CoM(1));
        Phi2 = wrapToPi(PhiExit-PhiEntry);
        Phi1 = wrapToPi(PhiXY-PhiEntry);
        if Phi1>Phi2 || Phi1<0
            d1 = inf;
            d2 = inf;
        end
        

        A = (p1/norm(TF))*0.5+iZ;
        B = (p2/norm(TX))*0.5+0.5+iZ;
        
        if debug
            clf
            hold on
            plot(x(iD),y(iD),'ko','markerfacecolor','k')
            plot(Entry(iZ,1),Entry(iZ,2),'go','markerfacecolor','g')
            plot(Feeder(iZ,1),Feeder(iZ,2),'bx','markerfacecolor','b')
            plot(Exit(iZ,1),Exit(iZ,2),'rs','markerfacecolor','r')
            quiver(Entry(iZ,1),Entry(iZ,2),TF(1), TF(2), 'color', 'g')
            quiver(Feeder(iZ,1),Feeder(iZ,2), TX(1), TX(2), 'color', 'r')
            quiver(x(iD),y(iD),r1(1),r1(2), 'color', 'k', 'linestyle', '--')
            quiver(x(iD),y(iD),r2(1),r2(2), 'color', 'k', 'linestyle', '--')
            xlim([0 720])
            ylim([0 480])
            set(gca,'xtick',[])
            set(gca,'ytick',[])
            set(gca,'xcolor','w')
            set(gca,'ycolor','w')
            hold off
            drawnow
        end

        D(iD,iZ,1) = d1;
        D(iD,iZ,2) = d2;
        P(iD,iZ,1) = A;
        P(iD,iZ,2) = B;
    end
    D0 = squeeze(D(iD,:));
    P0 = squeeze(P(iD,:));
    [~,I] = min(D0,[],2);
    L(iD) = P0(I);
end
L(L<1) = L(L<1)-1+5;
L(L>5) = L(L>5)-5+1;
