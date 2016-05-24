function KKwikCondition(varargin)
% KKwik entire condition.

root = pwd;
FD = '\FD'; % Features directory, where KKwik puts *.clu.* files.
nTTs = 24;
TTprefix = 'TT';
process_varargin(varargin);
fcTT = cell(1,nTTs);
for iF=1:nTTs
    fcTT{iF} = sprintf('%s%d.ntt',TTprefix,iF); % Tetrodes to autocut.
end
process_varargin(varargin);
%%
ttToDo = false(length(fcTT),1);
fnToDo = cell(length(fcTT),1);
for iF=1:length(fcTT)
    fn = fcTT{iF};
    [~,fn] = fileparts(fn);
    idTT = max(regexpi(fn,TTprefix))+length(TTprefix);
    idDot = max(regexpi(fn,'\.'))-1;
    if isempty(idDot)
        idDot = length(fn);
    end
    ttNum = str2double(fn(idTT:idDot));
    ttToDo(ttNum) = true;
    fnToDo{ttNum} = fcTT{iF};
end
    
%%
pushdir(root);
disp(['Searching ' root ' for sessions to autocut.'])
%% Get the list of sessions to KKwik
disp('Getting list of sessions to KKwik.')
FD = regexprep(FD,'\\','\\\\'); % Find the backslashes, make them double backslashes.

ntt = FindFiles('*.ntt');
ntd = cell(length(ntt),1);
for iF=1:length(ntt); ntd{iF} = fileparts(ntt{iF}); end;
ntd = unique(ntd);
clu = FindFiles('*.clu.*');
cld = cell(length(clu),1);
for iF=1:length(clu); 
    fd = fileparts(clu{iF});
    delim = regexpi(fd,FD);
    cld{iF}=fd(1:max(delim)-1); 
end;
cld = unique(cld);

todo = cell(0,1);
for iD=1:length(cld)
    pushdir(cld{iD});
    fn1 = FindFiles('*.clu.*');
    fn2 = FindFiles('*.KKmat.*');
    fnExc = FindFiles('*temp*');
    fn = cat(1,fn1(:),fn2(:));
    fn = fn(~ismember(fn,fnExc));
    
    ttDone = false(nTTs,1);
    for iF=1:length(fn)
        fd = fn{iF};
        [~,fd] = fileparts(fd);
        idTT = max(regexpi(fd,TTprefix))+length(TTprefix);
        idDot = max(regexpi(fd,'\.'))-1;
        if isempty(idDot)
            idDot = length(fd);
        end
        ttNum = str2double(fd(idTT:idDot));
        ttDone(ttNum) = true;
    end
    if ~(all(ttDone(ttToDo)));
        % not all tetrodes on the to-do list are done.
        todo{end+1} = cld{iD};
    end
    
    popdir;
end
%todo = ntd(~ismember(ntd,cld));

disp([num2str(length(todo)) ' sessions to cut:'])
for iF=1:length(todo)
    fd = todo{iF};
    delimPC = regexpi(fd,'\\');
    delimUNIX = regexpi(fd,'/');
    delim = sort([delimPC(:)' delimUNIX(:)']);
    fd = fd(max(delim)+1:end);
    disp(fd);
end

%% Clean up as much as possible to liberate space.
disp('Cleaning up.')
ws = who;
ws = ws(~ismember(ws,{'todo' 'fcTT' 'ttToDo' 'fnToDo' 'nTTs' 'TTprefix'}));
for s=1:length(ws)
    eval(['clear ' ws{s}])
end
clear s ws

%% Run clust batch on the sucker.
for iD=1:length(todo)
    pushdir(todo{iD});
    disp(['AUTOCUTTING SESSION ' todo{iD}])
    fcDone1 = FindFiles('*.clu.*');
    fcDone2 = FindFiles('*.KKmat.*');
    fcDone = cat(1,fcDone1(:),fcDone2(:));
    fcExc = FindFiles('*temp*');
    fcDone = fcDone(~ismember(fcDone,fcExc));
    
    ttDone = false(nTTs,1);
    for iF=1:length(fcDone)
        [~,fn] = fileparts(fcDone{iF});
        idTT = max(regexpi(fn,TTprefix))+length(TTprefix);
        idDot = max(regexpi(fn,'\.'))-1;
        if isempty(idDot)
            idDot = length(fn);
        end
        ttNum = str2double(fn(idTT:idDot));
        ttDone(ttNum) = true;
    end
    idNotDone = (ttDone==0)&(ttToDo==1);
    RunClustBatch('fcTT',fnToDo(idNotDone));
    popdir;
    disp([num2str(length(todo)-iD) ' sessions remain to autocut.'])
end
%%
popdir;