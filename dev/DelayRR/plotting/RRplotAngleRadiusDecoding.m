function pOut = RRplotAngleRadiusDecoding(sd,B,T,thetaBins,radiusBins)
% assumes sd has fields theta and radius.
%
%
%

CoM = [nanmean(sd.x.data(sd.EnteringZoneTime)) nanmean(sd.y.data(sd.EnteringZoneTime))];
zoneTheta = [-pi/2;
             0;
             pi/2;
             pi];
z = tsd(sd.EnteringZoneTime',sd.ZoneIn');
thetaList = linspace(B.min(1),B.max(1),B.nBin(1));
radiusList = linspace(B.min(2),B.max(2),B.nBin(2));
p = B.pxs.data(T);
idInc = any(any(~isnan(p),2),3);

p = p(idInc,:,:);
T = T(idInc);

thetaOut = nan(size(p));
radiusOut = nan(size(p));

for iTrl = 1 : length(T)
    theta = sd.theta.data(T(iTrl));
    radius = sd.radius.data(T(iTrl));
    iZ = z.data(T(iTrl));
    
%     theta0 = thetaList - theta;
    theta0 = thetaList - zoneTheta(iZ);
    theta0(theta0<-pi) = pi-(abs(theta0(theta0<-pi))-pi);
    theta0(theta0>pi) = -pi+(theta0(theta0>pi)-pi);
    
    radius0 = radiusList-radius;
    thetaOut(iTrl,:,:) = repmat(theta0(:),1,length(radius0));
    radiusOut(iTrl,:,:) = repmat(radius0(:)',length(theta0),1);
end
binw(1) = mean(diff(thetaBins));
binw(2) = mean(diff(radiusBins));

pOut = nan(length(T),length(thetaBins),length(radiusBins));
for iTrl=1:length(T)
    for iTheta = 1 : length(thetaBins)
        idT = thetaOut(iTrl,:,1)>=thetaBins(iTheta)-binw(1)/2 & thetaOut(iTrl,:,1)<thetaBins(iTheta)+binw(1)/2;
        for iRadius = 1 : length(radiusBins)
            idR = radiusOut(iTrl,1,:)>=radiusBins(iRadius)-binw(2)/2 & radiusOut(iTrl,1,:)<radiusBins(iRadius)+binw(2)/2;
            p0 = p(iTrl,idT,idR);
            if ~isempty(p0)
                if ~all(isnan(p0))
                    pOut(iTrl,iTheta,iRadius) = nansum(p0(:));
                end
            end
        end
    end
end

imagesc(thetaBins,radiusBins,squeeze(nanmean(pOut,1))')
xlabel('Radians from zone entry')
ylabel('Radial distance from zone entry')
