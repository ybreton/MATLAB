function [ID,IT,PreTitration,PostTitration] = DD_idealTitration(sd,varargin)
% Gets an ideal titration function 
%
%
%

nL = 20; % number of final laps
smoothing = 1; % windows to smooth over.
process_varargin(varargin);

laps = 1:sd.TotalLaps;
C=sd.ZoneIn==sd.DelayZone;
startLap = min(find(C,1,'first'));

[DD,LL] = DD_getDelays(sd,'nL',sd.TotalLaps);
SD = LL(find(~isnan(LL),1,'first'));
FD = nanmean(LL(laps>sd.TotalLaps-nL));
if isempty(SD)
    SD = nan;
end
if isempty(FD)
    FD = nan;
end

if ~isnan(FD)
    nIdealAdjust = round(abs(FD-SD));

    if FD>SD+1
        direction = 1;
    elseif FD<SD-1
        direction = -1;
    else
        direction = 0;
    end

    ID = nan(sd.TotalLaps,1);
    ID(1) = SD;
    crosspt = nan;
    crosspt2 = nan;
    for iL = 2 : sd.TotalLaps
        if ID(iL-1)>FD
            ID(iL) = max(ID(iL-1)-1,1);
        end
        if ID(iL-1)<FD
            ID(iL) = ID(iL-1)+1;
        end
        if ID(iL-1)==FD
            ID(iL) = ID(iL-1);
        end
        if ID(iL)>FD & direction == 1
            ID(iL) = FD;
        end
        if ID(iL)<FD & direction == -1
            ID(iL) = FD;
        end
        if direction == 0
            ID(iL) = FD;
        end

        if direction>=0 & isnan(crosspt) & ~isnan(crosspt2)
            if LL(iL-1)<FD & LL(iL)>=FD
                crosspt = iL;
            end
        end
        if direction<=0 & isnan(crosspt)& ~isnan(crosspt2)
            if LL(iL-1)>FD & LL(iL)<=FD
                crosspt = iL;
            end
        end
        if direction>=0 & isnan(crosspt2)
            if LL(iL)>SD & LL(iL-1)>SD
                crosspt2 = iL-2;
            end
        end
        if direction<=0 & isnan(crosspt2)
            if LL(iL)<SD & LL(iL-1)<SD
                crosspt2 = iL-2;
            end
        end
    end
    if isnan(crosspt);crosspt=1;end;
    if isnan(crosspt2);crosspt2=0;end;

    if smoothing>1
        ID = smooth(ID,smoothing);
    end

    if crosspt>1
        IT = ID(1:sd.TotalLaps-(crosspt-nIdealAdjust)+1);
        % PreTitration = length(LL)-length(IT);
        PreTitration = crosspt2;
        PostTitration = crosspt;
        IT = [ones(length(LL)-length(IT),1)*IT(1);IT];
    else
        IT = ones(length(LL),1)*FD;
        PreTitration = crosspt2;
        PostTitration = crosspt;
    end
else
    PreTitration = nan;
    PostTitration = nan;
    ID = nan(sd.TotalLaps,1);
    IT = nan(sd.TotalLaps,1);
end