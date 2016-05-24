function PF = placeFieldN(s,D,v,varargin)
% Identify the N-dimensional place field of s.
% PF = placeField(s,D,v)
% where         PF              is a n x m x ... x p place field structure
%                               with fields:
%                   .nFields        is a scalar with the number of
%                                   well-defined place fields,
%                   .Labels         is a nybins x nxbins image of the labelled
%                                   place fields,
%                   .BW             is a nybins x nxbins x nFields image of
%                                   each place field,
%                   .Area           is a nFields x 1 vector of areas for
%                                   each place field,
%                   .Centroid.x     is a nFields x 1 vector of the x positions
%                                   of the centroid of the place field,
%                   .Centroid.y     is a nFields x 1 vector of the y positions
%                                   of the centroid of the place field,
%                   .Peak.x         is a nFields x 1 vector of the x
%                                   positions of the peak firing rate,
%                   .Peak.y         is a nFields x 1 vector of the y
%                                   positions of the peak firing rate.
%
%           s                   is a ts or cell array of ts's of spikes for
%                               place field computation.
%           D                   is a cell array of tuning curve dimensions
%               D{i} = {Xi, xmin, xmax, nxbins}
%           v                   is a tsd of rat velocities.
%               
%
% OPTIONAL ARGUMENTS:
% ******************
% minSpeed  (default 5 [x,y] units/sec)
%   minimum speed rat must be travelling for tuning curves
% minFRpct  (default 5 percent)
%   minimum percentage maximum firing rate for place fields
% minOcc    (default 0.25 sec)
%   minimum occupancy for place fields
% minPFsz   (default 10 bins)
%   minimum area of place field
% debug     (default false)
%   produce debugging plots of place fields
%

minSpeed = 5;   % minimum rat speed through place field
minFRpct = 5;   % minimum pct firing rate of maximum in a place field
minOcc = 0.25;  % mininum occupancy of a spatial bin in a place field
minConn = conndef(length(D), 'maximal'); % minimum connectivity level
minPFsz = (minConn)+2;   % minimum coverage of a place field
debug=false;    % debugging flag
process_varargin(varargin);

if ~iscell(s)
    s = {s};
else
    s = s(:);
end
nCells = length(s);

for iC=1:nCells
    s0 = s{iC}.data;
    v0 = v.data(s0);
    inc = v0>=minSpeed;
    s1 = s0(inc);
    s{iC} = ts(s1);
end

TC = TuningCurves(s,D);
nBins = TC.nBin;
if length(nBins)<2
    nBins = [nBins 1];
end
nDims = length(D);
Dims = 1:nDims;
H = TC.H;
Occ = repmat(reshape(TC.Occ,[1 nBins]),[nCells 1 1]);

alphamask = Occ>minOcc;

xs = cell(nDims,1);
for iD=Dims
    xmin = TC.min(iD);
    xmax = TC.max(iD);
    nxbins = TC.nBin(iD);
    xs{iD} = linspace(xmin,xmax,nxbins);
end

for iC=1:length(s)
    I = squeeze(H(iC,:));
    I = reshape(I,nBins);
    alphamask0 = squeeze(alphamask(iC,:));
    alphamask0 = reshape(alphamask0,nBins);
    N = squeeze(Occ(iC,:));
    N = reshape(N,nBins);
    
    I0 = I;
    I0(~alphamask0) = nan;
    
    maxFR = max(I0(:));
    thresholded = I0>=maxFR*(minFRpct/100);
    
    L = bwlabeln(thresholded, conndef(ndims(thresholded), 'maximal'));
    
    % Remove connected components that don't make the minimum coverage
    f = unique(L(L>0));
    n = nan(length(f),1);
    F = nan(length(f),1);
    for iL=f(:)'
       n(iL)=sum(L(:)==iL);
       F(iL)=iL;
    end
    excL = F(n<minPFsz);
    incL = F(n>=minPFsz);
    incN = n(n>=minPFsz);
    for iL=excL(:)'
        idx = L==iL;
        L(idx) = 0;
    end
    
    % Relabel connected components from largest to smallest.
    [incN,idSort] = sort(incN);
    incL = incL(idSort);
    
    pfields = zeros(nBins);
    bw = zeros([length(incL), nBins]);
    centroid = nan(length(incL),length(D));
    peak = centroid;
    area = nan(length(incL),1);
    for iL=1:length(incL)
        idx = L==incL(iL);
        pfields(idx) = iL;
        bw(:,:,iL) = idx;
        stats = regionprops(idx,'Centroid','Area');
        % rows (dim 1) are actually y-dimensions of centroid.
        C = stats.Centroid;
        stats.Centroid(2) = C(1);
        stats.Centroid(1) = C(2);
        
        Imasked = I;
        Imasked(~idx) = nan;
        
        Itest = Imasked(:,:);
        [~,ix] = max(max(Itest,[],2));
        peak(iL,1) = interp1(1:nBins(iD),xs{iD},ix);
        centroid(iL,1) = interp1(1:nBins(iD),xs{iD},stats.Centroid(iD));
        for iD=2:length(D)
            notID = Dims(Dims~=iD);
            Itest = permute(Imasked,[iD notID]);
            Itest = Itest(:,:);
            [~,ix] = max(max(Itest,[],2));
            peak(iL,iD) = interp1(1:nBins(iD),xs{iD},ix);
            centroid(iL,iD) = interp1(1:nBins(iD),xs{iD},stats.Centroid(iD));
        end
        area(iL) = stats.Area;
        if debug
            for iD=Dims
                notID = Dims(Dims~=iD);
                p = (nDims*(iC-1))+iD
                subplot(nCells,nDims,p);
                hold on
                FR = I./N;
                if isempty(notID)
                    notID=2;
                end
                FR = permute(FR,[iD notID]);
                h = nanmean(FR(:,:),2);
                plot(xs{iD},h,'r-')
                xlabel(sprintf('Dimension %.0f',iD));
                ylabel('FR')
                title(sprintf('Cell %.0f',iC));
                plot(pf.Centroid(iL,iD),0,'ko','markersize',10)
                hold off
                drawnow
            end
        end
    end
    
    pf.nFields = length(incL);
    pf.Labels = pfields;
    pf.BW = bw;
    pf.Area = area;
    pf.Centroid = centroid;
    pf.Peak = peak;
    
    PF(iC) = pf;
    
end