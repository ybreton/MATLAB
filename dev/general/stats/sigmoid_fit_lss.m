function [b,r,rsq,bCI,rCI] = sigmoid_fit_lss(x,y,const,varargin)
%
%
%
%
tol = 1e-3;
debug = false;
constrainRange = true;
[x,id] = sortrows(x);
y = y(id);

% default starting range and coefficients
r = [max(y)+0.1*(max(y)-min(y)) min(y)-0.1*(max(y)-min(y))];
if const
    b = glmfit(x,(y-r(2))./(r(1)-r(2)),'normal','link','logit','constant','on');
else
    b = glmfit(x,(y-r(2))./(r(1)-r(2)),'normal','link','logit','constant','off');
end

process_varargin(varargin);


errNew = errFunc(x,y,b,r,const,debug);

% For fitting range, min-max<=0
A = [-1 1];
B = 0;
% For fitting range, if constrained, lower bound is min(y) and upper bound
% is max(y). Since min<=max, UB for min is (max-min)/2+min and LB for max
% is (max-min)/2+min.
if constrainRange
    y50 = (max(y)-min(y))/2+min(y);
    LB = [y50 min(y)];
    UB = [max(y) y50];
else
    LB = [];
    UB = [];
end

t = 0;
converge = false;
options = optimset('algorithm','interior-point','display','off');
while ~converge & t<=500
    r0 = r;
    b0 = b;
    errOld = errNew;
    
    r = fmincon(@(r) errFunc(x,y,b,r,const,debug),r0,A,B,[],[],LB,UB,[],options);
    b = fminsearch(@(b) errFunc(x,y,b,r,const,debug),b0,options);
    
    errNew = errFunc(x,y,b,r,const,debug);
    deltaR = r - r0;
    deltaB = b - b0;
    
    difference = errOld-errNew;
    if difference<tol
        converge = true;
    end
    if all(abs(deltaR)<tol)&all(abs(deltaB)<tol)
        converge = true;
    end
    
    t = t+1;
end
yPred = scaled_logit(x,b,r,const);
SSpred = (yPred(:)'-mean(yPred))*(yPred(:)-mean(yPred));
SStot = (y(:)'-mean(y))*(y(:)-mean(y));
rsq = SSpred/SStot;

if nargout>3
    [stat,sam]=bootstrp(1000,@mean,y);
    nboot = size(sam,2);
    bList = nan(length(b),nboot);
    rList = nan(length(r),nboot);
    parfor boot = 1 : nboot
        iboot = sam(:,boot);
        yboot = y(iboot);
        xboot = x(iboot,:);
        % fit sigmoid to bootstrap-sampled x,y pairs using r and b from fit
        % as starting values.
        [bboot,rboot] = sigmoid_fit_lss(xboot,yboot,const,'tol',tol,'debug',false,'r',r,'b',b);
        bList(:,boot) = bboot(:);
        rList(:,boot) = rboot(:);
    end
    blo = nan(length(b),1);
    bhi = nan(length(b),1);
    rlo = nan(length(r),1);
    rhi = nan(length(r),1);
    parfor parm = 1 : size(blo,1)
        bparm = bList(parm,:);
        blo(parm) = prctile(bparm,2.5);
        bhi(parm) = prctile(bparm,97.5);
    end
    parfor parm = 1 : size(rlo,1)
        rparm = rList(parm,:);
        rlo(parm) = prctile(rparm,2.5);
        rhi(parm) = prctile(rparm,97.5);
    end
    bCI = [blo bhi];
    rCI = [rlo rhi];
end


function err = errFunc(x,y,b,r,const,debug)
yPred = scaled_logit(x,b,r,const);
dev = yPred(:)-y(:);
err = dev(:)'*dev(:);

if debug
    clf
    hold on
    plot(x,y,'ko')
    plot(x,yPred,'r-')
    hold off
    drawnow
end
