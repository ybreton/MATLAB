function [pL_XY, pR_XY, pLtsd, pRtsd] = pChoiceX(sd, varargin)

nXb = 64; nYb = 128;
xMin = 100; xMax = 300;
yMin = 0; yMax = 400;
%xMin = 0; xMax = 480
%yMin = 0; yMax = 640;

process_varargin(varargin);

xEdges = linspace(xMin, xMax, nXb);
yEdges = linspace(yMin, yMax, nYb);

X = sd.x.data;
Y = sd.y.data;
L = sd.wentLeft.data;
R = sd.wentRight.data;

[pXY, ~, ~, bin] = histcn([X Y], xEdges, yEdges);
pXY = pXY./sum(pXY(:));
bin = bin+1; % correction c to matlab

pXY_L = histcn([X(L) Y(L)], xEdges, yEdges);
pXY_L = pXY_L./sum(pXY_L(:));

pXY_R = histcn([X(R) Y(R)], xEdges, yEdges);
pXY_R = pXY_R./sum(pXY_R(:));

pL_XY = pXY_L ./ pXY;
pL_XY = pL_XY./nansum(pL_XY(:));

pR_XY = pXY_R ./ pXY;
pR_XY = pR_XY./nansum(pR_XY(:));

ix = sub2ind(size(pL_XY), bin(:,1), bin(:,2));
pLtsd = tsd(sd.x.range, pL_XY(ix));
pRtsd = tsd(sd.x.range, pR_XY(ix));

end

%%
function extra
%%
 subplot(2,2,1); scatter(-sd.y.data, -sd.x.data, 10, pLtsd.data.*wentLeft.data);  caxis([0 0.001]); title('pL went L');
 subplot(2,2,2); scatter(-sd.y.data, -sd.x.data, 10, pLtsd.data.*wentRight.data); caxis([0 0.001]); title('pL went R');
 subplot(2,2,3); scatter(-sd.y.data, -sd.x.data, 10, pRtsd.data.*wentLeft.data);  caxis([0 0.001]); title('pR went L');
 subplot(2,2,4); scatter(-sd.y.data, -sd.x.data, 10, pRtsd.data.*wentRight.data); caxis([0 0.001]); title('pR went R');
end