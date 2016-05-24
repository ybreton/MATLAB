function RRplotXYdecoding(sd,B,T)
%
%
%
%
nTrls = length(sd.ZoneIn);
z = tsd(sd.EnteringZoneTime',sd.ZoneIn');
CoM = [nanmean(sd.x.data(sd.EnteringZoneTime)) nanmean(sd.y.data(sd.EnteringZoneTime))];
p = B.pxs.data(T);
z = z.data(T);
pTrl = nan(size(p,1),max(size(p,2),size(p,3)),max(size(p,2),size(p,3)));
xList = linspace(B.min(1),B.max(1),B.nBin(1));
yList = linspace(B.min(2),B.max(2),B.nBin(2));
x = nan(length(T),1);
y = nan(length(T),1);
for iTrl = 1 : length(T)
    p0 = squeeze(p(iTrl,:,:));
    if z(iTrl)>1
        p0 = rot90(p0,-(z(iTrl)-1));
    end
    pTrl(iTrl,1:size(p0,1),1:size(p0,2)) = p0;
    x0 = round(sd.x.data(T(iTrl)));
    y0 = round(sd.y.data(T(iTrl)));
    theta0 = atan2(y0-CoM(2),(x0-CoM(1)));
    r0 = sqrt((y0-CoM(2)).^2+((x0-CoM(1))).^2);
    theta = theta0-(pi/2)*(z(iTrl)-1);
    
    x(iTrl) = CoM(1)+r0*cos(theta);
    y(iTrl) = CoM(2)+r0*sin(theta);
    
    cla
    imagesc(xList,yList,p0');
    hold on
    plot(x(iTrl),y(iTrl),'wx');
    hold off
end

mPxs = squeeze(nanmean(pTrl,1));
imagesc(xList,yList,mPxs);
hold on
plot(nanmean(x),nanmean(y),'wx')
hold off