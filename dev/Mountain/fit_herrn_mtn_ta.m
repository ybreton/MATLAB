function rpt_mtn = fit_herrn_mtn_ta(SSN,Amnt,Po,Pr,Zone,TA,varargin)

makeCIs = false;
process_varargin(varargin);

X = [SSN log10(Amnt) log10(Po) Pr Zone];
Y = TA;
uniqueX = unique(X,'rows');
y = nan(size(uniqueX,1),1);
for iX = 1 : length(uniqueX)
    comparison = repmat(uniqueX(iX,:),size(X,1),1);
    idX = all(comparison==X,2);
    y(iX) = nanmean(TA(idX));
end
x = uniqueX(:,2:end);
X = X(:,2:end);
% TA = y;

nBoots = 1000;

% x = [log10(Amnt) log10(Po) Pr Zone];
nZones = length(unique(Zone));

options = optimset('algorithm','interior-point','display','off');

% Ain * params <= bin
% [A; S0; Sp; Ce; flvr]
Ain = [];
bin = [];
% Aeq * params == bin
% [A; S0; Sp; Ce; flvr]
Aeq = [];
beq = [];
% params >= lb
% [A; k; S0; Sp; Ce; flvr]
lb = [0 0 0 0 -inf 0 -2*ones(1,nZones-1)];
% params <= ub
% [A; k; S0; Sp; Ce; flvr]
ub = [20 20 1 inf 20 0 2*ones(1,nZones-1)];

params0 = [4 1 eps 1 0 zeros(1,nZones)];

[params,err] = fmincon(@(params) lsq_err(X,TA,params),params0,Ain,bin,Aeq,beq,lb,ub,[],options);
Dev = TA(:)-mean(TA(:));
tot = (Dev(:)')*(Dev(:));
Rsq = (tot-err)/tot;
fprintf('\nR^2=%.3f \n',Rsq);
predTA = ez_herrn_mtn_ta(X,params);
SStot = (TA(:)-mean(TA))'*(TA(:)-mean(TA));
SSpred = (predTA(:)-mean(predTA(:)))'*(predTA(:)-mean(predTA(:)));
Rsq = SSpred/SStot;
rpt_mtn.Mtn_primary_fit.HEADER = {'A' 'k' 'S(Pr=0)' 'S1*Pr' 'Ce'};
for z = 1 : nZones
    rpt_mtn.Mtn_primary_fit.HEADER{end+1} = sprintf('Fhm%d',z);
end
rpt_mtn.Mtn_primary_fit.DATA = params;

fprintf('\n Primary fit:\n')
fprintf('A\t\tk\t\tS0\t\tS1\t\tCe\t\tFhm\n')
fprintf(['\t\t\t\t\t\t\t\t\t\t' sprintf('Z%d\t\t',1:nZones) '\n'])
fprintf('%.3f\t',params(1:5))
fprintf('%.3f\t',10.^params(6:end))
fprintf('\n')

if makeCIs
    rows = 1 : size(X,1);
    uniqueSSN = unique(SSN);
    bootrow = [];
    for iSSN = 1 : length(uniqueSSN)
        if iscell(uniqueSSN)
            idx = strcmpi(uniqueSSN{iSSN},SSN);
        else
            idx = uniqueSSN(iSSN)==SSN;
        end
        SSNrows = rows(idx);
        [m,bootsam] = bootstrp(nBoots,@mean,SSNrows);
        % bootsam has the 1000 permutations of SSNrows.
        % we'll be adding 
        if isempty(bootrow)
            bootrow = SSNrows(bootsam);
        else
            bootrow = [bootrow; SSNrows(bootsam)];
        end
    end
    pList = nan(nBoots,length(params));
    t0 = clock;
    pList = [];
    for ten = 1 : nBoots/10;
        pList0 = nan(10,length(params));
        parfor boot = 1 : 10
            rowIndices = bootrow(:,boot);
            xBoot = X(rowIndices,:);
            TAboot = TA(rowIndices);
            p = fmincon(@(params) lsq_err(xBoot,TAboot,params),params,Ain,bin,Aeq,beq,lb,ub,[],options);
            pList0(boot,:) = p;
        end
        fprintf('.')
        pList = [pList;pList0];
        if mod(ten,10)==0
            t1 = clock;
            fprintf('\n')
            elapsed = etime(t1,t0);
            tper = elapsed/(10*ten);
            remaining = (nBoots-(10*ten))*tper;
            fprintf('Elapsed:%.1f\tRemaining:%.1f',elapsed,remaining)
            fprintf('\n')
        end

    end
    DATA(1,:) = median(pList,1);
    DATA(2,:) = prctile(pList,2.5,1);
    DATA(3,:) = prctile(pList,97.5,1);
    DATA(4,:) = DATA(3,:)-DATA(2,:);
    DATA(5,:) = DATA(1,:)-DATA(2,:);
    DATA(6,:) = DATA(3,:)-DATA(1,:);
    rpt_mtn.Mtn_median_fit.HEADER.Row = rpt_mtn.Mtn_primary_fit.HEADER';
    rpt_mtn.Mtn_median_fit.HEADER.Col = {'Estimate' 'CB lo' 'CB hi' 'CB width' 'EXC lo' 'EXC hi'};
    rpt_mtn.Mtn_median_fit.DATA = DATA';
end

rpt_mtn.Mtn_means.HEADER = {'Log10[Amount]' 'Log10[Price]' 'Probability' 'Zone' 'TA' 'CB lo' 'CB hi' 'CB w' 'EXC lo' 'EXC hi'};
uniqueX = unique(X,'rows');
m = nan(length(uniqueX),1);
cis = [m m];
for iX = 1 : length(uniqueX)
    idx = uniqueX(iX,1)==X(:,1)&uniqueX(iX,2)==X(:,2)&uniqueX(iX,3)==X(:,3)&uniqueX(iX,4)==X(:,4);
    choices = Y(idx);
    m(iX) = nanmean(choices);
    if length(choices)<2
        sdm = choices;
    else
        sdm = bootstrp(1000,@nanmean,choices);
    end
    cis(iX,1) = prctile(sdm,2.5);
    cis(iX,2) = prctile(sdm,97.5);
end
rpt_mtn.Mtn_means.DATA = [uniqueX m cis abs(diff(cis,1,2)) m-cis(:,1) cis(:,2)-m];
rpt_mtn.Rsq = Rsq;


function err = lsq_err(x,y,params)
yhat = ez_herrn_mtn_ta(x,params);
Dev = y(:)-yhat(:);
err = (Dev(:)')*(Dev(:));