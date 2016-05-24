function se = nanstderrpool(x1,x2,flag,dim)
% pooled standard error of the mean
% se = nanstderrpool(x1,x2,flag,dim)
% where     se          is the pooled standard error of the mean
% 
%           x1          is the set of observations for group 1
%           x2          is the set of observations for group 2
%           flag        false if assuming sample variance, true if assuming
%                       population variance; default is false.
%           dim         dimension along which to calculate standard error
%                       of the mean; default is 1.

if nargin<3
    flag = 0;
end
if nargin<4
    dim = 1;
end

% S_{xbar1-xbar2} = sqrt(Sp^2/n1 + Sp^2/n2)
% where
% Sp^2 = (SS1+SS2)/(df1+df2)

n1 = sum(~isnan(x1),dim);
df1 = n1-1;
if ~flag
    SS1 = nanvar(x1,flag,dim).*df1;
else
    SS1 = nanvar(x1,flag,dim).*n1;
end
n2 = sum(~isnan(x2),dim);
df2 = n2-1;
if ~flag
    SS2 = nanvar(x2,flag,dim).*df2;
else
    SS2 = nanvar(x2,flag,dim).*df2;
end

if ~flag
    Vp = (SS1+SS2)./(df1+df2);
else
    Vp = (SS1+SS2)./(n1+n2);
end

Ve = (Vp./n1+Vp./n2);
se = sqrt(Ve);