function [LED,phiB,phiH] = make_RatTrack_tsds(RatTrackData,varargin)
% Prepares a time-stamped data file of rat position (LED) and body/head
% angle (phiB, phiH), based on a supplied or global RatTrackData.
%
% [LED,phiB,phiH] = make_RatTrack_tsds(RatTrackData,varargin)
% [LED,Phi] = make_RatTrack_tsds(RatTrackData,varargin)
% [Rat] = make_RatTrack_tsds(RatTrackData,varargin)
% [ ... ]= make_RatTrack_tsds
% where     Rat is a structure array with fields LED and Phi, or
%           LED is a time-stamped data object with rat LED position (x,y).
%           Phi is a structure array with fields,
%           .Body, the time-stamped data of body angle relative to LED,
%           .Head, the time-stamped data of head angle, or
%           phiB, phiH are time-stamped data of body and head angle,
%               respectively,
%           RatTrackData is a RatTrack2 structure produced by RatTrack2,
% varargin  'produceRpt' (default true) exports 
%               VideoFile.txt
%               - the filename of the video file analyzed, and
%               TimeStamped_FrameStamped_PositionXY_AngleBH.csv
%               - a table of the rat-tracking results
%               to a subdirectory in the video file's directory,
%           'savedTsd' (default false) exports LED, phiB and phiH tsd's to
%               the report subdirectory as individual .mat files.

if nargin < 1
    global RatTrackData
end
produceRpt = true;
saveTsd = true;
process_varargin(varargin);

% Export only from the time the rat is actually on video.
ratOnVideo = RatTrackData.RatVisible.frame;
idRatOnVideo = RatTrackData.iFrame>=ratOnVideo(1)&RatTrackData.iFrame<=ratOnVideo(end);
LED = tsd(RatTrackData.timestamp(idRatOnVideo),[RatTrackData.LEDx(idRatOnVideo) RatTrackData.LEDy(idRatOnVideo)]);
phiB = tsd(RatTrackData.timestamp(idRatOnVideo),[RatTrackData.LEDphiB(idRatOnVideo)]);
phiH = tsd(RatTrackData.timestamp(idRatOnVideo),[RatTrackData.LEDphiH(idRatOnVideo)]);
Phi.Body = phiB;
Phi.Head = phiH;

% Directory
if saveTsd|produceRpt
    fullFn = RatTrackData.FullFilename;
    id0 = regexp(fullFn,'\');
    id1 = regexp(fullFn,'/');
    idExt = max(regexp(fullFn,'\.'));
    if isempty(id0)
        id = id1;
        delim = '/';
    else
        id = id0;
        delim = '\';
    end
    idLastParent = max(id);
    f = fullFn(idLastParent+1:idExt-1);
    d = fullFn(1:idLastParent);
    mkdir([d f])
end
if saveTsd
    save([d f delim 'LED.mat'],'LED');
    save([d f delim 'phiB.mat'],'phiB');
    save([d f delim 'phiH.mat'],'phiH');
end

if produceRpt
    % Produce a report of the video tracking procedure.
    tca{1} = RatTrackData.FullFilename;
    tca{2} = 'Time stamped from start of MPEG.';
    cell2csv([d f delim 'VideoFile.txt'],tca)
    clear tca
    nFrames = RatTrackData.currentFrameCount-1;
    tca(1,:) = {'timestamp' 'frame' 'LEDx' 'LEDy' 'PhiB' 'PhiH'};
    tca(2:nFrames+1,:) = mat2can([RatTrackData.timestamp RatTrackData.iFrame RatTrackData.LEDx RatTrackData.LEDy RatTrackData.LEDphiB RatTrackData.LEDphiH]);
    cell2csv([d f delim 'TimeStamped_FrameStamped_PositionXY_AngleBH.csv'],tca)
end

if nargout<3
    phiB = Phi;
end
if nargout<2
    tsdLED = LED;
    clear LED
    LED.LED = tsdLED;
    LED.Phi = Phi;
end