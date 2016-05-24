function DurationList = listSegmentDurations(K,maxLaps,varargin)
%
%
%
%

minDuration = 1;
process_varargin(varargin);

if K==1
    DurationList = maxLaps;
elseif K==2
    DurationList = (1:maxLaps-K+1)';
    DurationList(:,K) = maxLaps - sum(DurationList(:,1:K-1),2);
else
    segments = repmat((1:maxLaps-K+1)',1,K-1);
    DurationList = allPossibleCombinations(segments,'minDuration',minDuration);
end

DurationList(:,K) = maxLaps - sum(DurationList(:,1:K-1),2);
idExc = false(size(DurationList));
for k = 1 : K
    idExc(:,k) = DurationList(:,k)<minDuration;
end
id = any(idExc,2);
DurationList(id,:) = [];