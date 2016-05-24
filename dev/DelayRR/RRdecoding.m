function sd = RRdecoding(sd,TargetTCdims,varargin)
% Adds TC, Q, and B cell arrays to sd. Each corresponds to sd.ExpKeys.Target.
% sd = RRdecoding(sd,TargetTCdims)
% where         sd            is standard session data,
%
%               TargetTCdims  is a nStructure cell array with dimensions to
%                               perform tuning.
%
% ex:
% sd = RRdecoding(sd,{{{sd.x 32} {sd.y 32}} {{sd.x 64} {sd.y 64}} {{tsd(sd.FeederTimes,sd.FeedersFired) 4}}})
% will perform decoding where
% sd.ExpKeys.Targets{1} will be decoded in 32 (x,y) bins of spatial
% position,
% sd.ExpKeys.Targets{2} will be decoded in 64 (x,y) bins of spatial
% position,
% sd.ExpKeys.Targets{3} will be decoded in 4 bins of feeders fired.
% 
% OPTIONAL ARGUMENTS:
% ******************
% dt        (default 0.125)         time step for MakeQfromS.
%
dt = 0.125;
process_varargin(varargin);

idOFC = find(strcmpi('OFC',sd.ExpKeys.Target));
idNAc = find(strcmpi('vStr',sd.ExpKeys.Target));
idCA1 = find(strcmpi('CA1',sd.ExpKeys.Target));

sd = RRassignSpikesToTargets(sd);
% sd.ByTarget.S contains S where column idOFC is all OFC cells, etc.

TC = cell(1,length(sd.ExpKeys.Target));
Q = cell(1,length(sd.ExpKeys.Target));
B = cell(1,length(sd.ExpKeys.Target));
for iStruc = 1:length(sd.ExpKeys.Target)
    S = sd.ByTarget.S(1:sd.ByTarget.nCells(iStruc),iStruc);
    dims = TargetTCdims{iStruc};
    disp(['Tuning curves for ' sd.ExpKeys.Target{iStruc}])
    TC{iStruc} = TuningCurves(S,dims);
    Q{iStruc} = MakeQfromS(S,dt);
    disp(['Decoding for ' sd.ExpKeys.Target{iStruc}])
    B{iStruc} = BayesianDecoding(Q{iStruc},TC{iStruc});
end

sd.TC = TC;
sd.Q = Q;
sd.B = B;
