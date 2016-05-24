function h=trendline(x,y,varargin)
%
%
%
%

if mod(length(varargin),2)==1
    LineSpec = varargin{1};
    varargin = varargin(2:end);
else
    LineSpec = 'r-';
end
distr = 'normal';
link = 'identity';
process_varargin(varargin);
nargs = length(varargin);
arg = 1:nargs;

farg = ismember(varargin,{'distr','link'});
if any(farg)
    fval = arg(find(farg)+1);
    id = true(1,nargs);
    id(farg) = false;
    id(fval) = false;
    properties = varargin(id);
else
    properties = varargin;
end

H = ishold;
hold on
idnan = isnan(x)|isnan(y);
x0 = x(~idnan);
y0 = y(~idnan);
ph=plot(unique(x),glmval(glmfit(x0,y0,distr),unique(x),link),LineSpec);
for iP=1:2:length(properties)
    set(ph,properties{iP},properties{iP+1});
end

if ~H
    hold off
end
if nargout>0
    h = ph;
end