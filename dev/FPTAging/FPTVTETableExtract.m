function [ExtractedVar]=FPTVTETableExtract(VTETable,SubjCol,SessCol,LapCol,ExtractCol,varargin)
%
%
%
%

numeric= [true false true true];
process_varargin(varargin);

DATA = VTETable.DATA;
if all(numeric) & iscell(DATA);
    DATA = can2mat(DATA);
end

if ischar(SubjCol)
    SubjCol = find(strcmp(SubjCol,VTETable.HEADER));
end
if ischar(SessCol)
    SessCol = find(strcmp(SessCol,VTETable.HEADER));
end
if ischar(LapCol)
    LapCol = find(strcmp(LapCol,VTETable.HEADER));
end
if ischar(ExtractCol)
    ExtractCol = find(strcmp(ExtractCol,VTETable.HEADER));
end

if numeric(1) & iscell(DATA)
    Ss = can2mat(DATA(:,SubjCol));
else
    Ss = (DATA(:,SubjCol));
end
if numeric(2) & iscell(DATA)
    SSNs = can2mat(DATA(:,SessCol));
else
    SSNs = (DATA(:,SessCol));
end
if numeric(3) & iscell(DATA)
    Laps = can2mat(DATA(:,LapCol));
else
    Laps = (DATA(:,LapCol));
end
if numeric(4) & iscell(DATA)
    X = can2mat(DATA(:,ExtractCol));
else
    X = (DATA(:,ExtractCol));
end
uniqueS = unique(Ss);
uniqueSSN = unique(SSNs);
uniqueLap = unique(Laps);

if numeric(4)
    ExtractedVar = nan(length(uniqueS),ceil(length(uniqueSSN)/length(uniqueS))+2,length(uniqueLap));
else
    ExtractedVar = cell(length(uniqueS),ceil(length(uniqueSSN)/length(uniqueS))+2,length(uniqueLap));
end
for iS = 1 : length(uniqueS)
    if numeric(1)
        idS = Ss==uniqueS(iS);
    else
        idS = strcmp(uniqueS(iS),Ss);
    end
    
    idS3d = false(size(ExtractedVar));
    idS3d(iS,:,:) = true;
    ratSSNs = SSNs(idS);
    uniqueratSSNs = unique(SSNs(idS));
    ratX = X(idS);
    for iSSN = 1 : length(uniqueratSSNs)
        if numeric(2)
            idSSN = ratSSNs==uniqueratSSNs(iSSN);
        else
            idSSN = strcmp(uniqueratSSNs(iSSN),ratSSNs);
        end
        idSSN3d = false(size(ExtractedVar));
        idSSN3d(iS,iSSN,:) = true;
        
        contents = ratX(idSSN);
        
        idLap3d = false(size(ExtractedVar));
        idLap3d(:,:,1:numel(contents)) = true;
        
        ExtractedVar(idS3d&idSSN3d&idLap3d) = reshape(contents,[1,1,numel(contents)]);
    end
end