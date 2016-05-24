function SD = HWMinit(fd)

% SD = HWMinit(fd)
%
% This function extracts relevant objects and structures from the file
% directory and puts them into sd. It also sorts timestamps by x and y
% coordinates and re-timestamps them.
%
% returned sd contains x and y tds, ExpKeys, Fcl, Fl, Fcr, Fr data


if nargin == 0
    fd = pwd;
end

pushdir(fd);

% keys
fnkeys = FindFile('*keys.m');
[~,fn,~] = fileparts(fnkeys);
eval(fn);
SD.ExpKeys = ExpKeys;

% position
fn = FindFile('*-vt.mat');
load(fn);

warning('SORTING TIMESTAMPS - IS THIS OK?  WE''RE NOT SURE!');
x.t = sort(x.t); y.t = sort(y.t);

x = tsd(x); y = tsd(y);
x = x.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
y = y.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
SD.x = x;
SD.y = y;

% Events
fn = FindFile('*-Events.Nev');
[~, EVS] = LoadEP(fn);
EVSt = range(EVS);
SD.Fcl = EVSt(strmatch('Feeder Center (L) fire 2 pellets',data(EVS)));
SD.Fl = EVSt(strmatch('Feeder Left fire 2 pellets',data(EVS)));
SD.Fr = EVSt(strmatch('Feeder Right fire 2 pellets',data(EVS)));
SD.Fcr = EVSt(strmatch('Feeder Center (R) fire 2 pellets',data(EVS)));

popdir;