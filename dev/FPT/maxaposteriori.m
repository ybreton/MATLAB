function [MAP,posterior] = maxaposteriori(x,Tau,Theta,varargin)
%
%
%
%

dist = 'normal';
process_varargin(varargin);
if ischar(dist)
    dist = {dist};
end
if numel(dist)==1
    dist0 = dist;
    dist = cell(size(Theta,2),1);
    dist(1:end) = dist0;
end

% P[D | x>=x*] = (P[x>=x* | D] * P[D])/P[x>=x*]

[c,bin] = ecdf(x);
s=1-c;
priorX = zeros(length(x),1);
for id = 1 : length(bin)
    idx = x == bin(id);
    priorX(idx) = s(id);
end

likelihood = zeros(length(x),size(Theta,2));
for k = 1 : size(Theta,2);
    str0 = '1-cdf(dist{k},x';
    str1 = sprintf(',%f',Theta(:,k));
    str = [str0 str1 ');'];
    likelihood(:,k) = eval(str);
end

posterior = (likelihood.*repmat(Tau(:)',length(x),1))./repmat(priorX(:),1,size(Theta,2));

components = 1:size(Theta,2);
MAP = nan(size(posterior,1),1);
for id = 1 : size(posterior,1)
    [maxima] = max(posterior(id,:));
    idx = posterior(id,:) == maxima;
    if sum(double(idx))==1
        MAP(id) = components(idx);
    end
end