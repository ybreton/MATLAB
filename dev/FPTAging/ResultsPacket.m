%% ResultsPacket.m
% Builds a results packet of the FPT/Aging data.

%% DEF Age groups
RatGroups = {'5 months' '9 months' '>27 months'};
RatAgeList = {'R248' 1
    'R249' 2
    'R250' 2
    'R251' 2
    'R256' 3
    'R257' 3
    'R258' 1
    'R259' 2
    'R260' 3
    'R261' 3
    'R262' 1
    'R263' 3
    'R264' 2
    'R265' 3
    'R272' 2
    'R273' 2
    'R274' 3
    'R275' 3
    'R282' 1
    'R283' 1
    'R284' 1
    'R285' 2
    'R286' 3
    'R287' 3};

%% DEF session list with Rat, AGE, PR, SSN, Directory.
RAT = [];
AGE = [];
PR = [];
SSN = cell(0,1);
FD = cell(0,1);
for r = 1 : size(RatAgeList)
    rat = RatAgeList{r,1};
    pushdir(rat);
    
    rat = str2double(rat(2:end));
    fn = FindFiles('R*-DD.mat');
    fd = cell(length(fn),1);
    pr = nan(length(fn),1);
    ssn = cell(length(fn),1);
    for f = 1 : length(fn)
        pn = fileparts(fn{f});
        fd{f} = pn;
        id = regexpi(pn,'\');
        ssn{f} = pn(max(id)+1:end);
        
        sd = load(fn{f});
        pr(f) = round(10.^(abs(log10(sd.World.nPleft/sd.World.nPright))));
    end
    age = repmat(RatAgeList{r,2},length(fn),1);
    rat = repmat(rat,length(fn),1);
    RAT = cat(1,RAT,rat);
    AGE = cat(1,AGE,age);
    PR = cat(1,PR,pr);
    SSN = cat(1,SSN,ssn);
    FD = cat(1,FD,fd);
    popdir;
end
MasterSSNTable.HEADER = {'RatNumber' 'AgeGroup' 'PelletRatio' 'SSN' 'DIRECTORY'};
MasterSSNTable.DATA = cell(length(RAT),4);
MasterSSNTable.DATA(:,1) = mat2can(RAT);
MasterSSNTable.DATA(:,2) = mat2can(AGE);
MasterSSNTable.DATA(:,3) = mat2can(PR);
MasterSSNTable.DATA(:,4) = SSN;
MasterSSNTable.DATA(:,5) = FD;
save('MasterSSNList.mat','MasterSSNTable')

%% Get ADs.

AD = getAD_FPTAging(MasterSSNTable.DATA);
MasterSSNTable.HEADER{6} = 'FINAL DELAY';
MasterSSNTable.DATA(:,6) = mat2can(AD);

%% Prepare matrix of conditions for ANOVA.

Xfull = unique(can2mat(MasterSSNTable.DATA(:,[1 2 3])),'rows');
Yfull = nan(size(Xfull,1),1);
for iX = 1 : size(Xfull,1)
    id = can2mat(MasterSSNTable.DATA(:,1))==Xfull(iX,1)&can2mat(MasterSSNTable.DATA(:,2))==Xfull(iX,2)&can2mat(MasterSSNTable.DATA(:,3))==Xfull(iX,3);
    
    Yfull(iX) = nanmean(AD(id));
end
S = Xfull(:,1);
Xfull = Xfull(:,2:end);
% S is the list of subjects,
% X is the list of predictors,
% Y is the outcome variable.

% N is 3 x 3 nesting matrix, with
% N(1,2)=1 subjects nested in age group
N = zeros(3);
N(1,2) = 1;

[p,table,stats,terms] = anovan(Yfull,[S Xfull],'random',1,'nested',N,'model','interaction','varnames',{'Subjects' 'Age' 'PR'});
ADyAGExPR.p = p;
ADyAGExPR.table = table;
ADyAGExPR.stats = stats;
ADyAGExPR.terms = terms;

%% AD , Age

Xage = unique(can2mat(MasterSSNTable.DATA(:,[1 2])),'rows');
Yage = nan(size(Xage,1),1);
for iX = 1 : size(Xage,1)
    id = can2mat(MasterSSNTable.DATA(:,1))==Xage(iX,1)&can2mat(MasterSSNTable.DATA(:,2))==Xage(iX,2);
    
    Yage(iX) = nanmean(AD(id));
end
S = Xage(:,1);
Xage = Xage(:,2:end);

[p,table,stats] = anova1(Yage,Xage);


ADyAGE.p = p;
ADyAGE.table = table;
ADyAGE.stats = stats;
ADyAGE.postHoc = d;
ADyAGE.postHoc

%% AD , PR


%% AD , Age x PR

%% VTE , Age



%% VTE , PR

%% VTE, Age x PR

%% VTE , (D-AD)

%% MAD , Age

%% MAD , PR

%% MAD , Age x PR

%% P1s , Age

%% P1s , PR

%% P1s , Age x PR