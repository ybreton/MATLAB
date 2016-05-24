function getCheetahMP4(varargin)

fn = FindFile('*-DD.mat');
SOURCE = ['\\adrlab-tempest\CheetahShare\Aging rats'];
SOURCE_EXT = '*.mp4';
process_varargin(varargin);

pn = fileparts(fn);
pushdir(pn);

idRat = regexp(pn,'\R[0-9][0-9][0-9]\');
idSSN = regexp(pn,'\R*-*-*-*\');
idPth = unique([regexp(pn,'\') length(pn)+1]);
idRat = max(idRat);
idSSN = max(idSSN);
Rat = pn(idRat:min(idPth(idPth>idRat))-1);
SSN = pn(idSSN+1:min(idPth(idPth>idSSN))-1);

SrcPath = [SOURCE '\' Rat '\' SSN];
pushdir(SrcPath);

mp4 = FindFiles(SOURCE_EXT);
if ~isempty(mp4)
    mp4 = mp4{1};
end
smi = FindFiles('*.smi');
if ~isempty(smi)
    smi = smi{1};
end
nvt = FindFiles('*.nvt');
if ~isempty(nvt)
    nvt = nvt{1};
end
txt = FindFiles('FPT-tracking-*.txt');
if ~isempty(txt)
    txt = txt{1};
end

zipfile = FindFile('*.zip');
fileList{1} = mp4;
fileList{2} = smi;
fileList{3} = nvt;
fileList{4} = txt;
fileList{5} = zipfile;

popdir;
for f = 1 : length(fileList)
    if ~isempty(fileList{f})
        from = fileList{f};
        [SrcPath,SrcFile,SrcExt]=fileparts(from);
        
        to = [pn '\' SrcFile SrcExt];
        if ~(exist(to,'file')==2)
            disp(['Downloading ' SrcFile '...'])
            copyfile(from,to);
        else
            disp(['Directory already contains ' SrcFile '.'])
        end
        if ~isempty(regexpi(SrcExt,'zip'))
            disp(['Unzipping ' SrcFile ' ...'])
            unzip(to);
        end
    end
end

popdir;