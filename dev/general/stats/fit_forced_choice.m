function [b,SSerr,bci] = fit_forced_choice(X,Y,varargin)
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
if min(size(Y)) == 1
    Y = Y(:);
    Y = [1-Y Y];
end

if intercept == true;
    X = [ones(size(X,1),1) X];
end
[X,idSort] = sortrows(X);
Y = Y(idSort,:);

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

function inversePrec = errFunc(X,Y,b,debug)
b = b(:)';

predY = softmax(X,b);
dev = predY-Y;
SSerr = dev'*dev;
determinant = det(SSerr);
inversePrec = 1/determinant;

function predY = softmax(X,b)

% numerator = nan(size(X));
exponent = repmat(b(:)',size(X,1),1).*X;

numerator = exp(1).^exponent;
% for k = 1 : size(b,2)
%     numerator(:,k) = exp(1).^(b(k)*X(:,k));
% end
predY = numerator./repmat(sum(numerator,2),1,size(numerator,2));
