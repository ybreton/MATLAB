cmap = [1 0 0; 0.8 0.8 0; 0 0 0; .21 .05 0];
thresh = nan(4,1);
figure;
for iZ = 1:4; 
    subplot(2,2,iZ); 
    title(sprintf('Zone %d\n%d Pellets',iZ,nPelletsSS(iZ)));
    hold on; 
%     plot(ZoneDelay(ZoneIn(1:160)==iZ), ismember(ExitZoneTime(ZoneIn(1:160)==iZ), FeederTimes),'.','markeredgecolor',cmap(iZ,:));  
    D = ZoneDelaySS(ZoneInSS(1:length(ZoneDelaySS))==iZ);
    E = ismember(ExitZoneTimeSS(ZoneInSS(1:length(ZoneDelaySS))==iZ), FeederTimesSS);
    ph=plot_grouped_Y(D(:), E(:),'dist','binomial');  
    set(ph,'markerfacecolor',cmap(iZ,:));
    set(ph,'markeredgecolor','k');
    
    b = glmfit(D(:),E(:),'binomial','link','logit');
    yhat = glmval(b, unique(D(:)),'logit');
    plot(unique(D(:)),yhat,'-','color',cmap(iZ,:));
    thresh(iZ) = -b(1)/b(2);
    hold off; 
end