function postHoc = PostHocPairwiseComps(Y,X,varargin)

alpha = 0.05;
ctype = 'Bonferroni';
comparisons = [];
subjects = [];
gnames = unique(X,'rows');
process_varargin(varargin);

G = unique(X,'rows');
Ybar = nan(size(G,1),1);
n = Ybar;
SSs = n;
uniqueSubj = unique(subjects);

for c = 1 : size(G,1)
    id = all(X==repmat(G(c,:),size(X,1),1),2);
    Ybar(c) = nanmean(Y(id));
    
    % if subjects is empty, each score in group G(c,:) is an individual.
    if isempty(subjects)
        n(c) = length(Y(id));
        SSs(c) = (Y(id)-Ybar(c))'*(Y(id)-Ybar(c));
    else
    % if subjects is a vector of subject identifiers, first get average
    % subject's score for each subject.
        for s = 1 : length(uniqueSubj)
            idSubj = uniqueSubj(s)==subjects;
            Ys(s) = Y(id&idSubj);
        end
        % Each subject's mean score,
        
    end
end
s2 = SSs./(n-1);

if isempty(comparisons)
    k = 0;
    for c1 = 1 : length(G)-1
        for c2 = c1+1 : length(G)
            k = k+1;
            comparisons(k,c1) = 1;
            comparisons(k,c2) = -1;
        end
    end
end
nComps = size(comparisons,1);

if strcmpi(ctype,'Bonferroni');
    alpha_PC = alpha/nComps;
elseif strcmpi(ctype,'Exact');
    alpha_PC = 1 - (1-alpha).^(1/nComps);
end

psi = comparisons*Ybar;
nh = size(G,1)/(sum(1./n));
SScomp = nh*psi.^2./sum((comparisons.^2),2);
MSerr = sum(comparisons.^2*s2,2)./sum(comparisons.^2,2);
dferr = sum(abs(comparisons)*(n-1),2)./max(abs(comparisons),[],2);

F = SScomp./MSerr;

t = sqrt(F);
p = 1-tcdf(t,dferr);
sig = p<alpha_PC;

postHoc.diffs = psi;
postHoc.MScomp = SScomp;
postHoc.MSerr = MSerr;
postHoc.dferr = dferr;
postHoc.t = t;
postHoc.p = p;
postHoc.sig = sig;

DATA = cat(2,gnames,psi,SScomp,MSerr,dferr,t,p,sig);
HEADER = {mat2can(1:size(gnames,2)) 'diff' 'MScomp' 'MSerr' 'dferr' 't' 'p' 'sig'};

postHoc.Table = cat(1,HEADER,mat2can(DATA));
