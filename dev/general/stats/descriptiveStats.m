function stats = descriptiveStats(s,DVs,IVs,varargin)
% Calculate descriptive statistics of each DV field in DVs, using IV fields
% in IVs as predictors, for structure array s.
% If there are no predictors, will only produce the overall descriptives
% for each outcome.
% If there is one predictor, will only produce the overall descriptives and
% the marginal descriptives for each outcome.
% If there are multiple predictors, will produce the overall descriptives,
% marginal descriptives, and cell descriptives for each outcome.
%
% stats = descriptiveStats(s,DVs)
% stats = descriptiveStats(s,DVs,IVs)
% where     s       is a structure array
%           DVs     is a string or cell array of strings with field names
%                   for the dependent (outcome) variables
%           IVs     is a string or cell array of strings with field names
%                   for the independent (predictor) variables
%
%           stats   is a structure with fields
%
%   .input      inputname for the input structure s
%   .IV         field names of predictor variables for marginal and cell means
%   .numeric    logical indicating that the predictor is numeric
%   .(IV)       unique levels of each predictor
%   .DV         field names of outcome variables
%
%   .raw        vectors of each variable.
%
%   .correl     correlation tables for each outcome, broken down for the DV
%               as
%               .(DV).varnames, variable names for the correlation table
%               entries
%               .(DV).r, the correlation table
%               .(DV).p, the p-value associated with the correlation
%               .(DV).rLo, the lower bound of the confidence interval
%               around the correlation
%               .(DV).rLo, the upper bound of the confidence interval
%               around the correlation
%               .(DV).ncomp, the number of comparisons made
%               .(DV).alpha, the adjusted error rate for statistical
%               significance
%               .(DV).sig, flags statistically significant correlations,
%               (Bonferroni-)adjusting for the number of correlation pairs
%               tested
%               If DVs are categorical, all categorical vectors are tested.
%
%   .overall    descriptives for each outcome, broken down for the DV as
%               .(DV)
% 
% If predictors (IVs) have been specified, the following will be produced
% 
%   .marginals  descriptives for marginal means for each outcome, broken
%               down for the marginal mean of DV at n levels of the IV in 
%               1 x n arrays as
%               .(DV).(IV)
%   .cellmeans  descriptives for cell means for each outcome, broken down
%               for the DV in n x m x ... x p arrays as
%               .(DV)
%
% Descriptives are
%   .(IV)       value of predictor for cell and marginal descriptive statistics
% 	.n          number of valid cases
%   .df         number of degrees of freedom
%   .sum        sum of valid cases
%   .m          mean of valid cases
%   .s          (unbiased) standard deviation of valid cases
%   .v          (unbiased) variance of valid cases
%   .se         standard error of the mean
%   .alpha      type-I (false-positive) error rate
%   .tcrit      critical t statistic for statistical significance testing
%   .CBlo       lower bound of confidence interval
%   .CBhi       upper bound of confidence interval
%   .rangeLo    lower bound of range
%   .rangeHi    upper bound of range
%   .median     median of valid cases
%   .Q1         first quartile
%   .Q3         third quartile
%   .bootLo     lower bound of bootstrapped confidence interval
%   .bootHi     upper bound of bootstrapped confidence interval
%   .bootMid    median of bootstrapped sampling distribution of the mean
%   .mode       mode of cases; empty if none
%
% OPTIONAL ARGUMENTS:
% ******************
% alpha         (default 0.05)
%       type-I (false-positive) error rate for confidence interval and
%       critical t calculations.
% includeRaw    (default true)
%       adds field "raw" to output structure with vector of each predictor
%       and outcome.
%
% Example:
% s.y = randn(2,2,100);
% s.x1 = nan(2,2,100);
% s.x1(1,:,:) = 1;
% s.x1(2,:,:) = 2;
% s.x2.A = false(2,2,100);
% s.x2.B = false(2,2,100);
% s.x2.A(:,1,:) = true;
% s.x2.B(:,2,:) = true;
% s.x2.Names(s.x2.A) = {'A'};
% s.x2.Names(s.x2.B) = {'B'};
% 
% s is a structure array with fields x1, x2, and y. x1 is a numerical
% predictor, x2 is a categorical predictor, and y is a continuous outcome.
% We want to know the descriptive statistics of y based on no predictors
% (overall descriptives), each predictor individually (marginals
% descriptives), and each combination of predictors (cellmeans
% descriptives).
%
% >> stats = descriptiveStats(s,'y',{'x1' 'x2'})
%
% stats = 
% 
%         input: 's'
%            IV: {'x1'  'x2'}
%       numeric: [1 0]
%            x1: [2x1 double]
%            x2: {2x1 cell}
%            DV: {'y'}
%           raw: [1x1 struct]
%        correl: [1x1 struct]
%       overall: [1x1 struct]
%     marginals: [1x1 struct]
%     cellmeans: [1x1 struct]
%
% This stats structure indicates that 
%   - the input structure is s,
%   - IVs are the fields x1 and x2 that were found in s, 
%   - x1 is numeric and x2 is non-numeric, 
%   - the two values of x1 are 1 and 2, 
%   - the two values of x2 are 'A' and 'B',
%   - DVs are the field y that was found in s,
% The stats structure assembles
%   - raw data that has been analyzed in raw for each IV (x1,x2) and DV (y),
%
%   stats.raw
%     x1: [4000x1 double]
%     x2: [1x1 struct]
%      y: [4000x1 double]
%   stats.raw.x2
%      A: [400x1 logical]
%      B: [400x1 logical]
%  Names: {400x1 cell}
% 
%   - correlation data among the IVs (x1, x2) and y in correl, with variable
%   names (varnames), correlation table (r), p-value table (p), lower and
%   upper bounds of correlation confidence interval (rLo, rHi), number of
%   comparisons (ncomp), adjusted error rate (alpha), and statistical
%   significance adjusting for 3 comparisons (sig)
%   
%   stats.correl.y
%     varnames: {'x1'  'x2'  'y'}
%            r: [3x3 double]
%            p: [3x3 double]
%          rLo: [3x3 double]
%          rHi: [3x3 double]
%        ncomp: 3
%        alpha: 0.0167
%          sig: [3x3 logical]
%   
%   - overall descriptive statistics of y without taking any predictors into
%   account
%   
%   stats.overall.y
%           n: 400
%          df: 399
%         sum: 32.3430
%           m: 0.0809
%           s: 0.9691
%           v: 0.9391
%          se: 0.0485
%       alpha: 0.0500
%       tcrit: 1.9659
%        CBlo: -0.0144
%        CBhi: 0.1761
%     rangeLo: -2.6600
%     rangeHi: 2.5354
%      median: 0.0597
%          Q1: -0.5281
%          Q3: 0.6580
%       nboot: 1000
%      bootLo: -0.0105
%      bootHi: 0.1767
%     bootMid: 0.0820
%        mode: {}
%
%   - marginal descriptive statistics of y taking each predictor into account
%
%   stats.marginals.y
%     x1: [1x1 struct]
%     x2: [1x1 struct]
%   stats.marginals.y.x1
%          x1: {[1]  [2]}
%           n: [200 200]
%          df: [199 199]
%         sum: [25.5555 6.7875]
%           m: [0.1278 0.0339]
%           s: [0.9681 0.9702]
%           v: [0.9372 0.9413]
%          se: [0.0685 0.0686]
%       alpha: [0.0500 0.0500]
%       tcrit: [1.9720 1.9720]
%        CBlo: [-0.0072 -0.1013]
%        CBhi: [0.2628 0.1692]
%     rangeLo: [-2.5400 -2.6600]
%     rangeHi: [2.5201 2.5354]
%      median: [0.1194 0.0252]
%          Q1: [-0.4824 -0.5906]
%          Q3: [0.7550 0.5975]
%       nboot: [1000 1000]
%      bootLo: [-0.0035 -0.0982]
%      bootHi: [0.2609 0.1653]
%     bootMid: [0.1309 0.0342]
%        mode: {{}  {}}
%
%   - cellmeans descriptive statistics of y taking all predictors into
%   account
%
%   stats.cellmeans.y
%          x1: {2x2 cell}
%          x2: {2x2 cell}
%           n: [2x2 double]
%          df: [2x2 double]
%         sum: [2x2 double]
%           m: [2x2 double]
%           s: [2x2 double]
%           v: [2x2 double]
%          se: [2x2 double]
%       alpha: [2x2 double]
%       tcrit: [2x2 double]
%        CBlo: [2x2 double]
%        CBhi: [2x2 double]
%     rangeLo: [2x2 double]
%     rangeHi: [2x2 double]
%      median: [2x2 double]
%          Q1: [2x2 double]
%          Q3: [2x2 double]
%       nboot: [2x2 double]
%      bootLo: [2x2 double]
%      bootHi: [2x2 double]
%     bootMid: [2x2 double]
%        mode: {2x2 cell}
%   
%   In this case, IV order will set dimensionality and size of the cell
%   means fields.
%

if nargin<3
    IVs = {};
end

alpha = 0.05;
includeRaw = true;
process_varargin(varargin);

stats.input = inputname(1);

% Checks on input

if ischar(IVs)
    IVs = {IVs};
end
if ischar(DVs)
    DVs = {DVs};
end

k = length(IVs);
m = length(DVs);

for iIV=1:k
    assert(isfield(s,IVs{iIV}),['Field ' IVs{iIV} ' does not exist in input structure.'])
    if isstruct(s.(IVs{iIV}))
        assert(isfield(s.(IVs{iIV}),'Names'), ['Categorical predictor structure ' IVs{iIV} ' must have a Names subfield.']);
    end
end
for iDV=1:m
    assert(isfield(s,DVs{iDV}),['Field ' DVs{iDV} ' does not exist in input structure.'])
    if isstruct(s.(DVs{iDV}))
        assert(isfield(s.(DVs{iDV}),'Names'), ['Categorical outcome structure ' DVs{iDV} ' must have a Names subfield.']);
    end
end

nIV = nan(k,1);
for iIV=1:k
    x = s.(IVs{iIV});
    if isstruct(x)
        x = x.Names;
    end
    nIV(iIV) = numel(x);    
end
nDV = nan(m,1);
for iDV=1:m
    y = s.(DVs{iDV});
    if isstruct(y)
        y = y.Names;
    end
    nDV(iDV) = numel(y);    
end

% check 1: all n's for IVs are the same.
id1 = repmat(nIV(:),1,length(nIV(:)))==repmat(nIV(:)',length(nIV(:)),1);
% check 2: all n's for DVs are the same.
id2 = repmat(nDV(:),1,length(nDV(:)))==repmat(nDV(:)',length(nDV(:)),1);
% check 3: all n's for IVs are the same as the n's for the DVs.
id3 = repmat(nIV(:),1,length(nDV(:)))==repmat(nDV(:)',length(nIV(:)),1);

assert(all(id1(:))&&all(id2(:))&&all(id3(:)),'IVs and DVs must all have same number of elements.');
n = nanmedian([nIV(:);nDV(:)]);

% Unique combinations of IVs for cell and marginals
X = nan(n,k);
Xvals = cell(n,k);
num = false(1,k);
for iIV=1:k
    x = s.(IVs{iIV});
    if isstruct(x)
        x0 = x;
        idvalid = ~cellfun(@isempty,x.Names);
        [~,~,ic] = unique(x.Names(idvalid));
        
        x = nan(n,1);
        x(idvalid) = ic;
        x(~idvalid) = nan;
        
        Xvals(:,iIV) = x0.Names(:);
        num(iIV) = false;
    elseif iscell(x)
        x0 = x;
        idvalid = ~cellfun(@isempty,x);
        [~,~,ic] = unique(x(idvalid));
        
        x = nan(n,1);
        x(idvalid) = ic;
        x(~idvalid) = nan;
        
        Xvals(:,iIV) = x0(:);
        num(iIV) = false;
    else
        Xvals(:,iIV) = mat2can(x(:));
        
        idvalid = ~isnan(x);
        [~,~,ic] = unique(x(idvalid));
        
        x = nan(n,1);
        x(idvalid) = ic;
        x(~idvalid) = nan;
        num(iIV) = true;
    end
    
    X(:,iIV) = x(:);
end
[uniqueX,ia] = unique(X,'rows');
sz = max(uniqueX,[],1);
nDim = length(sz);
if nDim<2
    sz = [sz 1];
end
uniqueVals = Xvals(ia,:);

% Summarize data to be described.
stats.IV = IVs;
stats.numeric = num;
for iIV=1:length(IVs)
    if num(iIV)
        stats.(IVs{iIV}) = unique(can2mat(uniqueVals(:,iIV)));
    else
        stats.(IVs{iIV}) = unique(uniqueVals(:,iIV));
    end
end
stats.DV = DVs;

% Add raw data
if includeRaw
    
    for iIV=1:k
        x = s.(IVs{iIV});
        if isstruct(x)
            fields = fieldnames(x);
            
            for iF=1:length(fields)
                stats.raw.(IVs{iIV}).(fields{iF}) = x.(fields{iF})(:);
            end
        else
            stats.raw.(IVs{iIV}) = x(:);
        end
    end
    for iDV=1:m
        y = s.(DVs{iDV});
        if isstruct(y)
            fields = fieldnames(y);
            
            for iF=1:length(fields)
                stats.raw.(DVs{iDV}).(fields{iF}) = y.(fields{iF})(:);
            end
        else
            stats.raw.(DVs{iDV}) = s.(DVs{iDV})(:);
        end
    end
end

% Begin processing descriptive statistics.
disp([num2str(m) ' outcome variables requested.'])
for iDV=1:m
    DV = DVs{iDV};
    disp(['Processing DV ' DV ':']);
    Y = s.(DV)(:);
    disp('Overall statistics...')
    id = [];
    
    if isstruct(Y)
        fields = fieldnames(Y);
        fields = fields(~ismember(fields,'Names'));
        y = nan(n,length(fields));
        DV0 = cell(1,length(fields));
        for iF=1:length(fields)
            y(:,iF) = Y.(fields{iF})(:);
            DV0{iF} = [DV '=' fields{iF}];
        end
    elseif iscell(Y)
        idvalid = ~cellfun(@isempty,Y);
        [uniqueY,~,ic] = unique(Y(idvalid));
        y = nan(n,length(uniqueY));
        DV0 = cell(1,length(uniqueY));
        for iF=1:length(uniqueY)
            y(idvalid,iF) = ic==iF;
            DV0{iF} = [DV '=' uniqueY(iF)];
        end
    else
        y = Y;
        DV0 = DV;
    end
    stats.correl.(DV).varnames = cat(2,IVs,DV0);
    [stats.correl.(DV).r,stats.correl.(DV).p,stats.correl.(DV).rLo,stats.correl.(DV).rHi] = corrcoef([X y],'alpha',alpha,'rows','pairwise');
    if length(stats.correl.(DV).varnames)>1
        ncomp = nchoosek(length(stats.correl.(DV).varnames),2);
    else
        ncomp = 1;
    end
    stats.correl.(DV).ncomp = ncomp;
    stats.correl.(DV).alpha = alpha/ncomp;
    stats.correl.(DV).sig = double(stats.correl.(DV).p<(alpha/ncomp));
    stats.correl.(DV).sig(eye(size(stats.correl.(DV).sig))==1) = nan;
    
    stats.overall.(DV) = desc(Y,id,alpha);
    statsFields = fieldnames(stats.overall.(DV));
    
    for iIV=1:k
        IV = IVs{iIV};
        disp(['Marginal statistics for ' IV ':'])
        [x,ia] = unique(uniqueX(:,iIV));
        uniqueV = uniqueVals(ia,iIV);
        disp([num2str(length(x)) ' levels of ' IV ' along dimension ' num2str(iIV) '.'])
        
        rs = ones(1,length(sz));
        rs(iIV) = length(x);
        
        stats.marginals.(DV).(IV).(IV) = reshape(uniqueV(x(:)),rs);
        
        for iField=1:length(statsFields);
            if ~iscell(stats.overall.(DV).(statsFields{iField}))
                stats.marginals.(DV).(IV).(statsFields{iField}) = reshape(nan(1,length(x)),rs);
            else
                stats.marginals.(DV).(IV).(statsFields{iField}) = reshape(cell(1,length(x)),rs);
            end
        end
        
        for iLvl=1:length(x)
            id = X(:,iIV)==x(iLvl);
            stats0 = desc(Y,id,alpha);
            for iField=1:length(statsFields);
                if ~iscell(stats.marginals.(DV).(IV).(statsFields{iField}))
                    stats.marginals.(DV).(IV).(statsFields{iField})(iLvl) = stats0.(statsFields{iField});
                else
                    stats.marginals.(DV).(IV).(statsFields{iField}){iLvl} = stats0.(statsFields{iField});
                end
            end
        end
    end
    
    if k>1
        disp('Cell mean statistics ')
        for iIV=1:k
            IV = IVs{iIV};
            stats.cellmeans.(DV).(IV) = cell(sz);
        end
        for iField=1:length(statsFields)
            if ~iscell(stats.overall.(DV).(statsFields{iField}))
                stats.cellmeans.(DV).(statsFields{iField}) = nan(sz);
            else
                stats.cellmeans.(DV).(statsFields{iField}) = cell(sz);
            end
        end
        disp(['Processing cell statistics for ' num2str(size(uniqueX,1)) ' cells.'])

        for iCombo=1:size(uniqueX,1)
            id = all(repmat(uniqueX(iCombo,:),size(X,1),1)==X,2);
            indices = uniqueX(iCombo,:);
            str = '';
            for iDim=1:nDim
                str = [str num2str(indices(iDim)) ','];
            end
            if nDim<2
                str = [str '1,'];
            end
            str = str(1:end-1);
            evalStr = ['sub2ind(sz,' str ');'];
            lindex = eval(evalStr);

            for iIV=1:k
                IV = IVs{iIV};
                stats.cellmeans.(DV).(IV)(lindex) = uniqueVals(iCombo,iIV);
            end

            stats0 = desc(Y,id,alpha);
            for iField=1:length(statsFields);
                if ~iscell(stats.cellmeans.(DV).(statsFields{iField}))
                    stats.cellmeans.(DV).(statsFields{iField})(lindex) = stats0.(statsFields{iField});
                else
                    stats.cellmeans.(DV).(statsFields{iField}){lindex} = stats0.(statsFields{iField});
                end
            end
        end
    end
end

function s = desc(y,id,alpha)
if isstruct(y)
    y = y.Names;
end
if isempty(id)
    id = true(size(y));
end
y0 = y(id);
s = ds(y0,alpha);

function s = ds(y,alpha)
% 	.n          number of valid cases
%   .df         number of degrees of freedom
%   .m          mean of valid cases
%   .s          (unbiased) standard deviation of valid cases
%   .v          (unbiased) variance of valid cases
%   .se         standard error of the mean
%   .CBlo       lower bound of confidence interval
%   .CBhi       upper bound of confidence interval
%   .median     median of valid cases
%   .Q1         first quartile
%   .Q3         third quartile
%   .bootLo     lower bound of bootstrapped confidence interval
%   .bootHi     upper bound of bootstrapped confidence interval
%   .bootMid    median of bootstrapped sampling distribution of the mean

nboot = 10^(-floor(log10(alpha/2))+1);
num = ~iscell(y);
if iscell(y)
    idvalid = ~cellfun(@isempty,y);
    [~,~,iC]=unique(y(idvalid));
    names = y;
    y = nan(length(y),1);
    y(idvalid) = iC;
    y(~idvalid) = nan;
else
    idvalid = ~isnan(y);
end

y0 = y(idvalid);
y0 = double(y0(:));

s.n = sum(idvalid(:));
s.df = sum(idvalid(:))-1;
s.sum = nansum(y0);
s.m = nanmean(y0);
s.s = nanstd(y0);
s.v = nanvar(y0);
s.se = nanstderr2(y0);
s.alpha = alpha;
s.tcrit = tinv(1-(alpha/2),s.df);
s.CBlo = s.m+s.se*tinv(alpha/2,s.df);
s.CBhi = s.m+s.se*tinv(1-(alpha/2),s.df);
s.rangeLo = nanmin(y0);
s.rangeHi = nanmax(y0);
s.median = nanmedian(y0);
s.Q1 = prctile(y0,25);
s.Q3 = prctile(y0,75);

[~,bootsam] = bootstrp(nboot,@mean,y0);
yBoot = y0(bootsam);
mBoot = nanmean(yBoot,1);

s.nboot = nboot;
s.bootLo = prctile(mBoot,(alpha/2)*100);
s.bootHi = prctile(mBoot,(1-(alpha/2))*100);
s.bootMid = median(mBoot);

[uniqueY,ia] = unique(y0);
n = nan(length(uniqueY),1);
parfor iY=1:length(uniqueY);
    n(iY) = nansum(y0==uniqueY(iY));
end
[maxN,idMax] = max(n);
ties = nansum(n==maxN)>1;
if ~ties
    if num
        s.mode = {uniqueY(idMax)};
    else
        uniqueNames = names(ia);
        s.mode = uniqueNames(idMax);
    end
else
    s.mode = {};
end