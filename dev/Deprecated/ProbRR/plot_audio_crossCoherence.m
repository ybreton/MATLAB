function plot_audio_crossCoherence(AudioTab,Threshold)
%
%
%
%
clf
fh=gcf;
set(gcf,'position',[1921,57,1280,948]);

% Parse threshold table.
DATA = [];
Low = false(size(AudioTab.DATA,1),1);
Mid = false(size(AudioTab.DATA,1),1);
High = false(size(AudioTab.DATA,1),1);

for r = 1 : size(Threshold.Thresholds,1)-1
    for c = 1 : size(Threshold.Thresholds,2)-1
        theta = Threshold.Thresholds(r,c).Theta;
        IVr = Threshold.Thresholds(r,c).IVr;
        IVc = Threshold.Thresholds(r,c).IVc;
        DATA = [DATA;
            IVr IVc theta];
        % AudioTab.DATA(:,3) is zone number (IVc)
        % AudioTab.DATA(:,4) is pellets (IVr)
        % AudioTab.DATA(:,5) is probability.
        idLow = AudioTab.DATA(:,3)==IVc & AudioTab.DATA(:,4)==IVr & AudioTab.DATA(:,5)<theta;
        idMid = AudioTab.DATA(:,3)==IVc & AudioTab.DATA(:,4)==IVr & AudioTab.DATA(:,5)==theta;
        idHi = AudioTab.DATA(:,3)==IVc & AudioTab.DATA(:,4)==IVr & AudioTab.DATA(:,5)>theta;
        Low(idLow) = true;
        Mid(idMid) = true;
        High(idHi) = true;
    end
end

% Following low tone
% 	AudioTab.DATA(:,7)==1 atZone
%   Low==1 low tone
id = AudioTab.DATA(:,7)==1 & AudioTab.DATA(:,9)==1 & Low==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);

set(0,'CurrentFigure',fh)
subplot(6,2,1)
title('Following low probability, before an entry')
hold on
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following low probability, before an entry')
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);
hold on
plot(unique(tones),unique(tones),'wx','markersize',10)
hold off
drawnow

% Low, skip
id = AudioTab.DATA(:,7)==1 & AudioTab.DATA(:,9)==0 & Low==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);

set(0,'CurrentFigure',fh)

subplot(6,2,2)
title('Following low probability, before a skip')
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following low probability, before a skip')
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);


hold on; plot(unique(tones),unique(tones),'wx','markersize',10)
hold off
drawnow


% Following high tone
%   AudioTab.DATA(:,7)==1 atZone
%   High==1 high tone
id = AudioTab.DATA(:,7)==1 & AudioTab.DATA(:,9)==1 & High==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
set(0,'CurrentFigure',fh)
subplot(6,2,3)
hold on
title('Following high probability, before an entry')
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);
hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following high probability, before an entry')
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);


hold on; plot(unique(tones),unique(tones),'wx','markersize',10)
hold off
drawnow
set(0,'CurrentFigure',fh)

id = AudioTab.DATA(:,7)==1 & AudioTab.DATA(:,9)==0 & High==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
set(0,'CurrentFigure',fh)
subplot(6,2,4)
hold on
title('Following high probability, before a skip')
tones = extract_tones(S,Y,tones);
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following high probability, before a skip')
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);


hold on; plot(unique(tones),unique(tones),'wx','markersize',10)
hold off
drawnow
set(0,'CurrentFigure',fh)

% Following reward delivery, low-P
% AudioTab.DATA(:,8)==1 atFeeder
% AudioTab.DATA(:,10)==1 rewarded
id = AudioTab.DATA(:,8)==1 & AudioTab.DATA(:,10)==1 & Low==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
set(0,'CurrentFigure',fh)
subplot(6,2,5)
title('Following reward, low-P')
hold on
if ~isempty(X)
    [Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

    hold off
    drawnow
    
    figure; set(gcf,'position',[1921,57,1280,948]);
    hold on
    title('Following reward, low-P')
    [Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);
    
    
    hold on; plot(unique(tones),unique(tones),'wx','markersize',10)
    hold off
    drawnow
else
    title('Never rewarded on low-P.')
    set(gca,'visible','off')
    meanAF_lowR = nan;
    meanF_lowR = nan;
end


% Following reward delivery, high-P
id = AudioTab.DATA(:,8)==1 & AudioTab.DATA(:,10)==1 & High==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);

set(0,'CurrentFigure',fh)
subplot(6,2,6)
title('Following reward, high-P')
hold on
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

hold off
drawnow

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following reward, high-P')
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

hold off
drawnow


% Following reward non-delivery, low-P
id = AudioTab.DATA(:,8)==1 & AudioTab.DATA(:,10)==0 & Low==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
set(0,'CurrentFigure',fh)
subplot(6,2,7)
title('Following no reward, low-P')
hold on
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

hold off

figure; set(gcf,'position',[1921,57,1280,948]);;
hold on
title('Following no reward, low-P')
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);


hold on; plot(unique(tones),unique(tones),'wx','markersize',10)
hold off
drawnow

% Following reward non-delivery, high-P
id = AudioTab.DATA(:,8)==1 & AudioTab.DATA(:,10)==0 & High==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
set(0,'CurrentFigure',fh)
subplot(6,2,8)
title('Following no reward, high-P')
hold on
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

hold off
drawnow

figure; set(gcf,'position',[1921,57,1280,948]);
title('Following no reward, high-P')
hold on
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);


hold on; plot(unique(tones),unique(tones),'wx','markersize',10)
hold off
drawnow


% Entries
id = AudioTab.DATA(:,7)==1 & AudioTab.DATA(:,9)==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
set(0,'CurrentFigure',fh)
subplot(6,2,9)
title('All Entry')
hold on
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('All Entry')
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);


hold on; plot(unique(tones),unique(tones),'wx','markersize',10)
hold off

% Following skip
id = AudioTab.DATA(:,7)==1 & AudioTab.DATA(:,9)==0;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
set(0,'CurrentFigure',fh)
subplot(6,2,10)
title('All Skip')
hold on
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('All Skip')
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);


hold on; plot(unique(tones),unique(tones),'wx','markersize',10)
hold off

set(0,'CurrentFigure',fh)

% Following reward
id = AudioTab.DATA(:,8)==1 & AudioTab.DATA(:,10)==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
set(0,'CurrentFigure',fh)
subplot(6,2,11)
title('Following Reward')
hold on
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following Reward')
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);


hold on; plot(unique(tones),unique(tones),'wx','markersize',10)
hold off

% Following non-reward
id = AudioTab.DATA(:,8)==1 & AudioTab.DATA(:,10)==0;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,13);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
set(0,'CurrentFigure',fh)
subplot(6,2,12)
title('Following Non-Reward')
hold on
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);

hold off

figure; set(gcf,'position',[1921,57,1280,948]);
title('Following Non-Reward')
hold on
[Z,C] = binned_correlogram([S Y],X,P,'numBins', 600); caxis([-1 1]);


hold on; plot(unique(tones),unique(tones),'wx','markersize',10)
hold off


function tones = extract_tones(S,T,tones)

st = unique([S T],'rows');
tone0 = nan(size(st,1),1);
for t = 1 : size(st,1)
    st0 = st(t,:);
    id = st0(1)==S & st0(2)==T;
    tone0(t) = mean(tones(id));
end
tones = tone0;