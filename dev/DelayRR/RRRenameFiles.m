function RRRenameFiles(SSN,varargin)
% Renames restaurant row files for promotion to database.
%
%
%

CSCReference = [];
nCSCs = 24;
process_varargin(varargin);

if nargin<1
    SSN = '';
end

if isempty(SSN)
    fd = pwd;
    delim = regexpi(fd,'\');
    SSN = fd(max(delim)+1:end);
    Rat = regexpi(SSN,'R[0-9][0-9][0-9]-');
    while isempty(Rat)
        SSN = input('Session number [Rrat-YYYY-MM-DD]: ','s');
        Rat = regexpi(SSN,'R[0-9][0-9][0-9]-');
    end
end

%% Rename CSCs
%  FROM: CSCx.ncs
%    TO: SSN-CSCxxa.ncs
disp('Renaming CSCs...')
cscfn0 = FindFiles('*.ncs','CheckSubdirs',0);
cscfn = FindFiles('R*-CSC*.ncs','CheckSubdirs',0);
% fromRename = cscfn0(~ismember(cscfn0,cscfn));
fromRename = cscfn0;
for iRen = 1 : length(fromRename)
    [~,fnFrom,extFrom] = fileparts(fromRename{iRen});
    idStart  = regexpi(fnFrom,'CSC')+3;
    letters = regexp(fnFrom,'[A-Za-z]');
    idFinish = nanmin(letters(letters>idStart)-1);
    if isempty(idFinish)
        idFinish = length(fnFrom);
    end
%     idNum = regexp(fnFrom,'[0-9]');
%     number = str2double(fnFrom(idNum));
    number = str2double(fnFrom(idStart:idFinish));
    cscnum = sprintf('%02d',number);
    
    if ~isempty(CSCReference) & number<=length(CSCReference);
        ref = ['r' num2str(CSCReference(number))];
    else
        ref = '';
    end
    while isempty(ref)
        ref = input(['Reference for ' fromRename{iRen} ' '],'s');
    end

    toRename = [SSN '-CSC' cscnum ref extFrom];
    [~,from,ext] = fileparts(fromRename{iRen});
    [~,to,ext] = fileparts(toRename);
    if ~strcmpi(from,to)
        disp([from '->' to])
        movefile(fromRename{iRen},toRename);
    else
        disp([toRename ' already exists.'])
    end
end

%% Rename NTTs
%  FROM: TTx.ntt
%    TO: SSN-TTxx.ntt
disp('Renaming NTTs...')
nttfn0 = FindFiles('*.ntt','CheckSubdirs',0);
nttfn = FindFiles('R*-TT*.ntt','CheckSubdirs',0);
fromRename = nttfn0(~ismember(nttfn0,nttfn));
for iRen = 1 : length(fromRename)
    [~,fnFrom,extFrom] = fileparts(fromRename{iRen});
    idNum = regexp(fnFrom,'[0-9]');
    number = str2double(fnFrom(idNum));
    nttnum = sprintf('%02d',number);
    
    toRename = [SSN '-TT' nttnum extFrom];
    movefile(fromRename{iRen},toRename);
end

%% Rename NEVs
%  FROM: Events.nev
%    TO: SSN-Events.nev
disp('Renaming NEVs...')
nevfn0 = FindFiles('*.nev','CheckSubdirs',0);
nevfn = FindFiles('R*-Events.nev','CheckSubdirs',0);
fromRename = nevfn0(~ismember(nevfn0,nevfn));
for iRen = 1 : length(fromRename)
    [~,fnFrom,extFrom] = fileparts(fromRename{iRen});
        
    toRename = [SSN '-' fnFrom extFrom];
    movefile(fromRename{iRen},toRename);
end

%% Rename Ts
%  FROM: TTx_yy.t
%    TO: SSN-TTxx_yy.t
disp('Renaming .Ts...')
tfn0 = FindFiles('*.t','CheckSubdirs',0);
tfn = FindFiles('R*-TT*_*.t','CheckSubdirs',0);
fromRename = tfn0(~ismember(tfn0,tfn));
for iRen = 1 : length(fromRename)
    [~,fnFrom,extFrom] = fileparts(fromRename{iRen});
    clu = regexpi(fnFrom,'_');
    tet = regexpi(fnFrom,'TT');
    cluNum = str2double(fnFrom(clu+1:end));
    tetNum = str2double(fnFrom(tet+2:clu-1));
    
    tetStr = sprintf('%02d',tetNum);
    cluStr = sprintf('%02d',cluNum);
    
    toRename = [SSN '-TT' tetStr '_' cluStr extFrom];
    movefile(fromRename{iRen},toRename);
end
%% Rename _Ts
%  FROM: TTx_yy._t
%    TO: SSN-TTxx_yy._t
disp('Renaming ._Ts...')
ustfn0 = FindFiles('*._t','CheckSubdirs',0);
ustfn = FindFiles('R*-TT*_*._t','CheckSubdirs',0);
fromRename = ustfn0(~ismember(ustfn0,ustfn));
for iRen = 1 : length(fromRename)
    [~,fnFrom,extFrom] = fileparts(fromRename{iRen});
    clu = regexpi(fnFrom,'_');
    tet = regexpi(fnFrom,'TT');
    cluNum = str2double(fnFrom(clu+1:end));
    tetNum = str2double(fnFrom(tet+2:clu-1));
    
    tetStr = sprintf('%02d',tetNum);
    cluStr = sprintf('%02d',cluNum);
    
    toRename = [SSN '-TT' tetStr '_' cluStr extFrom];
    movefile(fromRename{iRen},toRename);
end

%% Rename CluQuals
%  FROM: TTx_yy-CluQual.nev
%    TO: SSN-TTxx_yy-CluQual.nev
disp('Renaming CluQuals...')
cqfn0 = FindFiles('*-CluQual.mat','CheckSubdirs',0);
cqfn = FindFiles('R*-CluQual.mat','CheckSubdirs',0);
fromRename = cqfn0(~ismember(cqfn0,cqfn));
for iRen = 1 : length(fromRename)
    [~,fnFrom,extFrom] = fileparts(fromRename{iRen});
    clu = regexpi(fnFrom,'_');
    tet = regexpi(fnFrom,'TT');
    delim = regexpi(fnFrom,'-CluQual');
    cluNum = str2double(fnFrom(clu+1:delim-1));
    tetNum = str2double(fnFrom(tet+2:clu-1));
    
    tetStr = sprintf('%02d',tetNum);
    cluStr = sprintf('%02d',cluNum);
    
    toRename = [SSN '-TT' tetStr '-' cluStr '-CluQual' extFrom];
    movefile(fromRename{iRen},toRename);
end

%% Rename WVs
%  FROM: TTx_yy-wv.mat
%    TO: SSN-TTxx_yy-wv.mat
disp('Renaming WVs...')
wvfn0 = FindFiles('*-wv.mat','CheckSubdirs',0);
wvfn = FindFiles('R*-wv.mat','CheckSubdirs',0);
fromRename = wvfn0(~ismember(wvfn0,wvfn));
for iRen = 1 : length(fromRename)
    [~,fnFrom,extFrom] = fileparts(fromRename{iRen});
    clu = regexpi(fnFrom,'_');
    tet = regexpi(fnFrom,'TT');
    delim = regexpi(fnFrom,'-wv');
    cluNum = str2double(fnFrom(clu+1:delim-1));
    tetNum = str2double(fnFrom(tet+2:clu-1));
    
    tetStr = sprintf('%02d',tetNum);
    cluStr = sprintf('%02d',cluNum);
    
    toRename = [SSN '-TT' tetStr '-' cluStr '-wv' extFrom];
    movefile(fromRename{iRen},toRename);
end
%%
%% Rename clusters
%  FROM: TTx.clusters
%    TO: SSN-TTxx.clusters
disp('Renaming clusters...')
clufn0 = FindFiles('TT*.clusters','CheckSubdirs',0);
clufn = FindFiles('R*.clusters','CheckSubdirs',0);
fromRename = clufn0(~ismember(clufn0,clufn));
for iRen = 1 : length(fromRename)
    [~,fnFrom,extFrom] = fileparts(fromRename{iRen});
    tet = regexpi(fnFrom,'TT');
    
    tetNum = str2double(fnFrom(tet+2:end));
    
    tetStr = sprintf('%02d',tetNum);
    
    toRename = [SSN '-TT' tetStr extFrom];
    movefile(fromRename{iRen},toRename);
end
%% Rename NVTs
%  FROM: VTx.nvt
%    TO: SSN-VTx.nvt
disp('Renaming NVTs')
vtfn0 = FindFiles('*VT*.nvt','CheckSubdirs',0);
vtfn = FindFiles('R*-VT*.nvt','CheckSubdirs',0);
fromRename = vtfn0(~ismember(vtfn0,vtfn));
for iRen = 1 : length(fromRename)
    [~,fnFrom,extFrom] = fileparts(fromRename{iRen});
    
    toRename = [SSN '-' fnFrom extFrom];
    movefile(fromRename{iRen},toRename);
end
%% Rename ZIPs
%  FROM: VT*.zip
%    TO: SSN-VT*.zip
zfn0 = FindFiles('*VT*.zip','CheckSubdirs',0);
zfn = FindFiles('R*-VT*.zip','CheckSubdirs',0);
fromRename = zfn0(~ismember(zfn0,zfn));
for iRen = 1 : length(fromRename)
    [~,fnFrom,extFrom] = fileparts(fromRename{iRen});
    
    toRename = [SSN '-' fnFrom extFrom];
    movefile(fromRename{iRen},toRename);
end

%% Rename VTs
%  FROM: VT*.mat
%    TO: SSN-VT*.mat
vtmat0 = FindFiles('*VT*.mat','CheckSubdirs',0);
vtmat = FindFiles('R*-VT*.mat','CheckSubdirs',0);
fromRename = vtmat0(~ismember(vtmat0,vtmat));
for iRen = 1 : length(fromRename)
    [~,fnFrom,extFrom] = fileparts(fromRename{iRen});
    
    toRename = [SSN '-' fnFrom extFrom];
    movefile(fromRename{iRen},toRename);
end
