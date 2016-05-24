function fh = plot_revealed_preferences(varargin)
%
%
%
%

d = cd;
id = regexp(d,'\');
id = max(id);
prefix = d(1:id-1);
curDir = d(id+1:end);
% prefix will be important to locate files.
% when run from within SSN, prefix will be ...\ProbRR\Rat
%                           curDir will be SSN
% when run from within rat, prefix will be ...\ProbRR
%                           curDir will be Rat
% when getting sessions, we just want the part up to Rat.

folders = dir;
k = 0;
session_list = cell(0,1);
for d = 1 : length(folders)
    name = folders(d).name;
    isdir = folders(d).isdir;
    isvalid = ~strcmp(name,'.') && ~strcmp(name,'..');
    isSSN =  ~isempty(regexp(name,'R[0-9][0-9][0-9]-20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]'));
    if isdir && isvalid && isSSN
        k = k+1;
        session_list{k} = name;
    end
end
if isempty(session_list)
    session_list = curDir;
end
process_varargin(varargin)
cd([prefix '\' curDir])
if ischar(session_list)
    sess_in = session_list;
    clear session_list;
    session_list{1} = sess_in;
end

n = length(session_list);

Skip = nan(4,11,n);
Entry = nan(4,11,n);
ZoneProbSkipPref = nan(4,11,n);
ZoneSkipPref = nan(4,1,n);
ProbSkipPref = nan(1,11,n);

for d = 1 : n
    SSN = session_list{d};
    idHyph = regexp(SSN,'-');
    dateStr = SSN(idHyph(1)+1:end);
    cd([prefix '\' curDir '\' SSN])
    file = FindFiles(['*' dateStr '*.mat'],'CheckSubDirs',false);
    vars = {'ZoneIn' 'ZoneProbability'};
    for f = 1 : length(file)
        try
            load(file{f},vars{:})
        end
    end
    if n>1
        [Skip(:,:,d),Entry(:,:,d),ZoneProbSkipPref(:,:,d),ZoneSkipPref(:,:,d),ProbSkipPref(:,:,d)] = RevealedPreferences;
    else
        [Skip,Entry,ZoneProbSkipPref,ZoneSkipPref,ProbSkipPref] = RevealedPreferences;
    end
    try
        clear ZoneIn ZoneProbability
    end
    cd('..')
end
cd([prefix '\' curDir])

OverallNumSkips = sum(Skip,3);
OverallNumEntry = sum(Entry,3);
SkipSD = std(Skip,0,3);
Skip = mean(Skip,3);
EntrySD = std(Entry,0,3);
Entry = mean(Entry,3);
ZoneProbSkipPrefSD = std(ZoneProbSkipPref,0,3);
ZoneProbSkipPref = mean(ZoneProbSkipPref,3);
ZoneSkipPrefSD = std(ZoneSkipPref,0,3);
ZoneSkipPref = mean(ZoneSkipPref,3);
ProbSkipPrefSD = std(ProbSkipPref,0,3);
ProbSkipPref = mean(ProbSkipPref,3);


fh = figure;
clf
subplot(2,2,1)
hold on
title('Overall Proportion of Skips')
xlabel('Probability of Reward')
ylabel('Zone')
x = 0:0.1:1;
y = 1:4;
Xwidth = 0.05;
Ywidth = 0.5;
colormap('jet')
[X,Y] = meshgrid(x,y);
Z = OverallNumSkips./(OverallNumSkips+OverallNumEntry);
for r = 1 : size(X,1)
    for c = 1 : size(Y,2)
        patchX = [X(r,c)-Xwidth X(r,c)-Xwidth X(r,c)+Xwidth X(r,c)+Xwidth];
        patchY = [Y(r,c)-Ywidth Y(r,c)+Ywidth Y(r,c)+Ywidth Y(r,c)-Ywidth];
        patchZ = ones(1,4)*Z(r,c);
        patch(patchX,patchY,patchZ);
    end
end
caxis([0 1]);
colorbar;
set(gca,'xlim',[-0.05 1.05])
set(gca,'ylim',[0.5 4.5])
set(gca,'xtick',[0:0.1:1])
set(gca,'ytick',[1:4])
yticklabel = {'Fruit' 'Banana' 'White' 'Chocolate'};
set(gca,'yticklabel',yticklabel)
hold off

subplot(2,2,2)
hold on
title('Mean Proportion of Skips')

cmap(1,:) = [1 0 0];
cmap(2,:) = [1 1 0];
cmap(3,:) = [0.8 0.8 0.8];
cmap(4,:) = [0.8 0.4 0.1];

legendStr{1} = sprintf('Fruit');
legendStr{2} = sprintf('Banana');
legendStr{3} = sprintf('White');
legendStr{4} = sprintf('Chocolate');
ph = nan(4,1);
for zone = 1 : 4
    ph(zone)=plot(X(zone,:),ZoneProbSkipPref(zone,:),'o-','markerfacecolor','k','color',cmap(zone,:),'linewidth',3);
    for prob = 1 : size(ZoneProbSkipPref,2)
        SEM = ZoneProbSkipPrefSD(zone,prob)./sqrt(n);
        ErrX = [X(zone,prob) X(zone,prob)];
        ErrY = [ZoneProbSkipPref(zone,prob)-SEM ZoneProbSkipPref(zone,prob)+SEM];
        plot(ErrX,ErrY,'-','color',cmap(zone,:),'linewidth',0.5)
    end
end
xlabel('Probability of Reward')
ylabel('Proportion of times skipped')
set(gca,'xlim',[-0.05 1.05])
set(gca,'xtick',[0:0.1:1])
set(gca,'ylim',[-0.05 1.05])
set(gca,'ytick',[0:0.1:1])
legend(ph,legendStr)
hold off

subplot(2,2,3)
hold on
title('Mean Probability-dependent skips')
xlabel('Probability of Reward')
ylabel('Proportion of times skipped')
plot([0:0.1:1],ProbSkipPref,'ko-','linewidth',2)
for prob = 1 : length(ProbSkipPref)
    SEM = ProbSkipPrefSD(prob)./sqrt(n);
    ErrX = [(prob-1)/10 (prob-1)/10];
    ErrY = [ProbSkipPref(prob)-SEM ProbSkipPref(prob)+SEM];
    plot(ErrX,ErrY,'k-','linewidth',0.5)
end
set(gca,'xlim',[-0.05 1.05])
set(gca,'xtick',[0:0.1:1])
set(gca,'ylim',[0 1])
set(gca,'ytick',[0:0.1:1])
hold off
subplot(2,2,4)
hold on
title('Mean Zone-dependent skips')
xlabel('Zone')
ylabel('Proportion of times skipped')

for zone = 1 : 4
    patchX = [zone-0.4 zone-0.4 zone+0.4 zone+0.4];
    patchY = [0 ZoneSkipPref(zone) ZoneSkipPref(zone) 0];
    patch(patchX,patchY,[0 0 0 0],'FaceColor','none','EdgeColor','k','linewidth',2)
    
    SEM = ZoneSkipPrefSD(zone)/sqrt(n);
    ErrX = [zone zone];
    ErrY = [ZoneSkipPref(zone)-SEM ZoneSkipPref(zone)+SEM];
    plot(ErrX,ErrY,'k-','linewidth',0.5)
end
set(gca,'xlim',[0 5])
set(gca,'xtick',[1:4])
xticklabels{1} = sprintf('Fruit');
xticklabels{2} = sprintf('Banana');
xticklabels{3} = sprintf('White');
xticklabels{4} = sprintf('Chocolate');
set(gca,'xticklabel',xticklabels)
set(gca,'ylim',[0 1])
set(gca,'ytick',[0:0.1:1])
hold off