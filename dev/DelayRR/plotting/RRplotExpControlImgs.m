function [fh,ah,cbh,oh] = RRplotExpControlImgs(x,y,controlImg,expImg,varargin)
%
%
%
%

zMax = max([controlImg(:);expImg(:)]);
zMin = min([controlImg(:);expImg(:)]);
process_varargin(varargin);
oh = nan(2,2);
cbh= nan(2,2);
ah = nan(2,2);
fh = gcf;
clf
ah(1)=subplot(2,2,1);
oh(1)=imagesc(x,y,controlImg);
caxis([zMin zMax])
cbh(1)=colorbar;
set(get(cbh(1),'ylabel'),'rotation',-90)
title('Control')
axis xy

ah(4)=subplot(2,2,4);
oh(4)=imagesc(x,y,controlImg);
caxis([zMin zMax])
cbh(4)=colorbar;
set(get(cbh(4),'ylabel'),'rotation',-90)
title('Control')
axis xy

ah(3)=subplot(2,2,3);
oh(3)=imagesc(x,y,expImg);
caxis([zMin zMax])
cbh(3)=colorbar;
set(get(cbh(3),'ylabel'),'rotation',-90)
title('Experimental')
axis xy
