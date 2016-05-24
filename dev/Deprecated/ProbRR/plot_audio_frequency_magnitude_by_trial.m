function ah=plot_audio_frequency_magnitude_by_trial(fGrid,tGrid,mGrid,tones,varargin)

logMag = true;
process_varargin(varargin);

ah=gca;
hold on

fList = fGrid(1,:);
tList = tGrid(:,1);
if logMag
    imagesc(fList/1000,tList,log10(mGrid))
else
    imagesc(fList/1000,tList,mGrid);
end
set(gca,'xlim',[min(fGrid(1,:))/1000 max(fGrid(1,:))/1000])
set(gca,'ylim',[min(tGrid(:,1)) max(tGrid(:,1))])

plot(tones/1000,1:length(tones),'wx')
ytick = unique(round(get(gca,'ytick')));
set(gca,'ytick',ytick)
hold off
drawnow