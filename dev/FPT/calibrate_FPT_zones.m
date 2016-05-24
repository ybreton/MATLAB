function XY = calibrate_FPT_zones(varargin)
%
%
%
%
InZoneDistance = 60+10;
nZones = 1;
process_varargin(varargin);

fn = FindFile('*.mp4');
if isempty(fn)
    fn = FindFiles('*.mpg');
    for f = 1 : length(fn)
        try
            vObj = VideoReader(fn{f});
            fn = fn{f};
        end
    end
    if isempty(vObj)
        disp('Cannot open video file.')
    end
else
    vObj = VideoReader(fn);
end

vt = FindFile('*-vt.mat');
vt = load(vt);
RatX = vt.x.restrict(min(vt.x.range),min(vt.x.range)+10);
RatY = vt.y.restrict(min(vt.y.range),min(vt.y.range)+10);


[pn,SSN] = fileparts(fn);


for fr = 1 : 10
    cData(:,:,:,fr) = read(vObj,fr);
end
im = (mean(cData,4));
im = im./255;

imagesc(im)
hold on
scatterplotc(RatX.data,RatY.data,RatX.range);
title(sprintf('%s',SSN),'interpreter','none')
lastX = nan;
lastY = nan;
axis equal
set(gca,'xlim',[0 720])
set(gca,'ylim',[0 480])
hold off
XY = nan(nZones,2);
cmap = hsv(nZones);

for n = 1 : nZones
    done = false;
    while ~done
        [x,y,btn]=ginput(1);
        clf
        imagesc(im)
        hold on
        scatterplotc(RatX.data,RatY.data,RatX.range);
        axis equal
        title(sprintf('%s',SSN),'interpreter','none')
        
        for z = 1 : n
            ch=circle([XY(z,1) XY(z,2)],InZoneDistance,1000,'-');
            set(ch,'color',cmap(z,:))
            text(XY(z,1),XY(z,2),sprintf('%d',z),'verticalalignment','middle','horizontalalignment','center','color',cmap(z,:))
        end
        hold off
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        axis equal

        if btn==3
            done = true;
            XY(n,:) = [lastX lastY];
        end
        if btn==1
            lastX = x;
            lastY = y;
            hold on
            circle([x y],InZoneDistance,1000,'w-');
            plot(x,y,'wo','markerfacecolor','w')
            hold off
            axis equal
            set(gca,'xlim',[0 720])
            set(gca,'ylim',[0 480])
        end
    end
    
end

clf
imagesc(im)
title(sprintf('%s',SSN),'interpreter','none')
hold on
for z = 1 : nZones
    ch=circle([XY(z,1) XY(z,2)],InZoneDistance,1000,'-');
    set(ch,'color',cmap(z,:))
    text(XY(z,1),XY(z,2),sprintf('%d',z),'verticalalignment','middle','horizontalalignment','center','color',cmap(z,:))
end
hold off
axis equal
set(gca,'xlim',[0 720])
set(gca,'ylim',[0 480])