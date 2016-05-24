function PF = placeField1D(s,x,v,varargin)
% Identify the place fields of s.
% PF = placeField(s,x,v)
% where         PF              is a n x m x ... x p place field structure
%                               with fields:
%                   .nFields        is a scalar with the number of
%                                   well-defined place fields,
%                   .Labels         is a nybins x nxbins image of the labelled
%                                   place fields,
%                   .BW             is a nFields x nybins x nxbins image of
%                                   each placae field,
%                   .Area           is a nFields x 1 vector of areas for
%                                   each place field,
%                   .Centroid.x     is a nFields x 1 vector of the x positions
%                                   of the centroid of the place field,
%                   .Centroid.y     is a nFields x 1 vector of the y positions
%                                   of the centroid of the place field,
%                   .Peak.x         is a nFields x 1 vector of the x
%                                   positions of the peak firing rate,
%                   .Peak.y         is a nFields x 1 vector of the y
%                                   positions of the peak firing rate,
%                   .ConvexHull.x   is a nFields x 1 cell array of the x
%                                   positions of each field's convex hull,
%                   .ConvexHull.y   is a nFields x 1 cell array of the y
%                                   positions of each field's convex hull,
%                   .ConvexArea     is a nFields x 1 vector of the area of
%                                   the convex hull for each field.
%
%           s                   is a ts or cell array of ts's of spikes for
%                               place field computation.
%           x                   is a tsd of x-coordinates.
%           v                   is a tsd of rat velocities.
%
% OPTIONAL ARGUMENTS:
% ******************
% nxbins    (default 64 bins)
%   number of bins for x coordinate
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

nxbins = 64;    % number of x bins
minSpeed = 5;   % minimum rat speed through place field
minFRpct = 5;   % minimum pct firing rate of maximum in a place field
minOcc = 0.25;  % mininum occupancy of a spatial bin in a place field
minPFsz = 2;    % minimum coverage of a place field
maxConn = 2;    % maximum distance
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
    inc = abs(v0)>=minSpeed;
    s1 = s0(inc);
    s{iC} = ts(s1);
end

D1 = {x, nxbins};
D = {D1};
TC = TuningCurves(s,D);
H = TC.H;
Occ = repmat(reshape(TC.Occ,[1 nxbins]),[nCells 1 ]);
xmin = TC.min(1);
xmax = TC.max(1);

alphamask = Occ>minOcc;

xs = linspace(xmin,xmax,nxbins);

for iC=1:length(s)
    I = squeeze(H(iC,:,:));
    N = squeeze(Occ(iC,:,:));
    alphamask0 = squeeze(alphamask(iC,:,:));
    I0 = I;
    I0(~alphamask0) = nan;
    maxFR = max(I0(:));
    thresholded = I0>=maxFR*(minFRpct/100);
    thresholded = repmat(thresholded, [maxConn+1,1]);
    k = ceil(maxConn/2)+1;
    for iConn=1:ceil(maxConn/2)
        thresholded(k-iConn,1:iConn) = 0;
        thresholded(k+iConn,end-iConn:end) = 0;
        thresholded(k-iConn,iConn+1:end) = thresholded(k,1:end-iConn);
        thresholded(k+iConn,1:end-iConn) = thresholded(k,iConn+1:end);
    end
        
    L = bwlabel(thresholded,8);
    L = L(k,:);
    
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
    
    pfields = zeros(1,nxbins);
    bw = zeros(length(incL),1,nxbins);
    centroid.x = nan(length(incL),1);
    centroid.y = nan(length(incL),1);
    peak = centroid;
    chull.x = cell(length(incL),1);
    chull.y = cell(length(incL),1);
    area = nan(length(incL),1);
    carea = area;
    for iL=1:length(incL)
        idx = L==incL(iL);
        pfields(idx) = iL;
        bw(iL,:,:) = idx;
        stats = regionprops(squeeze(bw(iL,:,:)),'Centroid','ConvexHull','Area');
        Imasked = I;
        Imasked(~idx) = nan;
        [m,ix] = max(max(Imasked,[],1),[],2);
        peak.x(iL) = interp1(1:nxbins,xs,ix);
        centroid.x(iL) = interp1(1:nxbins,xs,stats.Centroid(1));
        chull.x{iL} = stats.ConvexHull(:,1);
        area(iL) = stats.Area;
        carea(iL) = polyarea(stats.ConvexHull(:,1),stats.ConvexHull(:,2));
    end
    
    if debug
        subplot(1,nCells,iC)
        hold on
        plot(xs,I./N,'r-')
        plot(centroid.x,0,'rx','markersize',12)
        hold off
        drawnow;
    end
    
    pf.nFields = length(incL);
    pf.Labels = pfields;
    pf.BW = bw;
    pf.Area = area;
    pf.Centroid = centroid;
    pf.Peak = peak;
    pf.ConvexHull = chull;
    pf.ConvexArea = carea;
    
    PF(iC) = pf;
end