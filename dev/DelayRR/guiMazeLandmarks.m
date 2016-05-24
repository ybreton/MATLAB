function landmarks = guiMazeLandmarks(sd)
% Returns a nLandmark x 1 cell array of x and y coordinates of landmarks
% and landmark names.
% Right click to place a landmark. Left click to confirm. Enter to stop.

x = sd.x.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
y = sd.y.restrict(sd.ExpKeys.TimeOnTrack,sd.ExpKeys.TimeOffTrack);
sd.x =x;
sd.y =y;
sd=SmoothPath(sd);
x = sd.x;
y = sd.y;
x = x.removeNaNs;
y = y.removeNaNs;
dx = dxdt(x);
dy = dxdt(y);

done=false;
landmarkX = [];
landmarkY = [];
landmarkName = {};
lastLandmarkX = [];
lastLandmarkY = [];
while ~done
    cmap = jet(length(landmarkX));
    clf
    hold on
    if ~isempty(lastLandmarkX)
        plot(lastLandmarkX,lastLandmarkY,'ko','markerfacecolor','k')
    end
    plot(x.data,y.data,'.','color',[0.7 0.7 0.7]);
    quiver(x.data(min(x.range)),y.data(min(y.range)),dx.data(min(x.range)),dy.data(min(y.range)));
    if ~isempty(landmarkX)
        ph=nan(length(landmarkX),1);
        for iL=1:length(landmarkX)
            ph(iL)=plot(landmarkX(iL),landmarkY(iL),'o','markerfacecolor',cmap(iL,:),'markeredgecolor',cmap(iL,:));
        end
        lh=legend(ph,landmarkName);
        set(lh,'location','northeastoutside')
    end
    title(['Entering landmarks for ' sd.ExpKeys.SSN])
    
    [x0,y0,button]=ginput(1);
    if isempty(button)
        done=true;
    else
        if button==1
            landmarkX = [landmarkX; x0];
            landmarkY = [landmarkY; y0];
            landmarkName{end+1} = input(['Name of landmark ' num2str(length(landmarkX)) ':'],'s');
            lastLandmarkX = [];
            lastLandmarkY = [];
        end
        if button==3
            lastLandmarkX = x0;
            lastLandmarkY = y0;
        end
    end
end
