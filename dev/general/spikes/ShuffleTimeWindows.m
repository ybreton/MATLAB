function [tShuffleStart,tShuffleStop] = ShuffleTimeWindows(t1,t2,startTime,stopTime)
% Returns time windows obtained at random times between startTime and
% stopTime, of the same width as (t2-t1), but not including times between
% t1 and t2.
%
%
%

assert(length(size(t1))==length(size(t2)),'t1 and t2 must have identical dimensions');
assert(all(size(t1)==size(t2)),'t1 and t2 must have identical size.');
sz = size(t1);
t1 = t1(:);
t2 = t2(:);
window = (t2-t1);
window(end+1) = window(end);
n = length(t1);

In = [startTime;t2];
Out = [t1;stopTime];
id = Out-In<=window;
In = In(~id);
Out = Out(~id);
trls = length(In);
if trls<n
    id=randperm(trls,n-trls);
    In(trls+1:n) = In(id);
    Out(trls+1:n) = Out(id);
else
    In = In(1:n);
    Out = Out(1:n);
end
window = window(1:n);

tShuffleStart = rand(length(In),1).*(Out-In-window)+In;
tShuffleStop = min(tShuffleStart+window,Out);

t = sortrows([tShuffleStart(:) tShuffleStop(:)]);

tShuffleStart = reshape(t(:,1),sz);
tShuffleStop = reshape(t(:,2),sz);
