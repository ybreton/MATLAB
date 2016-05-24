function [center,slope] = RRsigmoidfit(x,y,varargin)
% fits a sigmoid function of x to the data in y by least squares.
%

debug=false;
process_varargin(varargin);

x=x(:);
y=y(:);
assert(length(x)==length(y),'x and y must have the same number of elements.')

b0=[nanmean(x) 0];
b=fmincon(@(b) lossFunc(x,y,b,debug),b0,[],[],[],[],[min(x) -inf],[max(x) inf]);
center=b(1);
slope=b(2);

function err = lossFunc(x,y,b,debug)
pred = sigmoidFunc(b,x(:));
dev = pred-y;
err = (dev'*dev);
tot = (y'-nanmean(y))*(y-nanmean(y));
R = (tot-err)/(tot);
if debug
    clf
    hold on
    ybin = min(y):min(diff(sort(unique(y)))):max(y);
    xbin = min(x):min(diff(sort(unique(x)))):max(x);
    h=histcn([y(:) x(:)],ybin,xbin);
    imagesc(xbin,ybin,h);
    plot(sort(x(:)),sigmoidFunc(b,sort(x(:))),'w-')
    plot(b(1),0.5,'wd','markerfacecolor','w')
    title(sprintf('\\mu=%.2f, \\sigma=%.2f\nSS_{resid}=%.4f, R^2=%.4f',b(1),b(2),err,R))
    xlim([min(x) max(x)]);
    ylim([min(y) max(y)]);
    hold off
    drawnow
end

function y = sigmoidFunc(b,x)
% y = sign(b(2))*normcdf(x,b(1),b(2))

if sign(b)>0
    y=normcdf(x,b(1),abs(b(2)));
elseif sign(b)<0
    y=1-normcdf(x,b(1),abs(b(2)));
else
    y=b(1);
end