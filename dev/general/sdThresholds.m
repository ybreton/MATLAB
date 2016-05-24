function sd = sdThresholds(sd,varargin)
%
%
%
%

threshFun = @RRheaviside;
process_varargin(varargin);

d = sd.ZoneDelay(:);
sg = sd.stayGo(:);
z = sd.ZoneIn(:);
uniqueZones = unique(z);

thresholds = nan(1,length(sd.ZoneIn));
for iZ=uniqueZones(:)'
    idz = z==iZ;
    idOK = ~isnan(d)&~isnan(sg);
    X = d(idz&idOK);
    y = sg(idz&idOK);
    if isempty(threshFun)

        b = glmfit(X,y,'binomial');
        % 0.5 = 1/(1+e^-z)
        % e^-z = 1
        % ln(1)= -z
        % ln(1)= -(b(1)+b(2)*x)
        % 0 = -b(1)-b(2)*x
        % b(1)=-b(2)*x
        % b(1)/(-b(2))=x
        theta = nanmean(b(1)/(-b(2)));
    elseif isa(threshFun,'function_handle')
        theta = nanmean(threshFun(X,y));
    end
    thresholds(idz&idOK) = theta;
end

sd.Thresholds = thresholds;