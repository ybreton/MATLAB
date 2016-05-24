function [b,SSerr,bci] = fit_2forced_choice(X,Y,varargin)
%
%
%
%

intercept = true;
alpha = 0.05;
debug = false;
process_varargin(varargin);
nboot = 10^-(floor(log10(alpha/2))-1);

if min(size(X)) == 1
    X = X(:);
end

if intercept == true;
    X = [ones(size(X,1),1) X];
end
[X,idSort] = sortrows(X);
Y = Y(idSort);

b = zeros(size(X,2),1);

OPTIONS = optimset('algorithm','interior-point');
b = fminsearch(@(b) errFunc(X,Y,b,debug),b,OPTIONS);
SSerr = errFunc(X,Y,b,debug);

if nargout>2
    K = size(X,2);
    for k = 1 : K
        [~,bootsam(:,:,k)] = bootstrp(nboot,@mean,X(:,k));
    end
    parfor boot = 1 : nboot
        bList = fminsearch(@(b) errFunc(X,Y,b,false),b,OPTIONS);
        for k = 1 : K
            SDb(boot,k) = bList(k);
        end
    end
    blo = prctile(SDb,100*alpha/2,1);
    bhi = prctile(SDb,100*(1-alpha/2),1);
    bci = [blo;bhi];
end

function SSerr = errFunc(X,Y,b,debug)
b = b(:)';

predY = softmax(X,b);
predY = predY(:,2);
dev = predY-Y;
SSerr = dev'*dev;
if debug
    cla
    hold on
    plot(X(:,2),Y,'ko')
    plot(X(:,2),predY,'r-')
    hold off
    drawnow
end

function predY = softmax(X,b)

numerator = exp(1).^[X(:,1)*prod(b) X(:,2)*b(2)];
predY = numerator./repmat(sum(numerator,2),1,size(numerator,2));