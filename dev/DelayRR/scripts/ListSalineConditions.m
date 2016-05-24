fn = FindFiles('*-Behav.csv');
fd = cell(size(fn));
for iF=1:length(fn); fd{iF} = fileparts(fn{iF}); end;
list = cell(0,1);
idInc = false(length(fn));
for iD=1:length(fd);
    pushdir(fd{iD});
    sd = RRInit;
    if strcmpi('Vehicle',sd(1).ExpKeys.Condition)||strcmpi('Saline',sd(1).ExpKeys.Condition)
        list{end+1,1} = sd(1).ExpKeys.SSN;
        idInc(iD) = true;
    end
    popdir;
end