function [Condition,Dose] = RRGetDrugs(sd,varargin)
% Produces drug condition cell array.
% [Condition,Dose] = RRGetDrugs(fn)
% where     Condition is nSubsess x 1 cell array of drug conditions.
%           Dose is nSubsess x 1 vector of drug doses.
%           
%           fn is nSubsess x 1 structure of sd.
%

process_varargin(varargin);

Condition = cell(numel(sd),1);
Dose = cell(numel(sd),1);

for s = 1 : numel(sd)
    Condition{s} = sd(s).ExpKeys.Condition;
    Dose{s} = sd(s).ExpKeys.Dose;
end