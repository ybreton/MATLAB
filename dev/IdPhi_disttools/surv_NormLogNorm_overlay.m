function ah = surv_NormLogNorm_overlay(x,in_fit)
% Overlays fit log-survivor on log-survivor of x.
%
%
%

ah = gca;
hold on
[f,bin] = ecdf(x,'function','survivor');
stairs(log10(bin),log(f),'-','color',[0.5 0.5 0.5],'linewidth',4)
p = zeros(length(bin),size(in_fit,2));
parfor k = 1 : size(in_fit,2)
    if ~logical(in_fit(1,k))
        p(:,k) = 1-normcdf(bin,10.^in_fit(3,k),10.^in_fit(4,k));
    else
        p(:,k) = 1-normcdf(log10(bin),(in_fit(3,k)),(in_fit(4,k)));
    end
end
p = p*in_fit(2,:)';
plot(log10(bin),log(p),'k:','linewidth',1.5)
hold off
