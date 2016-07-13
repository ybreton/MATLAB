function RRPromote(varargin)
% Promotes restaurant row.
% 'InjSeq'      (default true)          injection sequence
% 'Manipulation'(default 'DREADD')      type of cross-session manipulation
% 'Virus'       (default 'pAAV8-CaMKII-h4MDi-mCitrine')           
% 'ViralTarget' (default ask)           target of viral transduction
% 'Aname'       (default 'A')           indicator of condition A
% 'Bname'       (default 'B')           indicator of condition B
% 'Acond'       (default ask)           un-blind-ed condition A
% 'Bcond'       (default ask)           un-blind-ed condition B
%
% 'Behavior'    (default 'RRow')        Behavioural task: RRow, RRow4x20, etc.
% 'Protocol'    (default 'Behavior')    Behavior or Hyperdrive
% 'Rename'      (default false)         rename CSC, NTT, NEV, etc.
% 'Upload'      (default false)         copy directory to InProcess
% 'fd'          (default all)           file directories to process
%
% 'CSCReference'    (default ask)       Reference of each tetrode
% 'Target1'         (default ask)       Structure target 1
% 'Target2'         (default ask)       Structure target 2
% 'Target3'         (default ask)       Structure target 3
% 'SubTarget1'      (default ask)       Structure subtarget 1
% 'SubTarget2'      (default ask)       Structure subtarget 2
% 'SubTarget3'      (default ask)       Structure subtarget 3
% 'TetrodeTargets'  (default ask)       Structure targets of tetrodes
% 'HasHCTheta'      (default false)     Include a CSC with hippocampal theta
% 'ThetaCSC'        (default ask)       CSC with hippocampal theta
% 
InjSeq = true;
Manipulation = 'DREADD';
Virus = 'pAAV8-CaMKIIa-h4MDi-mCitrine';
ViralTarget = {};
Aname = 'A';
Bname = 'B';
Acond = '';
Bcond = '';
Behavior = 'RRow';
Protocol = 'Behavior';
Upload = false;
Rename = false;


fn = FindFiles('RR-*.mat');
fd = cell(length(fn),1);
for f = 1 : length(fn)
    fd{f} = fileparts(fn{f});
end
fd = unique(fd);
Target1 = [];
Target2 = [];
Target3 = [];
SubTarget1 = [];
SubTarget2 = [];
SubTarget3 = [];
TetrodeTargets = [];
CSCReference = [];
HasHCTheta = false;
ThetaCSC = [];
process_varargin(varargin);

if isempty(Acond)
    Acond = input(['True condition marked blind as ' Aname ': '],'s');
end
if isempty(Bcond)
    Bcond = input(['True condition marked blind as ' Bname ': '],'s');
end
Names = {Aname; Bname};
Conds = {Acond; Bcond};
if strcmpi(Manipulation,'DREADD') && isempty(Virus)
    Virus = input('Transduced virus name (e.g., pAAV8-CaMKII-h4MDi-mCitrine): ','s');
end
if ~isempty(Virus) && isempty(ViralTarget)
    ViralTarget{1} = input('Target of viral transduction (e.g., OFC): ','s');
end

if strncmpi(Protocol,'Hyp',3)
    if isempty(Target1)
        Target1 = input('Target 1 structure: ','s');
        if isempty(Target1); Target1 = 'nan'; end
    end
    if isempty(Target2)
        Target2 = input('Target 2 structure: ','s');
        if isempty(Target2); Target2 = 'nan'; end
    end
    if isempty(Target3)
        Target3 = input('Target 3 structure: ','s');
        if isempty(Target3); Target3 = 'nan'; end
    end
    if isempty(SubTarget1)
        SubTarget1 = input('Subtarget 1 structure: ','s');
        if isempty(SubTarget1); SubTarget1 = 'nan'; end
    end
    if isempty(SubTarget2)
        SubTarget2 = input('Subtarget 2 structure: ','s');
        if isempty(SubTarget2); SubTarget2 = 'nan'; end
    end
    if isempty(SubTarget3)
        SubTarget3 = input('Subtarget 3 structure: ','s');
        if isempty(SubTarget3); SubTarget3 = 'nan'; end
    end
    if isempty(TetrodeTargets)
        TetrodeTargets = nan(1,28);
        for iTT=1:24
            str = input(['Target number for channel' num2str(iTT) ':']);
            if isempty(str);str=nan;end
            TetrodeTargets(iTT) = str;
        end
    end
    if isempty(CSCReference)
        CSCReference = nan(1,24);
        for iCSC = 1:24
            str = input(['Reference channel for CSC' num2str(iCSC) ':']);
            if isempty(str);str=nan;end
            CSCReference(iCSC) = str;
        end
    end
    if isempty(HasHCTheta)
        tf = nan;
        while tf~=0 && tf~=1
            tf = input('Has HC theta? ');
        end
        HasHCTheta = tf;
    end
    if isempty(ThetaCSC) && HasHCTheta==1
        ThetaCSC = input('CSC channel for HC Theta: ');
    end
end

disp('Processing sessions:')
for d = 1 : length(fd)
    pushdir(fd{d});
    folder = fd{d};
    delim = regexpi(folder,'\');
    SSN = folder(max(delim)+1:end);
    fprintf('\n')
    disp(SSN);
    
    % Look for the summary e-mail text file to automate the process.
    sumfn = FindFile('*-summary.txt');
    summaryTxt = process_summaryfile(sumfn);
    
    % if a field is empty, ask about it.
    if InjSeq
        while isempty(summaryTxt.Drug)
            summaryTxt.Drug = input([SSN ' Blinded drug: '],'s');
        end
        
        idCond = strcmpi(summaryTxt.Drug,Names);
        if any(idCond)
            SSNcond = Conds{idCond};
        else
            disp(['Session condition ' summaryTxt.Drug ' is neither ' Names{1} ' nor ' Names{2} '.'])
            disp(['Unblinded drug conditions are ' Conds{1} ' and ' Conds{2} '.'])
            str = '';
            while isempty(str)
                str = input(['Enter unblinded drug condition for ' SSN ': '],'s');
                idCond = strcmpi(str,Conds);
                if any(idCond)
                    SSNcond = str;
                else
                    str = '';
                end
            end
        end

        while ~isempty(summaryTxt.Drug) && isnan(summaryTxt.Dose)
            summaryTxt.Dose = input([SSN ' Dose: ']);
        end
        Behavior0 = [Behavior ' ' Manipulation ' Injection Sequence'];
    else
        SSNcond = '';
        summaryTxt.Dose = nan;
        Behavior0 = Behavior;
    end
    disp(Behavior0);
    
    while isempty(summaryTxt.Weight)
        summaryTxt.Weight = input([SSN ' Weight: ']);
    end
    if isempty(summaryTxt.Blocks)
        summaryTxt.Blocks = input([SSN ' Blocks [0]: ']);
        if isempty(summaryTxt.Blocks); summaryTxt.Blocks = 0; end
    end
    if isempty(summaryTxt.Nudges)
        summaryTxt.Nudges = input([SSN ' Nudges [0]: ']);
        if isempty(summaryTxt.Nudges); summaryTxt.Nudges = 0; end
    end
    if isempty(summaryTxt.PostFeed)
        summaryTxt.PostFeed = input([SSN ' Post-feed [0]: ']);
        if isempty(summaryTxt.PostFeed); summaryTxt.PostFeed = 0; end
    end
    
    % Is there a CSV of the tetrode depth?
    if strncmp('H',Protocol,1)
        TTdepth = FindFile('*-TTdepth.csv');
    else
        TTdepth = [];
    end
    
    RRfn = FindFiles('RR-*.mat','CheckSubdirs',0);
    for iF=1:length(RRfn)
        RR = load(RRfn{iF});
        if isfield(RR,'SessionStartTime')&&isfield(RR,'SessionEndTime')
            Ton(iF) = RR.SessionStartTime*1e-6;
            Toff(iF) = RR.SessionEndTime*1e-6;
        else
            Ton(iF) = -inf;
            Toff(iF) = inf;
        end
    end
    Ton = (Ton(1));
    Toff = (Toff(end));
    nvt = FindFiles('*VT1*.nvt','CheckSubdirs',false);
    if ~isempty(nvt)
        disp('Inferring session times...')
        [x,y]=LoadVT_lumrg(nvt{1});
        if isnan(Ton) | isempty(Ton)
            Ton = min(x.range);
        end
        if isnan(Toff) | isempty(Toff)
%             Toff = max(x.range);
            Toff = inf;
        end
        if isinf(Ton)|isinf(Toff)
            [Ton,Toff] = RRsessionTimes(nvt{1},'Ton',Ton,'Toff',Toff);
        end
        clf
        [x,y]=LoadVT_lumrg(nvt{1});
        plot(x.range-Ton,atan2(y.data-nanmean(y.data),x.data-nanmean(x.data)))
        hold on
        plot([0 0],[-pi pi],'g-','linewidth',2)
        plot([Toff-Ton Toff-Ton],[-pi pi],'r-','linewidth',2)
        xlim([min(x.range)-Ton,max(x.range)-Ton])
        title(sprintf('%.1f mins',(Toff-Ton)/60));
        hold off
    else
        zipfn = FindFiles('*VT1*.zip','CheckSubdirs',false);
        if ~isempty(zipfn)
            filesPre = FindFiles('*.*','CheckSubdirs',false);
            disp(['Unzipping ' zipfn{1}])
            unzip(zipfn{1})
            filesPost = FindFiles('*.*','CheckSubdirs',false);
            toDelete = filesPost(~ismember(filesPost,filesPre));
            nvt = FindFiles('*VT1*.nvt','CheckSubdirs',false);
            disp('Inferring session times...')
            [x,y]=LoadVT_lumrg(nvt{1});
            if isnan(Ton) | isempty(Ton)
                Ton = min(x.range);
            end
            if isnan(Toff) | isempty(Toff)
%                 Toff = max(x.range);
                Toff = inf;
            end
            if isinf(Ton)||isinf(Toff)
                [Ton,Toff] = RRsessionTimes(nvt{1},'Ton',Ton,'Toff',Toff);
                
            end
            clf
            [x,y]=LoadVT_lumrg(nvt{1});
            plot(x.range-Ton,atan2(y.data-nanmean(y.data),x.data-nanmean(x.data)))
            hold on
            plot([0 0],[-pi pi],'g-','linewidth',2)
            plot([Toff-Ton Toff-Ton],[-pi pi],'r-','linewidth',2)
            title(sprintf('Angle\n(%.1f mins)',(Toff-Ton)/60));
            xlim([min(x.range)-Ton,max(x.range)-Ton])
            hold off
            disp(['Cleaning up files from ' zipfn{1}])
            for iD=1:length(toDelete)
                disp(['Removing ' toDelete{iD}])
                delete(toDelete{iD});
            end
        end
    end
    
    
    RR_CreateKeys('Behavior',Behavior,'Protocol',Protocol,'TimeOnTrack',Ton,'TimeOffTrack',Toff,...
        'Manipulation',Manipulation,'Condition',SSNcond,'Dose',summaryTxt.Dose,'Virus',Virus,'ViralTarget',ViralTarget,...
        'Weight',summaryTxt.Weight,'Blocks',summaryTxt.Blocks,'Nudges',summaryTxt.Nudges,'PostFeed',summaryTxt.PostFeed,...
        'UseDepthCSV',TTdepth,'Target',{Target1,Target2,Target3},'Target2',{SubTarget1,SubTarget2,SubTarget3},...
        'TetrodeTargets',TetrodeTargets,'CSCReference',CSCReference,...
        'HasHCTheta',HasHCTheta,'ThetaCSC',ThetaCSC);
        
    sd=RRInit;
        
    save([SSN '-sd.mat'],'sd')
    
    if Rename
        disp('Renaming files...')
        RRRenameFiles(SSN,'CSCReference',CSCReference);
    end
    
    if Upload
        idRAT = regexpi(SSN,'R[0-9][0-9][0-9]');
        RAT = SSN(idRAT:idRAT+3);
        disp(['Uploading files to inProcess for rat ' RAT ', session ' SSN '...'])
        sourceSD = FindFiles('R*-sd.mat','CheckSubdirs',0);
        sourceKEYS = FindFiles('R*_keys.m','CheckSubdirs',0);
        sourceNCS = FindFiles('R*.ncs','CheckSubdirs',0);
        sourceNEV = FindFiles('R*.nev','CheckSubdirs',0);
        sourceT = FindFiles('R*.t','CheckSubdirs',0);
        sourceT64 = FindFiles('R*.t64','CheckSubdirs',0);
        sourceUST = FindFiles('R*._t','CheckSubdirs',0);
        sourceUST64 = FindFiles('R*._t64','CheckSubdirs',0);
        sourceCQ = FindFiles('R*-CluQual.mat','CheckSubdirs',0);
        sourceWV = FindFiles('R*-wv.mat','CheckSubdirs',0);
        sourceZIP = FindFiles('R*-VT*.zip','CheckSubdirs',0);
        sourceVT = FindFiles('R*-VT.mat','CheckSubdirs',0);
        sourceTXT = FindFiles('RR-*.txt','CheckSubdirs',0);
        
        sources = cat(1,sourceSD,sourceKEYS,sourceNCS,sourceNEV,sourceT,sourceT64,sourceUST,sourceUST64,sourceCQ,sourceWV,sourceZIP,sourceVT,sourceTXT);
        
        for iFile = 1 : length(sources)
            fromFile = sources{iFile};
            [fd,fn,ext] = fileparts(fromFile);
            toFile = ['\\adrlab15\db\DataInProcess\' RAT '\' SSN '\' fn ext];
            if ~isdir(['\\adrlab15\db\DataInProcess\' RAT])
                disp(['Creating directory ' RAT ' on adrlab15\db\DataInProcess'])
                mkdir('\\adrlab15\db\DataInProcess\',RAT)
            end
            if ~isdir(['\\adrlab15\db\DataInProcess\' RAT '\' SSN])
                disp(['Creating directory ' SSN ' on adrlab15\db\DataInProcess\' RAT])
                mkdir(['\\adrlab15\db\DataInProcess\' RAT],SSN)
            end
            
            fprintf('\n');
            try
                fprintf('%s... ',[fn ext]);
                copyfile(fromFile,toFile)
                fprintf('done');
            catch exception
                fprintf('\n');
                disp(['Could not copy from ' fromFile ' to ' toFile])
                disp(exception.message)
            end
        end
    end
    fprintf('\n****************************\n')
    popdir;
end