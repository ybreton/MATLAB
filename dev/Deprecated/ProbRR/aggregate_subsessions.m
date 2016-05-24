function entire_session = aggregate_subsessions(prefix,varargin)
%
%
%
%

process_varargin(varargin);

fn = FindFiles([prefix '-*.mat']);

for f = 1 : length(fn)
    fd{f} = fileparts(fn{f});
end
ds = unique(fd);

for d = 1 : length(ds)
    pushdir(ds{d});
    entire_session(d).SSN = ds{d};
    
    fn = FindFiles([prefix '-*.mat']);
    % fn should now contain subsession files.
    sess_dat = load(fn{1});
    try
        sess_dat = fix_pellets(sess_dat);
    end
    for f = 2 : length(fn)
        subsess = fn{f};
        subdat = load(subsess);
        % Add a record of the number of food pellets obtained at each zone
        % in.
        try
            subdat = fix_pellets(subdat);
        end
        vars = fieldnames(subdat);
        for v = 1 : length(vars)
            cur_var = getfield(subdat,vars{v});
            try
                aggreg_var = getfield(sess_dat,vars{v});
                not_in = false;
            catch exception
                not_in = true;
            end
            
            if not_in
                sess_dat = setfield(sess_dat,vars{v},cur_var);
            else
                sess_dat = setfield(sess_dat,vars{v},[aggreg_var cur_var]);
            end
            
        end
    end
    entire_session(d).data = sess_dat;
    popdir;
end


    
function subdat = fix_pellets(subdat)

if numel(subdat.nPelletsPerDrop)==1
    subdat.nPelletsPerDrop = repmat(subdat.nPelletsPerDrop,1,4);
end
for lap = 1 : length(subdat.ZoneIn)
    id = mod(subdat.ZoneIn,10);
    subdat.ZonePellets = subdat.nPelletsPerDrop(id);
end