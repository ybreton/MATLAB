function ah = hist_NormLogNorm_overlay(lx,in_fit)
%
%
%
% 

ah = gca;
hold on
[f,bin] = hist(lx,ceil(sqrt(length(lx))));
w = mean(diff(bin));
c = max(f);
C = [1 1 1 1];
for b = 1 : length(bin)
    X = [bin(b)-w/2 bin(b)-w/2 bin(b)+w/2 bin(b)+w/2];
    Y = [0 f(b)/c f(b)/c 0];
    ph = patch(X,Y,C,'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.5 0.5 0.5]);
end

K = size(in_fit,2);
d = zeros(length(bin),K);
for k = 1 : K
    DTMS = in_fit(:,k);
    Norm = normpdf(10.^bin,10.^DTMS(3),10.^DTMS(4))/normpdf(10.^DTMS(3),10.^DTMS(3),10.^DTMS(4));
    LogNorm = normpdf(bin,DTMS(3),DTMS(4))/normpdf(DTMS(3),DTMS(3),DTMS(4));
    Dens = ([Norm(:) LogNorm(:)]*double([DTMS(1)==0;DTMS(1)==1]))*DTMS(2);
    plot(bin,Dens,'r-','linewidth',3)
    d(:,k) = ([normpdf(10.^bin(:),10.^DTMS(3),10.^DTMS(4)) normpdf(bin(:),DTMS(3),DTMS(4))]*[DTMS(1)==0;DTMS(1)==1])*DTMS(2);
end
md = sum(d,2)./max(sum(d,2));
plot(bin,md,':k','linewidth',2)

hold off
