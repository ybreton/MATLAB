function [Icondition,Icontrol] = find_RR_instances(sd,instanceType)
%
%
%
%

if ~isfield(sd,'Threshold')
    sd = calculate_session_thresholds(sd);
end

sd.Threshold.OverUnder =  sd.Threshold.OverUnder(:);
D = diff(sd.Threshold.OverUnder);

sd.Stay = sd.Stay(:);
Stayed = sd.Stay(1:end-1);


if ~isempty(regexpi(instanceType,'regret'))
    % Regret: Over (+1) after under (-1) and stayed, D==2 & Stayed
    Icondition = [false; D==2 & Stayed(:)];
    % No Regret: Over (+1) after under (-1) and skipped, D==2 & ~Stayed
    Icontrol = [false; D==2 & ~Stayed(:)];
end

if ~isempty(regexpi(instanceType,'rejoice'))
    % Rejoice: Under (-1) after over (+1)
    Icondition = [false; D==-2];
    % No Rejoice: Under (-1) after under (-1)
    Icontrol = [false; D==0 & sd.Threshold.OverUnder(1:end-1)<0];
end