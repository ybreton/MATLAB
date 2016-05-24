function ah = surv_gauss_overlay(x,in_fit)
% Overlays fit log-survivor on log-survivor of x.
%
%
%

ah = gca;
hold on
[f,bin] = ecdf(x,'function','survivor');
stairs(bin,log(f),'-','color',[0.5 0.5 0.5],'linewidth',4)
p = zeros(length(bin),size(in_fit,2));
parfor k = 1 : size(in_fit,2)
    p(:,k) = 1-normcdf(bin,in_fit(2,k),in_fit(3,k));
end
p = p*in_fit(1,:)';
plot(bin,log(p),'k:','linewidth',1.5)
hold off
