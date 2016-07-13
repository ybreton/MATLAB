function ah = add_subplots(fh,r,c)
% Wrapper to add all subplots to figure and return handles in matrix form.
% ah = add_subplots(fh,r,c)
% ah = add_subplots(r,c)
% ah = add_subplots(r)
% where     ah          is an r x c x f matrix of handles to subplots
%
%           fh          is a handle to figure for subplots, or a vector of
%                       f figures to add subplots
%           r           is the number of rows of subplots (default 1)
%           c           is the number of columns of subplots (default 1)
%
%
if nargin==0
    fh = gcf;
    r = 1;
    c = 1;
end
if nargin==1
    c = 1;
    r = fh;
    fh = gcf;
end

if nargin==2
    % r becomes c
    % fh becomes r
    c = r;
    r = fh;
    fh = gcf;
end

if isempty(r)
    r = 1;
end
if isempty(c)
    c = 1;
end

rows = repmat((1:r)',[1 c]);
columns = repmat(1:c,[r 1]);

for iF=1:numel(fh)
    ah = nan(r,c,numel(fh));
    for ip=1:numel(ah)
        set(0,'CurrentFigure',fh(iF))
        ah(rows(ip),columns(ip),iF) = subplot(r,c,ip);
    end
end