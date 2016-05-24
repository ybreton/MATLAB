%% Script to assemble and divvy up session data.
%% Initialize
VEHstr = 'Saline';
CNOstr = 'CNO';
VTEtime = 3;
%%
fn = FindFiles('RR-*.mat');
fd = cell(length(fn),1);
for f = 1 : length(fn); 
    fd{f} = fileparts(fn{f}); 
end
fd = unique(fd);
%% Accumulate sessions.
AllSessions = wrap_RR_collectSess(fd,'VTEtime',VTEtime);

%% Divide them into conditions.

VEH = wrap_RR_analysis(AllSessions,VEHstr);
CNO = wrap_RR_analysis(AllSessions,CNOstr);

fd=pwd;
id=regexpi(fd,'\');
save([fd(max(id)+1:end) '-VEH.mat'],'VEH');
save([fd(max(id)+1:end) '-CNO.mat'],'CNO');