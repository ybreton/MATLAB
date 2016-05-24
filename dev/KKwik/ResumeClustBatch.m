function ResumeClustBatch(varargin)
% Resume cluster cutting after unexpected quit (computer restart, MATLAB
% forcequit, etc.)
%
% OPTIONAL ARGUMENTS:
% ******************
% fcTT = {};                            list of tetrodes to autocut;
%                                           default all
% TText = '.ntt';                       extension of tetrode files;
%                                           default neuralynx .ntt
% TTstr = 'TT';                         prefix to tetrode numbers;
%                                           default TTxx
% cluStr = 'clu';                       extension of cluster output files;
%                                           default KKwik .clu.xx
% StartingDirectory = pwd;              starting directory to work in;
%                                           default current directory
% FDDirectory = 'FD';                   features directory for clusters;
%                                           default subdirectory FD
% channelValidity = true(4,1);          valid channels;
%                                           default first four valid
% LoadingEngine = 'LoadTT_NeuralynxNT'; tetrode file loading engine;
%                                           default neuralynx LoadTT_NeuralynxNT
% minClusters = 10;                     minimum number of clusters;
%                                           default 10
% maxClusters = 60;                     maximum number of clusters;
%                                           default 60
% maxSpikesBeforeSplit = [];            maximum spikes in tetrode file to split;
%                                           default no split
% featuresToCompute = {'feature_Energy', 'feature_EnergyD1', 'feature_Peak', 'feature_WavePC1', 'feature_Time'};
%                                       spike features to compute;
%                                           default energy first-derivative, 
%                                                   peak amplitude,
%                                                   first principal component of waveform,
%                                                   spike time
% featuresToUse = {'feature_Energy', 'feature_EnergyD1'};
%                                       spike features to use in clustering;
%                                           default waveform energy,
%                                                   energy first-derivative
% SubSetAt = 1e6;                       number of spikes before sub-set;
%                                           default 1000000
% GeneralSubSetRate = 10;               general subset rate;
%                                           default 10
%
%

fcTT = {};
TText = '.ntt';
TTstr = 'TT';
cluStr = 'clu';
StartingDirectory = pwd;
FDDirectory = 'FD';
channelValidity = true(4,1);
LoadingEngine = 'LoadTT_NeuralynxNT';
minClusters = 20;
maxClusters = 60;
maxSpikesBeforeSplit = []; % if isempty then don't split
featuresToCompute = {'feature_Energy', 'feature_EnergyD1', 'feature_Peak', 'feature_WavePC1', 'feature_Time'};
featuresToUse = {'feature_Energy', 'feature_EnergyD1'};
SubSetAt = 1e6;
GeneralSubSetRate = 10;  % rate is 1/GSSR
process_varargin(varargin);
loadFcn = eval(['@' LoadingEngine]);

disp(['Session ' StartingDirectory])
ls = dir;
if exist([StartingDirectory '\' FDDirectory],'dir')==7
    pushdir(FDDirectory);
    
    clu = FindFiles(['*.' cluStr '.*'],'CheckSubdirs',false);
    temp = FindFiles('*temp*','CheckSubdirs',false);
    clu = clu(~ismember(clu,temp));
    dateNum = nan(length(clu),1);
    for iClu=1:length(clu)
        s = dir(clu{iClu});
        dateNum(iClu) = s.datenum;
    end
    [dateNum,id] = sort(dateNum);
    clu = clu(id);
    clu = clu(1:end-1);
    % Re-do the last one which almost certainly crashed mid-way.
    
    disp([num2str(length(clu)) ' KKwik tetrode cluster files already produced.'])
    popdir;
else
    clu = {};
end
% clu contains the clusters already generated.
CLU = nan(length(clu),1);
for iF=1:length(CLU)
    [fd,fclu,ext] = fileparts(clu{iF});
    id1 = regexpi(fclu,TTstr);
    id2 = regexpi(fclu,cluStr);
    CLU(iF) = str2double(fclu(id1+length(TTstr):id2-1));
end
% CLU contains the tetrode numbers already generated.

if isempty(fcTT)
    fcTT = FindFiles(['*' TTstr '*' TText],'CheckSubdirs',false);
end
% fcTT contains the tetrodes to process.
TT = nan(length(fcTT),1);
for iF=1:length(fcTT)
    spiketimes = loadFcn(fcTT{iF});
    nSpikes = length(spiketimes);
    if nSpikes>0
        [fd,fc,ext] = fileparts(fcTT{iF});
        id = regexpi(fc,TTstr);
        TT(iF) = str2double(fc(id+length(TTstr):end));
    end
end
% TT has the tetrode numbers to be done.
disp([num2str(length(TT)) ' tetrodes to be processed, total.'])

% Of the fcTT numbers that need to be processed,
% only process those that are not already done.

toDo = ~isnan(TT) & ~ismember(TT,CLU);
disp(['Resuming autocut of remaining ' num2str(sum(double(toDo))) ' tetrodes.'])

fcTT = fcTT(toDo);
[TT,idSort] = sort(TT(toDo));
fcTT = fcTT(idSort);

disp('Resuming autocut on ');
for iF=1:length(fcTT)
    disp(['- ' fcTT{iF}])
end
fprintf('\n\n')
disp('******************************')
disp('  Enter to begin autocutting')
disp('******************************')
input('');

RunClustBatch('fcTT', fcTT,...
              'TText', TText,...
              'StartingDirectory', StartingDirectory,...
              'FDDirectory', FDDirectory,...
              'channelValidity', channelValidity,...
              'LoadingEngine', LoadingEngine,...
              'minClusters', minClusters,...
              'maxClusters', maxClusters,...
              'maxSpikesBeforeSplit', maxSpikesBeforeSplit,...
              'featuresToCompute', featuresToCompute,...
              'featuresToUse', featuresToUse,...
              'SubSetAt', SubSetAt,...
              'GeneralSubSetRate', GeneralSubSetRate);
