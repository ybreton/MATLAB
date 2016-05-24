function [ZoneTimes,ZoneDelay,ZoneIn] = fixFPTzoneTimes(ZoneTimes,ZoneDelay,ZoneIn)
%
%
%
%

ZoneLabels = repmat((1:size(ZoneTimes,1))',1,size(ZoneTimes,2));
Laps = repmat(1:size(ZoneTimes,2),size(ZoneTimes,1),1);

T = ZoneTimes(:);
Z = ZoneLabels(:);
L = Laps(:);
str = cell(length(T),1);
str(Z==1) = {sprintf('Entering SoM')};
str(Z==2) = {sprintf('Exiting SoM')};
str(Z==3) = {sprintf('Entering CP')};
str(Z==4) = {sprintf('Exiting CP')};
str(Z==5) = {sprintf('Entering Feeder')};
str(Z==6) = {sprintf('Exiting Feeder')};

for iTS=1:length(T)-1
    Ilo = find(T(iTS)>T(iTS+1:end),1,'first');
    if ~isempty(Ilo)
        disp(['Error on lap ' num2str(L(iTS)) ', ' str{iTS}])
        ZoneTimes(Z(iTS),L(iTS)+1:end) = ZoneTimes(Z(iTS),L(iTS):end-1);
        ZoneTimes(Z(iTS),L(iTS)) = nan;
        if Z(iTS)==5
            ZoneDelay = [ZoneDelay(1:L(iTS)-1) nan ZoneDelay(L(iTS):end)];
            ZoneIn = [ZoneIn(1:L(iTS)-1) nan ZoneIn(L(iTS):end)];
        end
        T = ZoneTimes(:);
    end
end

