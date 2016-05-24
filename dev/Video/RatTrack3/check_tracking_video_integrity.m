function [badframes,I,fh] = check_tracking_video_integrity(fn,varargin)
%
%
%
%

thresh = 10;
plot_RMS = false;
plot_badFrame = true;
process_varargin(varargin);
fprintf('\nLoading video %s',fn)
vObj = VideoReader(fn);
fprintf('\nVideo loaded.')
nFrames = vObj.NumberOfFrames;
frameList = (1 : nFrames)';
D = nan(nFrames,1);
if nargout>2 || plot_RMS
    fh=figure;
    cla
    hold on
    xlabel('Minutes')
    ylabel('RMS')
end
onePercent = floor(nFrames/100);
tenPercent = floor(nFrames/10);
fprintf('\n');
t0 = clock;
parfor iF = 2 : nFrames
    fr2 = read(vObj,iF);
    fr1 = read(vObj,iF-1);
    
    Sqdev = (rgb2gray(fr2)*255 - rgb2gray(fr1)*255).^2;
    D(iF) = sqrt(mean(Sqdev(:)));
%     clear fr1 fr2 Sqdev
%     if iF==2
%         t1 = clock;
%         e = etime(t1,t0);
%         tPerFrame = e;
%         r = tPerFrame*(nFrames-2);
%         m = fix(r/60);
%         s = (r-m*60);
%         fprintf('Approximate time to completion: %.dm:%.1f\n\n',m,s)
%     end
%     if mod(iF-1,onePercent)==0
%         fprintf('.')
%     end
%     if mod(iF-1,tenPercent)==0
%         fprintf('\n')
%         t1 = clock;
%         e = etime(t1,t0);
%         tPerFrame = e/(iF-1);
%         r = tPerFrame*(nFrames-iF);
%         p = round(((iF-1)/tenPercent)*10);
%         fprintf('%d%% Complete. %.1f min elapsed. %.1f min remain.',p,e/60,r/60)
%         fprintf('\n')
%     end
end
if nargout>2 || plot_RMS
    hold off
    title(num2str(iF))
    plot(iF/30/60,D(iF),'ko','markerfacecolor','k','markersize',8)
    drawnow
    [path,name,ext] = fileparts(fn);
    figFile = [path '\' name '-IntegrityCheck.fig'];
    saveas(fh,figFile);
end
I = D>=thresh;
badframes = frameList(I);
if plot_badFrame
    for f = 1 : length(badframes)
        fh0 = figure;
        
        hold on
        title(num2str(badframes(f)))
        fr = read(vObj,badframes(f));
        imshow(fr);
        hold off
        saveas(fh0,[num2str(badframes(f)) '.jpg'],'jpg')
        close(fh0);
    end
end
deviations = D(I);

if nargout<3
    fprintf('\nBad frame issue at frame %d; RMS-255 grayscale difference from last frame is %.1f>=10\n',badframes,deviations)
end
