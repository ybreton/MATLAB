function tso = maskts(tsa,t1,t2)
% Function to "mask" ts structures between t1 and t2.

assert(length(size(t1))==length(size(t2)),'t1 and t2 must have same number of dimensions.')
assert(all(size(t1)==size(t2)),'t1 and t2 must have identical size.');

d = tsa.data;

T1 = repmat(t1(:)',[length(d) 1]);
T2 = repmat(t2(:)',[length(d) 1]);
D = repmat(d(:),[1 numel(t1)]);
idExc = D>=T1 & D<T2;

id=any(idExc,2);

tso = ts(d(~id));