fn0 = FindFiles('DD-*.mat');
fn1 = FindFiles('*-DD.mat');
fn = horzcat(fn0,fn1);

HEADER = {'PR' 'Side' 'nPleft' 'nPright' 'Starting Delay'};
DATA = cell(0,5);
for f = 1 : length(fn)
    filename = fn{f};
    [pathname,filename,ext] = fileparts(filename);
    filename = [filename ext];
    
    pushdir(pathname);
    
    Experiment = load(filename);
    World = Experiment.World;
    nPright = World.nPright;
    nPleft = World.nPleft;
    nP = [nPleft nPright];
    sides = {'left' 'right'};
    z = [3 4];
    [PR,id] = max(nP);
    PR = max(nP)/min(nP);
    DZone = z(id);
    Side = sides(id);
    if nPleft==nPright && nPleft==2
        Side = 'Train';
    end
    delay = Experiment.ZoneDelay;

    choseDelay = false;
    trial = 0;
    StartingDelay = nan;
    while ~choseDelay & trial < length(Experiment.ZoneIn)
        trial = trial+1;
        if Experiment.ZoneIn(trial)==DZone
            StartingDelay = Experiment.ZoneDelay(trial);
            choseDelay = true;
        end
    end
    
    DATA(f,:) = {PR Side nPleft nPright StartingDelay};
    
    popdir;
end

SSNParams.HEADER = HEADER;
SSNParams.DATA = DATA;