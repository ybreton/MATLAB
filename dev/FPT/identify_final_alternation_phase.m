function [FinalAlternation,pChoice,propSSN] = identify_final_alternation_phase(events_tsd,cp,varargin)
%
%
%
%

B = 0.1;
minTime = 0.5;
process_varargin(varargin);

TotalLaps = max(events_tsd.range);
cp(cp<0) = 0;
cp = sort(cp(:));

s = cp(1:end-1)+1;
f = cp(2:end);
d = diff(cp);

pChoice = nan(length(cp),1);
FinalAlternation = false(length(cp),1);
propSSN(2:length(cp),1) = d/TotalLaps;

for seg = 1 : length(s)
    segment = events_tsd.restrict(s(seg),f(seg));
    p = sum(double(segment.data))./d(seg);
    pChoice(seg+1) = p;
end
cumSSNtime = cumsum(propSSN);

% Restrict the segments to those ending after the minimum
% time mark.
idxMin = cumSSNtime>=minTime;

% Then, consider only those segments where pChoice is between 0.5-B and
% 0.5+B.
idxAlt = pChoice>=0.5-B&pChoice<=0.5+B;
segList = 1:length(cp);

AlternationSegs = segList(idxAlt&idxMin);

% Of these potential alternation segments, find the longest.
[duration, idxLong] = max(propSSN(idxAlt&idxMin));
idFinalAlt = AlternationSegs(idxLong);

FinalAlternation = false(length(cp),1);
FinalAlternation(idFinalAlt) = true;


% % Of the alternation segments, consider only the final segment.
% PotentialFinalAlternation = max(AlternationSegs);
% 
% % It is not a final alternation if it ends before hitting the minimum time
% % mark.
% isNotFinal = cumSSNtime<=minTime;
% 
% FinalAlternation = false(length(cp),1);
% FinalAlternation(PotentialFinalAlternation) = true;
% FinalAlternation = FinalAlternation & ~isNotFinal;
