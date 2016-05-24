function plot_audio_events(AudioTab,Threshold)
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
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
subplot(5,2,1)
title('Following low probability, before an entry')
tones = extract_tones(S,Y,tones);
[fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
% eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following low probability, before an entry')
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ch=colorbar;
ylabel('Trials')
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off
figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following low probability, before an entry')
plot(fGrid(1,:)/1000,(mean(eGrid,1)))
meanAF_lowE = mean(eGrid,1);
meanF_lowE = fGrid(1,:);
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
plot(tones/1000,0,'kx')
xlabel('Audio frequency (kHz)')
ylabel('Mean Energy Across Sessions & Trials')
set(gca,'yscale','log')
hold off
drawnow

set(0,'CurrentFigure',fh)

% Low, skip
id = AudioTab.DATA(:,7)==1 & AudioTab.DATA(:,9)==0 & Low==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
subplot(5,2,2)
title('Following low probability, before a skip')
tones = extract_tones(S,Y,tones);
[fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
% eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following low probability, before a skip')
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ch=colorbar;
ylabel('Trials')
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following low probability, before a skip')
plot(fGrid(1,:)/1000,(mean(eGrid,1)))
meanAF_lowS = mean(eGrid,1);
meanF_lowS = fGrid(1,:);
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
plot(tones/1000,0,'kx')
xlabel('Audio frequency (kHz)')
ylabel('Mean Energy Across Sessions & Trials')
set(gca,'yscale','log')
hold off
drawnow

set(0,'CurrentFigure',fh)

% Following high tone
%   AudioTab.DATA(:,7)==1 atZone
%   High==1 high tone
id = AudioTab.DATA(:,7)==1 & AudioTab.DATA(:,9)==1 & High==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
set(0,'CurrentFigure',fh)
subplot(5,2,3)
title('Following high probability, before an entry')
tones = extract_tones(S,Y,tones);
[fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
% eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
drawnow

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following high probability, before an entry')
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ch=colorbar;
ylabel('Trial number')
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following high probability, before an entry')
plot(fGrid(1,:)/1000,(mean(eGrid,1)))
meanAF_highE = mean(eGrid,1);
meanF_highE = fGrid(1,:);
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
plot(tones/1000,0,'kx')
xlabel('Audio frequency (kHz)')
ylabel('Mean Energy Across Sessions & Trials')
set(gca,'yscale','log')
hold off
drawnow
set(0,'CurrentFigure',fh)

id = AudioTab.DATA(:,7)==1 & AudioTab.DATA(:,9)==0 & High==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
set(0,'CurrentFigure',fh)
subplot(5,2,4)
title('Following high probability, before a skip')
tones = extract_tones(S,Y,tones);
[fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
% eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
drawnow

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following high probability, before a skip')
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ch=colorbar;
ylabel('Trial number')
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following high probability, before a skip')
plot(fGrid(1,:)/1000,(mean(eGrid,1)))
meanAF_highS = mean(eGrid,1);
meanF_highS = fGrid(1,:);
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
plot(tones/1000,0,'kx')
xlabel('Audio frequency (kHz)')
ylabel('Mean Energy Across Sessions & Trials')
set(gca,'yscale','log')
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
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
subplot(5,2,5)
title('Following reward, low-P')
hold on
if ~isempty(X)
    tones = extract_tones(S,Y,tones);
    [fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
    % eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
    ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
    hold off
    drawnow
    
    figure; set(gcf,'position',[1921,57,1280,948]);
    hold on
    title('Following reward, low-P')
    ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
    xlabel('Audio frequency (kHz)')
    ch=colorbar;
    ylabel('Trial number')
    set(get(ch,'ylabel'),'string','Log Mean Energy')
    set(get(ch,'ylabel'),'rotation',-90)
    hold off
    
    figure; set(gcf,'position',[1921,57,1280,948]);;
    hold on
    title('Following reward, low-P')
    plot(fGrid(1,:)/1000,(mean(eGrid,1)))
    meanAF_lowR = mean(eGrid,1);
    meanF_lowR = fGrid(1,:);
    set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
    plot(tones/1000,0,'kx')
    xlabel('Audio frequency (kHz)')
    ylabel('Mean Energy Across Sessions & Trials')
    set(gca,'yscale','log')
    hold off
    drawnow
    set(0,'CurrentFigure',fh)
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
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
subplot(5,2,6)
title('Following reward, high-P')
hold on
tones = extract_tones(S,Y,tones);
[fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
% eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
hold off
drawnow

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following reward, high-P')
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ch=colorbar;
ylabel('Trial number')
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following reward, high-P')
plot(fGrid(1,:)/1000,(mean(eGrid,1)))
meanAF_hiR = mean(eGrid,1);
meanF_hiR = fGrid(1,:);
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
plot(tones/1000,0,'kx')
xlabel('Audio frequency (kHz)')
ylabel('Mean Energy Across Sessions & Trials')
set(gca,'yscale','log')
hold off
drawnow

set(0,'CurrentFigure',fh)

% Following reward non-delivery, low-P
id = AudioTab.DATA(:,8)==1 & AudioTab.DATA(:,10)==0 & Low==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
subplot(5,2,7)
title('Following no reward, low-P')
hold on
tones = extract_tones(S,Y,tones);
[fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
% eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
hold off
drawnow

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following no reward, low-P')
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ch=colorbar;
ylabel('Trial number')
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off

figure; set(gcf,'position',[1921,57,1280,948]);;
hold on
title('Following no reward, low-P')
plot(fGrid(1,:)/1000,(mean(eGrid,1)))
meanAF_lowNR = mean(eGrid,1);
meanF_lowNR = fGrid(1,:);
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
plot(tones/1000,0,'kx')
xlabel('Audio frequency (kHz)')
ylabel('Mean Energy Across Sessions & Trials')
set(gca,'yscale','log')
hold off
drawnow
set(0,'CurrentFigure',fh)

% Following reward non-delivery, high-P
id = AudioTab.DATA(:,8)==1 & AudioTab.DATA(:,10)==0 & High==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
subplot(5,2,8)
title('Following no reward, high-P')
hold on
tones = extract_tones(S,Y,tones);
[fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
% eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
hold off
drawnow

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following no reward, high-P')
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ch=colorbar;
ylabel('Trial number')
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off

figure; set(gcf,'position',[1921,57,1280,948]);;
hold on
title('Following no reward, high-P')
plot(fGrid(1,:)/1000,(mean(eGrid,1)))
meanAF_hiNR = mean(eGrid,1);
meanF_hiNR = fGrid(1,:);
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
plot(tones/1000,0,'kx')
xlabel('Audio frequency (kHz)')
ylabel('Mean Energy Across Sessions & Trials')
set(gca,'yscale','log')
hold off
drawnow
set(0,'CurrentFigure',fh)


% Entries
id = AudioTab.DATA(:,7)==1 & AudioTab.DATA(:,9)==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
subplot(5,2,9)
title('All Entry')
hold on
tones = extract_tones(S,Y,tones);
[fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
% eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ylabel('Trial number')
hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ylabel('Trial number')
ch=colorbar;
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('All Entry')
plot(fGrid(1,:)/1000,(mean(eGrid,1)))
meanAF_entry = mean(eGrid,1);
meanF_entry = fGrid(1,:);
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
plot(tones/1000,0,'kx')
xlabel('Audio frequency (kHz)')
ylabel('Mean Energy Across Sessions & Trials')
set(gca,'yscale','log')
hold off

set(0,'CurrentFigure',fh)

% Following skip
id = AudioTab.DATA(:,7)==1 & AudioTab.DATA(:,9)==0;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
subplot(5,2,10)
title('All Skip')
hold on
tones = extract_tones(S,Y,tones);
[fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
% eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ch=colorbar;
ylabel('Trial number')
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('All Skip')
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ch=colorbar;
ylabel('Trial number')
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off
drawnow

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('All Skip')
plot(fGrid(1,:)/1000,(mean(eGrid,1)))
meanAF_skip = mean(eGrid,1);
meanF_skip = fGrid(1,:);
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
plot(tones/1000,0,'kx')
xlabel('Audio frequency (kHz)')
ylabel('Mean Energy Across Sessions & Trials')
set(gca,'yscale','log')
hold off

set(0,'CurrentFigure',fh)

% Following reward
id = AudioTab.DATA(:,8)==1 & AudioTab.DATA(:,10)==1;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
subplot(5,2,10)
title('Following Reward')
hold on
tones = extract_tones(S,Y,tones);
[fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
% eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ch=colorbar;
ylabel('Trial number')
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following Reward')
plot(fGrid(1,:)/1000,(mean(eGrid,1)))
meanAF_R = mean(eGrid,1);
meanF_R = fGrid(1,:);
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
plot(tones/1000,0,'kx')
xlabel('Audio frequency (kHz)')
ylabel('Mean Energy Across Sessions & Trials')
set(gca,'yscale','log')
hold off

% Following non-reward
id = AudioTab.DATA(:,8)==1 & AudioTab.DATA(:,10)==0;
X = AudioTab.DATA(id,11);
Y = AudioTab.DATA(id,2);
Z = AudioTab.DATA(id,12);
P = AudioTab.DATA(id,14);
S = AudioTab.DATA(id,1);
tones = AudioTab.DATA(id,6);
subplot(5,2,10)
title('Following Non-Reward')
hold on
tones = extract_tones(S,Y,tones);
[fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(X,Y,S,Z,P);
% eGrid = eGrid./(repmat(sum(eGrid,2),1,size(eGrid,2)));
ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,eGrid,tones,'logMag',true);
xlabel('Audio frequency (kHz)')
ch=colorbar;
ylabel('Trial number')
set(get(ch,'ylabel'),'string','Log Mean Energy')
set(get(ch,'ylabel'),'rotation',-90)
hold off

figure; set(gcf,'position',[1921,57,1280,948]);
hold on
title('Following Non-Reward')
plot(fGrid(1,:)/1000,(mean(eGrid,1)))
meanAF_NR = mean(eGrid,1);
meanF_NR = fGrid(1,:);
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
plot(tones/1000,0,'kx')
xlabel('Audio frequency (kHz)')
ylabel('Mean Energy Across Sessions & Trials')
set(gca,'yscale','log')
hold off


figure; set(gcf,'position',[1921,57,1280,948]);
% Entries           Skips
% Low-P entry       Low-P skip
% High-P entry      High-P skip
ah = subplot(3,2,1);
title('Entries')
hold on
plot(meanF_entry,meanAF_entry,'g-');
% plot(meanF_entry+max(meanF_entry),meanAF_entry(end:-1:1),'g:');
id22 = meanF_entry>=20*1000&meanF_entry<25*1000;
m = mean(meanAF_entry(id22));
plot([20*1000 25*1000],[m m],'k-')

set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
ylabel('Mean Energy')
hold off
ah(2) = subplot(3,2,2);
title('Skips')
hold on
plot(meanF_skip,meanAF_skip,'r-');
% plot(meanF_skip+max(meanF_skip),meanAF_skip(end:-1:1),'r:');
id22 = meanF_skip>=20*1000&meanF_skip<25*1000;
m = mean(meanAF_skip(id22));
plot([20*1000 25*1000],[m m],'k-')

set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
ylabel('Mean Energy')
hold off
ah(3) = subplot(3,2,3);
title('Low-P, prior to entry')
hold on
plot(meanF_lowE,meanAF_lowE,'g-');
% plot(meanF_lowE+max(meanF_lowE),meanAF_lowE(end:-1:1),'g:');
id22 = meanF_lowE>=20*1000&meanF_lowE<25*1000;
m = mean(meanAF_lowE(id22));
plot([20*1000 25*1000],[m m],'k-')

set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
ylabel('Mean Energy')
hold off
ah(4) = subplot(3,2,4);
title('Low-P, prior to skip')
hold on
plot(meanF_lowS,meanAF_lowS,'r-');
% plot(meanF_lowS+max(meanF_lowS),meanAF_lowS(end:-1:1),'r:');
id22 = meanF_lowS>=20*1000&meanF_lowS<25*1000;
m = mean(meanAF_lowS(id22));
plot([20*1000 25*1000],[m m],'k-')

set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
ylabel('Mean Energy')
hold off
ah(5) = subplot(3,2,5);
title('High-P, prior to entry')
hold on
plot(meanF_highE,meanAF_highE,'g-');
% plot(meanF_highE+max(meanF_highE),meanAF_highE(end:-1:1),'g:');
set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
xlabel('Audio Frequency (Hz)')
ylabel('Mean Energy')
hold off
ah(6) = subplot(3,2,6);
title('High-P, prior to skip')
hold on
plot(meanF_highS,meanAF_highS,'r-');
% plot(meanF_highS+max(meanF_highS),meanAF_highS(end:-1:1),'r:');
id22 = meanF_highS>=20*1000&meanF_highS<25*1000;
m = mean(meanAF_skip(id22));
plot([20*1000 25*1000],[m m],'k-')

set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
ylabel('Mean Energy')
xlabel('Audio Frequency (Hz)')
hold off

ylim = [inf -inf];
for h=1:length(ah)
    ylim0 = get(ah(h),'ylim');
    ylim(1) = min(ylim(1),ylim0(1));
    ylim(2) = max(ylim(2),ylim0(2));
end
for h=1:length(ah)
    set(ah(h),'ylim',ylim)
    set(gcf,'currentaxes',ah(h))
    hold on
    patch([20000 20000 25000 25000],[ylim(1) ylim(2) ylim(2) ylim(1)],[1 1 1],'edgecolor','none','facecolor',[1 1 0],'facealpha',0.10)
    patch([45000 45000 55000 55000],[ylim(1) ylim(2) ylim(2) ylim(1)],[1 1 1],'edgecolor','none','facecolor',[1 1 0],'facealpha',0.10)
    text(22.5*1000,ylim(2),sprintf('Averisve 22kHz'),'verticalalignment','top','horizontalalignment','center','fontweight','bold')
    text(50*1000,ylim(2),sprintf('Appetitive 50kHz'),'verticalalignment','top','horizontalalignment','center','fontweight','bold')
    hold off
end

figure; set(gcf,'position',[1921,57,1280,948]);
% Rewarded          Non-Rewarded
% Low-P R           Low-P NR
% High-P R          High-P NR
ah = subplot(3,2,1);
title('Following Reward')
hold on
plot(meanF_R,meanAF_R,'g-');
% plot(meanF_R+max(meanF_R),meanAF_R(end:-1:1),'g:');
id22 = meanF_R>=20*1000&meanF_R<25*1000;
m = mean(meanAF_R(id22));
plot([20*1000 25*1000],[m m],'k-')

set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
ylabel('Mean Energy')
hold off
ah(2) = subplot(3,2,2);
title('Following Non-Reward')
hold on
plot(meanF_NR,meanAF_NR,'r-');
% plot(meanF_NR+max(meanF_NR),meanAF_NR(end:-1:1),'r:');
id22 = meanF_NR>=20*1000&meanF_NR<25*1000;
m = mean(meanAF_skip(id22));
plot([20*1000 25*1000],[m m],'k-')

set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
ylabel('Mean Energy')
hold off
ah(3) = subplot(3,2,3);
title('Low-P, Following Reward')
hold on
plot(meanF_lowR,meanAF_lowR,'g-');
% plot(meanF_lowR+max(meanF_R),meanAF_lowR(end:-1:1),'g:');
id22 = meanF_lowR>=20*1000&meanF_lowR<25*1000;
m = mean(meanAF_lowR(id22));
plot([20*1000 25*1000],[m m],'k-')

set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
ylabel('Mean Energy')
hold off
ah(4) = subplot(3,2,4);
title('Low-P, Following Non-Reward')
hold on
plot(meanF_lowNR,meanAF_lowNR,'r-');
% plot(meanF_lowNR+max(meanF_lowNR),meanAF_lowNR(end:-1:1),'r:');
id22 = meanF_lowNR>=20*1000&meanF_lowNR<25*1000;
m = mean(meanAF_lowNR(id22));
plot([20*1000 25*1000],[m m],'k-')

set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
ylabel('Mean Energy')
hold off
ah(5) = subplot(3,2,5);
title('High-P, Following Reward')
hold on
plot(meanF_hiR,meanAF_hiR,'g-');
% plot(meanF_hiR+max(meanF_hiR),meanAF_hiR(end:-1:1),'g:');
id22 = meanF_hiR>=20*1000&meanF_hiR<25*1000;
m = mean(meanAF_hiR(id22));
plot([20*1000 25*1000],[m m],'k-')

set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
ylabel('Mean Energy')
xlabel('Audio Frequency (Hz)')
hold off
ah(6) = subplot(3,2,6);
title('High-P, Following Non-Reward')
hold on
plot(meanF_hiNR,meanAF_hiNR,'r-');
% plot(meanF_hiNR+max(meanF_hiNR),meanAF_hiNR(end:-1:1),'r:');
id22 = meanF_hiNR>=20*1000&meanF_hiNR<25*1000;
m = mean(meanAF_hiNR(id22));
plot([20*1000 25*1000],[m m],'k-')

set(gca,'xlim',[10000 100000])
set(gca,'yscale','log')
ylabel('Mean Energy')
xlabel('Audio Frequency (Hz)')
hold off

ylim = [inf -inf];
for h=1:length(ah)
    ylim0 = get(ah(h),'ylim');
    ylim(1) = min(ylim(1),ylim0(1));
    ylim(2) = max(ylim(2),ylim0(2));
end
for h=1:length(ah)
    set(ah(h),'ylim',ylim)
    set(gcf,'currentaxes',ah(h))
    hold on
    patch([20000 20000 25000 25000],[ylim(1) ylim(2) ylim(2) ylim(1)],[1 1 1],'edgecolor','none','facecolor',[1 1 0],'facealpha',0.10)
    patch([45000 45000 55000 55000],[ylim(1) ylim(2) ylim(2) ylim(1)],[1 1 1],'edgecolor','none','facecolor',[1 1 0],'facealpha',0.10)
    text(22.5*1000,ylim(2),sprintf('Averisve 22kHz'),'verticalalignment','top','horizontalalignment','center','fontweight','bold')
    text(50*1000,ylim(2),sprintf('Appetitive 50kHz'),'verticalalignment','top','horizontalalignment','center','fontweight','bold')
    hold off
end

function tones = extract_tones(S,T,tones)

st = unique([S T],'rows');
tone0 = nan(size(st,1),1);
for t = 1 : size(st,1)
    st0 = st(t,:);
    id = st0(1)==S & st0(2)==T;
    tone0(t) = mean(tones(id));
end
tones = tone0;