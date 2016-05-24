function make_VTE_movie(sd,vtfn,varargin)

window = 1.5;
fps = 30;
% conversion = 1e-6;
% sdfn = FindFiles('*-sd-zIdPhi.mat','CheckSubdirs',false);
% sd = sdfn{1};
% load(sd);
% vtfn = 'VT1.mp4';
process_varargin(varargin);
sd = kludge_zone_times_FPT(sd);

fn = FindFiles(vtfn,'CheckSubdirs',false);
[pn, fn, ext] = fileparts(fn{1});
vtfn = [pn '\' fn ext];
smifn = [pn '\' fn '.smi'];

logIdPhi = log10(sd.IdPhi);

VR = VideoReader(vtfn);
FrameList = 1:VR.NumberOfFrames;
MovieTime = (FrameList)*(1./VR.FrameRate);
%%
F1(:,:,:) = read(VR,1);

[nlynxTS,syncTS] = get_smi_ts(smifn);
% syncTS says what the movie time is,
% nlynxTS says what it is in neuralynx.
CheetahTime = interp1(syncTS.range,nlynxTS.range,MovieTime);

% idHi = logIdPhi>2;
% idLow = logIdPhi<1.5;
% 

idHi = [18 23 117 153 183];
idLow = [21 87 114 189];

HighPassesIn = sd.EnteringCPTime(idHi);
HighPassesOut = sd.FeederTimes(idHi);
LowPassesIn = sd.EnteringCPTime(idLow);
LowPassesOut = sd.FeederTimes(idLow);

idHi = [18 23 117 153 183];
idLow = [21 87 114 189];

C = jet(window*fps+1);
C = C(end:-1:1,:);
stepSize = fps*window;
O = logspace(-0.1,-1.9,stepSize);
O = [1 O 0];
%%
VW = VideoWriter('VTE_movie.mp4','MPEG-4');
VW.FrameRate = 30;
open(VW);
%%
k = 1;
laps = 1:length(sd.EnteringCPTime);
highlaps = laps(idHi);
for pass = 1 : length(HighPassesIn)
    idPass = CheetahTime >= HighPassesIn(pass)-1 & CheetahTime <= HighPassesOut(pass)+1;
    lapnum = highlaps(pass);
    t = CheetahTime(idPass);
    x = sd.x.restrict(min(t),max(t));
    y = sd.y.restrict(min(t),max(t));
    xt = x.range;
    xd = x.data;
    yt = y.range;
    yd = y.data;
    for d = 1 : length(xd)
        s = max(1,d-2);
        f = min(length(xd),d+2);
        x0(d) = mean(xd(s:f));
        y0(d) = mean(yd(s:f));
    end
    x = tsd(xt(:),x0(:));
    y = tsd(yt(:),y0(:));
    Fr = FrameList(idPass);
    % Section showing trajectory
    for ifr = 1 : length(Fr)
        tFr = t(ifr);
        xFr = x.restrict(tFr-window,tFr);
        yFr = y.restrict(tFr-window,tFr);
        clf
        cla
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        hold on
        imshow(F1)
        th=text(720/2,0,sprintf('VTE, lap %d',lapnum));
        set(th,'verticalalignment','top')
        set(th,'horizontalalignment','center')
        set(th,'color','w')
        set(th,'fontname','Arial')
        set(th,'fontsize',16)
        mx = cos(0:0.01:2*pi)*4;
        my = sin(0:0.01:2*pi)*4;
        for d = length(xFr.data):-1:1
            od = length(xFr.data)-d+1;
            x0 = xFr.data;
            x0 = x0(d);
            y0 = yFr.data;
            y0 = y0(d);
            ch = patch(mx+x0,my+y0,[1 1 1],'facecolor',C(od,:));
            set(ch,'edgecolor','none')
        end
        hold off
        drawnow
        curFrame = getframe;
        writeVideo(VW,curFrame)
        writeVideo(VW,curFrame)
        k = k+1;
    end
    clf
    cla
    set(gca,'xlim',[0 720])
    set(gca,'ylim',[0 480])
    hold on
    imshow(F1)
    th=text(720/2,0,sprintf('VTE, lap %d',lapnum));
    set(th,'verticalalignment','top')
    set(th,'horizontalalignment','center')
    set(th,'color','w')
    set(th,'fontname','Arial')
    set(th,'fontsize',16)
    curFrame = getframe;
    for iti = 1 : VR.FrameRate
        writeVideo(VW,curFrame)
        writeVideo(VW,curFrame)
    end
    
    for ifr = 1 : length(Fr)
        tFr = t(ifr);
        xFr = x.restrict(tFr-window,tFr);
        yFr = y.restrict(tFr-window,tFr);
        clf
        cla
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        
        hold on
        F = read(VR,Fr(ifr));
        imshow(F)
%         mx = cos(0:0.01:2*pi)*4;
%         my = sin(0:0.01:2*pi)*4;
%         for d = length(xFr.data):-1:1
%             od = length(xFr.data)-d+1;
%             x0 = xFr.data;
%             x0 = x0(d);
%             y0 = yFr.data;
%             y0 = y0(d);
%             ch = patch(mx+x0,my+y0,C(od,:));
%             set(ch,'edgecolor','none')
%             set(ch,'FaceAlpha',O(od))
%         end
        th=text(720/2,0,sprintf('VTE, lap %d',lapnum));
        set(th,'verticalalignment','top')
        set(th,'horizontalalignment','center')
        set(th,'color','w')
        set(th,'fontname','Arial')
        set(th,'fontsize',16)
        hold off
        drawnow
        curFrame = getframe;
        writeVideo(VW,curFrame)
        writeVideo(VW,curFrame)
        k = k+1;
    end
end
close(VW)
%%
VW = VideoWriter('NonVTE_movie.mp4','MPEG-4');
VW.FrameRate = 30;
open(VW);

k = 1;
laps = 1:length(sd.EnteringCPTime);
lowlaps = laps(idLow);
for pass = 1 : length(LowPassesIn)
    idPass = CheetahTime >= LowPassesIn(pass)-1 & CheetahTime <= LowPassesOut(pass)+1;
    lapnum = lowlaps(pass);
    t = CheetahTime(idPass);
    x = sd.x.restrict(min(t),max(t));
    y = sd.y.restrict(min(t),max(t));
    xt = x.range;
    xd = x.data;
    yt = y.range;
    yd = y.data;
    for d = 1 : length(xd)
        s = max(1,d-2);
        f = min(length(xd),d+2);
        x0(d) = mean(xd(s:f));
        y0(d) = mean(yd(s:f));
    end
    x = tsd(xt(:),x0(:));
    y = tsd(yt(:),y0(:));
    Fr = FrameList(idPass);
    % Section showing trajectory
    for ifr = 1 : length(Fr)
        tFr = t(ifr);
        xFr = x.restrict(tFr-window,tFr);
        yFr = y.restrict(tFr-window,tFr);
        clf
        cla
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        hold on
        imshow(F1)
        th=text(720/2,0,sprintf('Non-VTE, lap %d',lapnum));
        set(th,'verticalalignment','top')
        set(th,'horizontalalignment','center')
        set(th,'color','w')
        set(th,'fontname','Arial')
        set(th,'fontsize',16)
        mx = cos(0:0.01:2*pi)*4;
        my = sin(0:0.01:2*pi)*4;
        for d = length(xFr.data):-1:1
            od = length(xFr.data)-d+1;
            x0 = xFr.data;
            x0 = x0(d);
            y0 = yFr.data;
            y0 = y0(d);
            ch = patch(mx+x0,my+y0,[1 1 1],'facecolor',C(od,:),'edgecolor',C(od,:));
            set(ch,'edgecolor','none')
%             set(ch,'FaceAlpha',O(od))
        end
        hold off
        drawnow
        curFrame = getframe;
        writeVideo(VW,curFrame)
        writeVideo(VW,curFrame)
        k = k+1;
    end
    clf
    cla
    set(gca,'xlim',[0 720])
    set(gca,'ylim',[0 480])
    th=text(720/2,0,sprintf('Non-VTE, lap %d',lapnum));
    set(th,'verticalalignment','top')
    set(th,'horizontalalignment','center')
    set(th,'color','w')
    set(th,'fontname','Arial')
    set(th,'fontsize',16)
    hold on
    imshow(F1)
    curFrame = getframe;
    for iti = 1 : VR.FrameRate
        writeVideo(VW,curFrame)
        writeVideo(VW,curFrame)
    end
    
    for ifr = 1 : length(Fr)
        tFr = t(ifr);
        xFr = x.restrict(tFr-window,tFr);
        yFr = y.restrict(tFr-window,tFr);
        clf
        cla
        set(gca,'xlim',[0 720])
        set(gca,'ylim',[0 480])
        th=text(720/2,0,sprintf('Non-VTE, lap %d',lapnum));
        set(th,'verticalalignment','top')
        set(th,'horizontalalignment','center')
        set(th,'color','w')
        set(th,'fontname','Arial')
        set(th,'fontsize',16)
        hold on
        F = read(VR,Fr(ifr));
        imshow(F)
        th=text(720/2,0,sprintf('Non-VTE, lap %d',lapnum));
        set(th,'verticalalignment','top')
        set(th,'horizontalalignment','center')
        set(th,'color','w')
        set(th,'fontname','Arial')
        set(th,'fontsize',16)
%         mx = cos(0:0.01:2*pi)*4;
%         my = sin(0:0.01:2*pi)*4;
%         for d = length(xFr.data):-1:1
%             od = length(xFr.data)-d+1;
%             x0 = xFr.data;
%             x0 = x0(d);
%             y0 = yFr.data;
%             y0 = y0(d);
%             ch = patch(mx+x0,my+y0,C(od,:));
%             set(ch,'edgecolor','none')
%             set(ch,'FaceAlpha',O(od))
%         end
        hold on
        drawnow
        curFrame = getframe;
        writeVideo(VW,curFrame)
        writeVideo(VW,curFrame)
        k = k+1;
    end
end
close(VW)