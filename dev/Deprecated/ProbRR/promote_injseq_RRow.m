function promote_injseq_RRow(dname,cname,cdose,varargin)
%
%
%
%

base = 'injectionsequence';
Protocol = 'Behavior';
process_varargin(varargin);

fn = FindFiles('RR-*.mat');
fd = cell(length(fn),1);
for f = 1 : length(fn)
    fd{f} = fileparts(fn{f});
end
fd = unique(fd);

fprintf('\n');
for f = 1 : length(fd)
    fd0 = fd{f};
    pushdir(fd0);
    
    id1 = regexpi(fd0,base);
    id2 = regexpi(fd0,'\');
    d = fd0(id1+length(base)+1:max(id2)-1);
    
    id = strcmpi(d,dname);
    condition = cname(id);
    fprintf('Processing %s, %s condition, %.2f mg/kg.\n',fd,condition{1}, cdose(id));
    
    RRowPromote('Condition',condition{1},'Dose',cdose(id),'Protocol',Protocol);
    
    popdir;
end