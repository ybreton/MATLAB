function PromoteRRowTraining(varargin)
% Readies all subdirectories for promotion as training-phase behavioral data
%
% InjSeq = false;                   Not part of the injection sequence
% Manipulation = 'None';            No across-session manipulation
% Virus = '';                       Virus used:
%                                   pAAV8-CaMKIIa-h4MDi-mCitrine
%                                   pAAV8-CaMKIIa-h4MDi-mCherry
% ViralTarget = '';                 Structure targeted by virus
% Aname = '';                       No A/B designations
% Bname = '';
% Acond = '';                       No experimental conditions coded as A/B
% Bcond = '';
% Behavior = 'Training RRow';       Behavior promoted: Training RRow
% Protocol = 'Behavior';            Protocol used: Behavior-only
% Rename = true;                    Rename files to SSN

InjSeq = false;
Manipulation = 'None';
Virus = '';
ViralTarget = '';
Aname = ' ';
Bname = ' ';
Acond = ' ';
Bcond = ' ';
Behavior = 'Training RRow';
Protocol = 'Behavior';
Rename = true;
process_varargin(varargin);

fn = FindFiles('*.mat');
fd = cell(length(fn),1);
for iF=1:length(fn); fd{iF} = fileparts(fn{iF}); end
fd = unique(fd);

for id=1:length(fd)
    pushdir(fd{id});
    disp(fd{id});
    RRPromote('InjSeq',InjSeq,'Manipulation',Manipulation,'Virus',Virus,'ViralTarget',ViralTarget,'Aname',Aname,'Bname',Bname,'Acond',Acond,'Bcond',Bcond,'Behavior',Behavior,'Protocol',Protocol,'Rename',Rename)
    popdir;
end