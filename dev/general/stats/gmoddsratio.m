function [OR,fh] = gmoddsratio(x,gmdist_obj,varargin)
% Returns the odds ratio of each distribution for a value of x.
% OR = gmoddsratio(x,gmdist_obj,varargin)
% where     OR          is a n x k x k matrix of odds ratios,
%           x           is a n x d matrix of x values for the odds ratio,
%           gmdist_obj  is a gmdistribution object with k components in d
%                       dimensions
% OPTIONAL ARGUMENTS
%           plotORs     will plot the log-odds ratio if there is one
%                       dimension for each unique pair of components.
%

plotORs = true;
xaxislabel = cell(size(x,2),1);
xaxislabel(1:end) = {'X'};
process_varargin(varargin);
if ischar(xaxislabel)
    xaxislabel = {xaxislabel};
end

MU = gmdist_obj.mu;
SIGMA = gmdist_obj.Sigma;
TAU = gmdist_obj.PComponents;
diagonal = size(SIGMA,1)==1;
restricted = gmdist_obj.SharedCov;

if any(size(x)==1)
    x = x(:);
end
assert(size(x,2)==size(MU,2),'Input vector must have same dimensionality as the gaussian mixture fit.');

PX = nan(size(x,1),size(MU,1));
for k = 1 : size(MU,1)
    mu = MU(k,:);
    if diagonal && ~restricted
        sigma = zeros(size(MU,2));
        for d = 1 : size(MU,2)
            sigma(d) = SIGMA(1,d,k);
        end
    elseif diagnonal && restricted
        sigma = zeros(size(MU,2));
        for d = 1 : size(MU,2)
            sigma(d,d) = SIGMA(1,d);
        end
    elseif ~diagonal && ~restricted
        sigma = SIGMA(:,:,k);
    elseif ~diagonal && restricted
        sigma = SIGMA;
    end
    if size(x,2)>1
        PX(:,k) = 1-mvncdf(x,mu,sigma);
    else
        PX(:,k) = 1-normcdf(x,mu,sigma);
    end
    s(:,:,k) = sigma;
end

% PX contains P(X>=x|Dk) for all dimensions

PD = repmat(TAU, size(PX,1),1);
% PD contains P(Dk) for each dimension

numerator = PX.*PD;
% numerator contains P(X>=x|Dk)*P(Dk) for each x and Dk
Pdata = sum(numerator,2);
% Pdata contains P(X>=x) for each x
denominator = repmat(Pdata,1,size(numerator,2));
% denominator contains P(X>=x) for each x and Dk
Posterior = numerator./denominator;
% Posterior contains P(Dk|X>=x) for each x and Dk

OR = nan(size(Posterior,1),size(Posterior,2),size(Posterior,2));
for k1 = 1 : size(Posterior,2)-1
    for k2 = k1+1 : size(Posterior,2)
        OR(:,k1,k2) = Posterior(:,k1)./Posterior(:,k2);
    end
end
% OR contains P(Dk|X>=x)/P(Dj|X>=x) for each x, Dk and Dj
if size(OR,3)<=2
    OR = OR(:,1,2);
    OR = squeeze(OR);
end
% if there are only 2 distributions, remove the extraneous dimension. We
% are only going to want to compare 1 vs 2. When there are two
% distributions, OR(:,1) = P(D1|X>=x)/P(D2|X>=x).

if plotORs
    for d = 1 : size(x,2)
        figure;
        if strcmpi(xaxislabel{d},'X')
            set(gcf,'name',sprintf('Dimension %d',d))
        else
            set(gcf,'name',sprintf('Dimension %d: %s',d,xaxislabel{d}))
        end
        sds = sqrt(s(d,d,:));
        if size(OR,3)>1
            p = 1;
            for k1 = 1 : size(OR,2)
                for k2 = 1 : size(OR,3)
                    X = x(:,d);
                    [X,id] = sort(X);
                    Y = OR(:,k1,k2);
                    Y = Y(id);
                    if ~all(isnan(Y));
                        subplot(size(OR,2),size(OR,3),p)
                        hold on
                        plot(X,log10(Y),'k-','linewidth',2)
                        xlabel('X')
                        ylabel(sprintf('Log_{10}[OR]\n(\\mu=%.2f,\\sigma=%.2f:\\mu=%.2f,\\sigma=%.2f)',MU(k1),sds(1,1,k1),MU(k2),sds(1,1,k2)));
                        hold off
                    end
                    p = p+1;
                end
            end
        else
            X = x(:,d);
            [X,id] = sort(X);
            Y = OR(:,1);
            Y = Y(id);
            hold on
            plot(X,log10(Y),'k-','linewidth',2)
            xlabel(xaxislabel{d})
            ylabel(sprintf('Log_{10}[OR]\n(\\mu=%.2f,\\sigma=%.2f:\\mu=%.2f,\\sigma=%.2f)',MU(k1),sds(1,1,k1),MU(k2),sds(1,1,k2)));
            hold off
        end
        if nargout>1
            fh(d) = gcf;
        end
    end
end