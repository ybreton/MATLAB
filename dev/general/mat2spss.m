function tab = mat2spss(mat,repDim,btwDim,wthDim,varargin)
% Converts a matrix to SPSS format, where each row is a case, each column a
% variable.
% tab = mat2spss(mat,repDim,btwDim,wthDim)
% where     tab         is a table structure array with fields
%              .DATA    with the data in SPSS columnwise wide format, and
%              .HEADER  with column headings
%
%           mat         is a A x B x ... x nRep x mBtw x ... x pWth matrix
%                           of outcomes
%           repDim      is a vector of dimensions with case/subject numbers
%                           (dimension n in the example here)
%           btwDim      is a vector of dimensions with between-subject
%                           assignments (dimension m in the example here)
%           wthDim      is a vector of dimensions containing within-subject
%                           variables (dimension p in the example here)

dimnames = cell(1,length(size(mat)));
for iDim=1:length(dimnames)
    dimnames{iDim} = sprintf('Dim%d',iDim);
end
process_varargin(varargin);

% get the size of the input.
sz = size(mat);

rs = ones(1,length(sz));
rs(repDim) = sz(repDim);
rp = sz;
rp(repDim) = 1;
repGrid=repmat(reshape(1:sz(repDim),rs),rp);

REP = (1:sz(repDim))';
BTW = nan(length(REP),length(btwDim));
WTH = nan(length(REP),prod(sz(wthDim)));
labelsW = cell(1,prod(sz(wthDim)));
for iRep=1:length(REP)
    idx = repGrid == REP(iRep);
    idSub = nan(1,length(sz));
    idSub(repDim) = iRep;
    for iIV=1:length(btwDim)
        rs = ones(1,length(sz));
        rs(btwDim(iIV)) = sz(btwDim(iIV));
        rp = sz;
        rp(btwDim(iIV)) = 1;
        btwGrid=repmat(reshape(1:sz(btwDim(iIV)),rs),rp);
        grid0 = btwGrid(idx& ~isnan(mat));
        
        BTW(iRep,iIV) = unique(grid0(:));
        idSub(btwDim(iIV)) = unique(grid0(:));
    end
    ca = cell(1,length(sz));
    for iDim=1:length(idSub)
        if ~isnan(idSub(iDim))
            ca{iDim} = num2str(idSub(iDim));
        else
            ca{iDim} = ':';
        end
    end
    str = '(';
    for iStr = 1:length(ca)
        str = [str ca{iStr} ','];
    end
    str(end) = ')';
    
    DVs = squeeze(eval(['mat' str]));
    
    WTH(iRep,:) = DVs(:);
end
replabel = {sprintf('%s:Case#',dimnames{repDim})};
btwlabel = cell(1,length(btwDim));
for iBtw=1:length(btwDim)
    btwlabel{iBtw} = dimnames{btwDim(iBtw)};
end
wthlabel0 = cell(length(wthDim),prod(sz(wthDim)));
for iWth=1:length(wthDim)
    ca = cell(1,length(sz));
    for iDim=1:length(sz)
        ca{iDim} = '1';
    end
    for iDim=1:length(wthDim)
        ca{wthDim(iDim)} = ':';
    end
    str = '(';
    for iStr = 1:length(ca)
        str = [str ca{iStr} ','];
    end
    str(end) = ')';
    
    rs = ones(1,length(sz));
    rs(wthDim(iWth)) = sz(wthDim(iWth));
    rp = sz;
    rp(wthDim(iWth)) = 1;
    wthGrid=repmat(reshape(1:sz(wthDim(iWth)),rs),rp);
    grid0 = squeeze(eval(['wthGrid' str]));
    
    for iLvl=1:numel(grid0)
        wthlabel0{iWth,iLvl} = sprintf('%s_%d',dimnames{wthDim(iWth)},grid0(iLvl));
    end
end
wthlabel = cell(1,size(wthlabel0,2));
for iCol=1:size(wthlabel0,2)
    str = '';
    for iRow=1:size(wthlabel0,1)
        str = [str ',' sprintf('%s',wthlabel0{iRow,iCol})];
    end
    wthlabel{iCol} = str(2:end);
end
header = cat(2,replabel,btwlabel);
header(1:size(wthlabel,1),end+1:end+size(wthlabel,2)) = wthlabel;
tab.HEADER = header;
tab.DATA = [REP BTW WTH];