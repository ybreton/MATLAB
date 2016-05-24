%% Script to plot the choice performance for each session.

%% Initialize
VEHstr = 'Saline';
CNOstr = 'CNO';
%%
fn = FindFiles('RR-*.mat');
fd = cell(length(fn),1);
for f = 1 : length(fn); 
    fd{f} = fileparts(fn{f}); 
end
fd = unique(fd);
%% Accumulate sessions.
AllSessions = wrap_RR_collectSess(fd);

%% Divide them into conditions.

VEH = wrap_RR_analysis(AllSessions,VEHstr);
CNO = wrap_RR_analysis(AllSessions,CNOstr);

%% For each session, plot each zone.
nPlistAll = [];
for iSess = 1:length(AllSessions)
    sess = AllSessions(iSess).sd;
    pushdir(sess(1).fd);
    nPlist = unique(sess(1).Pellets(~isnan(sess(1).Pellets)));
    for nP = nPlist(:)'
        fh = RRplotSessionChoices(sess,nP);
        for iZ=1:length(fh)
            saveas(fh(iZ),sprintf('%s-Choices-Zone%d-nPellets%d.fig',sess.SSN{1},iZ,nP),'fig')
            saveas(fh(iZ),sprintf('%s-Choices-Zone%d-nPellets%d.eps',sess.SSN{1},iZ,nP),'epsc')
        end
        close all
    end
    nPlistAll = unique([nPlistAll;nPlist(:)]);
    popdir;
end
%% For all vehicle sessions, plot each zone.
fh = 1:4;
for nP = nPlistAll(:)'
    for iSess=1:length(VEH)
        hold on
        fh = RRplotSessionChoices(VEH(iSess).sd,nP,'fh',fh);
        hold off
    end
    for iZ=1:length(fh)
        saveas(fh(iZ),sprintf('Vehicle-Choices-Zone%d-nPellets%d.fig',sess.SSN{1},iZ,nP),'fig')
        saveas(fh(iZ),sprintf('Vehicle-Choices-Zone%d-nPellets%d.eps',sess.SSN{1},iZ,nP),'epsc')
    end
    close all
end
%% For all CNO sessions, plot each zone.
fh = 1:4;
for nP = nPlistAll(:)'
    for iSess=1:length(CNO)
        hold on
        fh = RRplotSessionChoices(CNO(iSess).sd,nP,'fh',fh);
        hold off
    end
    for iZ=1:length(fh)
        saveas(fh(iZ),sprintf('CNO-Choices-Zone%d-nPellets%d.fig',sess.SSN{1},iZ,nP),'fig')
        saveas(fh(iZ),sprintf('CNO-Choices-Zone%d-nPellets%d.eps',sess.SSN{1},iZ,nP),'epsc')
    end
    close all
end