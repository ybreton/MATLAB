function ah = hist_gauss_overlay(x,in_fit)
% Overlays gaussians in fit on histogram of x.
%
%
%

ah = gca;
hold on
[f,bin] = hist(x,linspace(1,4,50));
binw = median(diff(bin));
maxf = sum(f(:));
bar(bin,f/maxf,1)
h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.5 0.5 0.5])
K = size(in_fit,2);
for k = 1 : K
    TMS = in_fit(:,k);
    d(:,k) = normcdf(bin+binw/2,TMS(2),TMS(3))-normcdf(bin-binw/2,TMS(2),TMS(3));
    p(:,k) = ones(length(d(:,k)),1)*TMS(1);
end
plot(bin,d.*p,'r-','linewidth',3)
plot(bin,sum(d.*p,2),':k','linewidth',2)

hold off
