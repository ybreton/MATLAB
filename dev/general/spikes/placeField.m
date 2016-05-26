function PF = placeField(s,x,y,varargin)
% Identify the place fields of s.
% PF = placeField(s,x,y)
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
%                   .FiringRate.max is a nFields x 1 vector of the peak
%                                   firing rate in the place field,
%                   .FiringRate.mean
%                                   is a nFields x 1 vector of the mean
%                                   firing rate across the place field,
%                   .ConvexHull.x   is a nFields x 1 cell array of the x
%                                   positions of each field's convex hull,
%                   .ConvexHull.y   is a nFields x 1 cell array of the y
%                                   positions of each field's convex hull,
%                   .ConvexArea     is a nFields x 1 vector of the area of
%                                   the convex hull for each field,
%                   .TC             is a structure with the tuning curve
%                                   information:
%                       .H          1 x nX x nY Histogram of spikes
%                                   occurring in each bin,
%                       .Occ        1 x nX x nY Histogram of occupancy in
%                                   each bin (in seconds),
%                       .Rate       1 x nX x nY matrix of firing rate
%                       .min        (x,y) minimum bin,
%                       .max        (x,y) maximum bin,
%                       .nBin       (x,y) number of bins,
%                   .x, .y          with the x and y coordinates that
%                                   correspond to each x,y pixel bin.
%
%           s                   is a ts or cell array of ts's of spikes for
%                               place field computation.
%           x                   is a tsd of x-coordinates.
%           y                   is a tsd of y-coordinates.
%
% OPTIONAL ARGUMENTS:
% ******************
% nxbins    (default 64 bins)
%   number of bins for x coordinate
% nybins    (default 64 bins)
%   number of bins for y coordinate
% minSpeed  (default 5 [x,y] units/sec)
%   minimum speed rat must be travelling for tuning curves
% minFRpct  (default 5 percent)
%   minimum percentage maximum firing rate for place fields
% minOcc    (default 0.25 sec)
%   minimum occupancy for place fields
% maxDist   (default 2 bins)
%   furthest two spatial bins can be apart and still count as 1 field
% minPFsz   (default 9 bins)
%   minimum area of place field
% debug     (default false)
%   produce debugging plots of place fields
%
% UPDATE HISTORY:
% **************
% 2016-05-05 (YAB)  -Place fields now sorted according to peak firing rate
%                   in field, such that place field 1 is the place field
%                   containing the highest firing rate bin
%                   -FiringRate structure array field with max and mean
%                   firing rates within the place field
%                   -BW field is now arranged nFields x nX x nY instead of
%                   nX x nY x nFields to make more consistent with
%                   TuningCurves usage
%                   -Firing now calculated as firing rate, normalized by
%                   occupancy.
%                   -TC structure array field also contains firing rate
%

nxbins = 64;    % number of y bins
nybins = 64;    % number of x bins
minSpeed = 5;   % minimum rat speed through place field
minFRpct = 5;   % minimum pct firing rate of maximum in a place field
minOcc = 0.25;  % mininum occupancy of a spatial bin in a place field
maxDist = 2;    % maximum number of bins to merge place fields
minPFsz = 9;   % minimum coverage of a place field
debug=false;    % debugging flag
process_varargin(varargin);

if ~iscell(s)
    s = {s};
else
    s = s(:);
end
nCells = length(s);


D1 = {x, nxbins};
D2 = {y, nybins};
D = {D2,D1};
for iC=1:nCells
    s0 = s{iC}.data;
    dx = dxdt(x);
    dy = dxdt(y);
    v = sqrt(dx.data.^2+dy.data.^2);
    v = tsd(dx.range,v);
    v0 = v.data(s0);
    inc = v0>=minSpeed;
    s1 = s0(inc);
    s{iC} = ts(s1);
end

TC = TuningCurves(s,D);
H = TC.H;
Occ = repmat(reshape(TC.Occ,[1 nybins nxbins]),[nCells 1 1]);
Rt = H./(eps+Occ);
xmin = TC.min(2);
ymin = TC.min(1);
xmax = TC.max(2);
ymax = TC.max(1);

xs = linspace(xmin,xmax,nxbins);
ys = linspace(ymin,ymax,nybins);

alphamask = Occ>minOcc;

if debug
    clf
    r = ceil(sqrt(nCells));
    c = ceil(nCells/r);
    for iC=1:nCells
        subplot(r,c,iC);
        colormap paruly
        hold on
        ih=imagesc(xs,ys,squeeze(Rt(iC,:,:)));
        set(ih,'AlphaData',squeeze(alphamask(iC,:,:)));
        plot(x.data(s{iC}.data),y.data(s{iC}.data),'r.');
        xlim([xmin xmax])
        ylim([ymin ymax])
        set(gca,'xtick',[])
        set(gca,'ytick',[])
        caxis([0.05 1])
        if nCells>1
            title(sprintf('C%.0f',iC));
        end
        hold off
        axis xy
        drawnow;
    end
end

for iC=1:length(s)
    I = squeeze(Rt(iC,:,:));
    alphamask0 = squeeze(alphamask(iC,:,:));
    I0 = I;
    Occ0 = squeeze(Occ(iC,:,:));
    I0(~alphamask0) = nan;
    Occ0(~alphamask0) = nan;
    
    maxFR = max(I0(:));
    thresholded = I0>=maxFR*(minFRpct/100);
        
    L = bwlabel(thresholded,8);
    L = mergeLabels(L,maxDist);
    
    % Remove connected components that don't make the minimum coverage
    f = unique(L(L>0));
    n = nan(length(f),1);
    F = nan(length(f),1);
    R = nan(length(f),1);
    Rm = nan(length(f),1);
    for iL=f(:)'
       n(iL)=sum(L(:)==iL);
       F(iL)=iL;
       R(iL)=max(I0(L==iL)./Occ0(L==iL));
       Rm(iL)=nansum(I0(L==iL))./(eps+nansum(Occ0(L==iL)));
    end
    excL = F(n<minPFsz);
    incL = F(n>=minPFsz);
    incN = n(n>=minPFsz);
    FR = R(n>=minPFsz);
    Rm = Rm(n>=minPFsz);
    for iL=excL(:)'
        idx = L==iL;
        L(idx) = 0;
    end
    
    % Relabel connected components from largest to smallest FR.
    [FR,idSort] = sort(FR,'descend');
    incN = incN(idSort);
    incL = incL(idSort);
    Rm = Rm(idSort);
    
    pfields = zeros(nybins,nxbins);
    bw = zeros(length(incL),nybins,nxbins);
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
        [m,iy] = max(max(Imasked,[],2),[],1);
        peak.x(iL) = interp1(1:nxbins,xs,ix);
        peak.y(iL) = interp1(1:nybins,ys,iy);
        centroid.x(iL) = interp1(1:nxbins,xs,stats.Centroid(1));
        centroid.y(iL) = interp1(1:nybins,ys,stats.Centroid(2));
        chull.x{iL} = stats.ConvexHull(:,1);
        chull.y{iL} = stats.ConvexHull(:,2);
        area(iL) = stats.Area;
        carea(iL) = polyarea(stats.ConvexHull(:,1),stats.ConvexHull(:,2));
    end
    
    if debug
        subplot(r,c,iC)
        hold on
        plot(centroid.x,centroid.y,'rx','markersize',12)
        hold off
        drawnow;
    end
    
    pf.nFields = length(incL);
    pf.Labels = pfields;
    pf.BW = bw;
    pf.Area = area;
    pf.Centroid = centroid;
    pf.Peak = peak;
    pf.FiringRate.max = FR;
    pf.FiringRate.mean = Rm;
    pf.ConvexHull = chull;
    pf.ConvexArea = carea;
    
    TC0.H = TC.H(iC,:,:);
    TC0.Occ = Occ(iC,:,:);
    TC0.Rate = Rt(iC,:,:);
    TC0.min = TC.min;
    TC0.max = TC.max;
    TC0.nBin = TC.nBin;
    TC0.tStart = TC.tStart;
    TC0.tEnd = TC.tEnd;
    
    pf.TC = TC0;
    pf.x = xs;
    pf.y = ys;
    
    PF(iC) = pf;
end