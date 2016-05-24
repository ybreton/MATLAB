function c = helmertContrasts(X,Y,varargin)
% Compares the mean of one condition to the mean across all subsequent
% conditions.
%
%
%

alpha = 0.05;
adjustPC = true;
performANOVA = false;
process_varargin(varargin);
if performANOVA
    [c.ANOVA.p,c.ANOVA.stats,c.ANOVA.table]=anova1(Y,X,'on');
else
    [c.ANOVA.p,c.ANOVA.stats,c.ANOVA.table]=anova1(Y,X,'off');
end

idnan = isnan(X);
X(idnan) = [];
Y(idnan) = [];

G = sort(unique(X));
W = zeros(length(G)-1,length(G));

m = nan(length(G),1);
n = m;
t = m;
dev = nan(length(Y),1);
for g = 1 : length(G)
    idG = X == G(g);
    m(g) = nanmean(Y(idG));
    n(g) = sum(double(~isnan(Y(idG))));
    dev(idG) = Y(idG)-m(g);
end
dev(isnan(dev)) = [];
SSerr = dev'*dev;
MSerr = SSerr/sum(n-1);

for g = 1 : length(G)-1
    notg = G(G>G(g));
    W(g,g) = length(notg);
    W(g,notg) = -1;
    % Row g contains contrast weights
    
    psi = (W(g,:)*m).^2;
    % PSI = sum_i W_i*T_i
    t(g) = psi./sqrt(MSerr*((W(g,:).^2)*(1./n)));
end
if adjustPC
    alphaPC = alpha./size(W,1);
else
    alphaPC = alpha;
end

c.t = t;
c.df = sum(n-1);
c.p = 1-tcdf(c.t,c.df);
c.sig = c.p<alphaPC/2;
c.SScontrast = (t*MSerr).^2;
c.MSerr = MSerr;