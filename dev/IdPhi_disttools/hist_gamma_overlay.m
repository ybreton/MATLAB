function ah = hist_gamma_overlay(x,in_fit)
% Overlays gaussians in fit on histogram of x.
%
%
%

ah = gca;
hold on
[f,bin] = hist(x,ceil(sqrt(length(x))));
maxf = max(f);
hist(x,ceil(sqrt(length(x))))
h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.5 0.5 0.5])
K = size(in_fit,2);
for k = 1 : K
    TMS = in_fit(:,k);
    n = gampdf(prod(TMS(2:3)),TMS(2),TMS(3));
    d(:,k) = TMS(1).*gampdf(bin,TMS(2),TMS(3));
    nd = d(:,k)./n;
    plot(bin,nd*maxf,'r-','linewidth',3)
end
md = sum(d,2)./max(sum(d,2));
plot(bin,md*maxf,':k','linewidth',2)

hold off
