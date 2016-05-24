function [Fr,Rxy,Gxy,Bxy,Lumxy] = getNVTframe(nvtFn,t,varargin)
% returns a structure array with neuralynx NVT target information.
% Fr = getNVTframe(nvtFn,t)
% where     Fr              is a structure array with fields
%               .cdata      a nTimes x nTargets x 3 matrix of true/false
%                               values for target color as RGB
%               .intensity  is a nTimes x nTargets matrix of intensity
%                               true/false values for target
%               .t          is a nTimes x 1 vector of time stamps obtained
%               .x          is a nTimes x 1 vector of x positions for
%                               target
%               .y          is a nTimes x 1 vector of y positions for
%                               target
%
%           nvtFn           is a string specifying the neuralynx NVT file
%           t               is the time stamp to extract. Leaving this
%                               empty will extract all time stamps.
%
% [Fr,Rxy,Gxy,Bxy] = getNVTframe(nvtFn,t)
% where     Rxy             is a structure array with fields
%               .x          a tsd of x position for each target, restricted
%                               to red threshold-exceeding positions,
%               .y          a tsd of y position for each target, restricted
%                               to red threshold-exceeding positions,
%               .mx         a tsd of x position, averaged over targets,
%                               restricted to red threshold-exceeding
%                               positions,
%               .my         a tsd of y position, averaged over targets,
%                               restricted to red threshold-exceeding
%                               positions,
%           Gxy             is a structure array with fields
%               .x          a tsd of x position for each target, restricted
%                               to green threshold-exceeding positions,
%               .y          a tsd of y position for each target, restricted
%                               to green threshold-exceeding positions,
%               .mx         a tsd of x position, averaged over targets,
%                               restricted to green threshold-exceeding
%                               positions,
%               .my         a tsd of y position, averaged over targets,
%                               restricted to green threshold-exceeding
%                               positions,
%           Bxy             is a structure array with fields
%               .x          a tsd of x position for each target, restricted
%                               to blue threshold-exceeding positions,
%               .y          a tsd of y position for each target, restricted
%                               to blue threshold-exceeding positions,
%               .mx         a tsd of x position, averaged over targets,
%                               restricted to blue threshold-exceeding
%                               positions,
%               .my         a tsd of y position, averaged over targets,
%                               restricted to blue threshold-exceeding
%                               positions.
% %         Lumxy           is a structure array with fields
%               .x          a tsd of x position for each target, restricted
%                               to intensity threshold-exceeding positions,
%               .y          a tsd of y position for each target, restricted
%                               to intensity threshold-exceeding positions,
%               .mx         a tsd of x position, averaged over targets,
%                               restricted to intensity threshold-exceeding
%                               positions,
%               .my         a tsd of y position, averaged over targets,
%                               restricted to intensity threshold-exceeding
%                               positions.
% OPTIONAL ARGUMENTS:
% ******************
% progressBar   (default false)
%                           logical specifying whether the user should be
%                           updated about progress on NVT target grabbing.
% multiplier    (default 1e-6)
%                           scalar providing the conversion of timestamps
%                           into seconds.
%

progressBar = false;
multiplier = 1e-6;
process_varargin(varargin);

[timestamps,X,Y,Phi,targets,points,header]=Nlx2MatVT(nvtFn,[1 1 1 1 1 1],1,1,[]);
timestamps = timestamps*multiplier;
if isempty(t)
    t = timestamps;
end
invalidTimepoints = find(all(targets==0,1));
% disp([num2str(length(invalidTimepoints)) ' time points without targets.'])
T = ts(timestamps);
t0 = nan(length(t),1);
for iT=1:length(t)
    t0(iT) = T.data(t(iT));
end
t = unique(t0);

red = nan(size(targets,1),length(t));
green = nan(size(targets,1),length(t));
blue = nan(size(targets,1),length(t));
intensity = nan(size(targets,1),length(t));
x = nan(size(targets,1),length(t));
y = nan(size(targets,1),length(t));
validTargets = any(targets>0,2);
maxTargets = find(validTargets,1,'last');
if progressBar
    ten = ceil(length(t)*0.1);
    one = ceil(length(t)*0.01);
    fprintf('\n')
    t0 = clock;
end

for iT=1:length(t)
    
    record = find(timestamps==t(iT));
    if all(record~=invalidTimepoints)
        for iR=1:maxTargets
            if targets(iR,record)~=0
                [red(iR,iT), green(iR,iT), blue(iR,iT), intensity(iR,iT), x(iR,iT), y(iR,iT)] = vt_bitfield_decode(targets(iR,record));
            end
        end
    end
    if progressBar
        if mod(iT,one)==0
            fprintf('.')
        end
        if mod(iT,ten)==0
            elapsed = etime(clock,t0);
            remain = (elapsed/iT)*(length(t)-iT);
            fprintf('\n%.0f%% complete. %.0fs elapsed. %.0fs remain.\n',iT/one,elapsed,remain);
        end
    end
end
if progressBar
    fprintf('\n')
end
Fr.cdata = cat(3,red',green',blue');
Fr.intensity = intensity';
Fr.t = t(:);
Fr.x = x(:);
Fr.y = y(:);

if nargout>1
    Dx = nan(length(t),maxTargets);
    Dy = nan(length(t),maxTargets);
    mx = nan(length(t),1);
    my = nan(length(t),1);
    for iT=1:size(red,2)
        id = red(1:maxTargets,iT)==1;
        if any(id)
            x0 = x(id,iT);
            y0 = y(id,iT);
            idnan = isnan(x0)|isnan(y0);
            nTargets = length(x0(~idnan));
            Dx(iT,1:nTargets) = x0(~idnan);
            Dy(iT,1:nTargets) = y0(~idnan);
            mx(iT) = nanmean(x0);
            my(iT) = nanmean(y0);
        end
    end
    Rxy.x = tsd(t,Dx);
    Rxy.y = tsd(t,Dy);
    Rxy.mx = tsd(t,mx);
    Rxy.my = tsd(t,my);
end

if nargout>2
    Dx = nan(length(t),maxTargets);
    Dy = nan(length(t),maxTargets);
    mx = nan(length(t),1);
    my = nan(length(t),1);
    for iT=1:size(green,2)
        id = green(1:maxTargets,iT)==1;
        if any(id)
            x0 = x(id,iT);
            y0 = y(id,iT);
            idnan = isnan(x0)|isnan(y0);
            nTargets = length(x0(~idnan));
            Dx(iT,1:nTargets) = x0(~idnan);
            Dy(iT,1:nTargets) = y0(~idnan);
            mx(iT) = nanmean(x0);
            my(iT) = nanmean(y0);
        end
    end
    Gxy.x = tsd(t,Dx);
    Gxy.y = tsd(t,Dy);
    Gxy.mx = tsd(t,mx);
    Gxy.my = tsd(t,my);
end

if nargout>3
    Dx = nan(length(t),maxTargets);
    Dy = nan(length(t),maxTargets);
    mx = nan(length(t),1);
    my = nan(length(t),1);
    for iT=1:size(blue,2)
        id = blue(1:maxTargets,iT)==1;
        if any(id)
            x0 = x(id,iT);
            y0 = y(id,iT);
            idnan = isnan(x0)|isnan(y0);
            nTargets = length(x0(~idnan));
            Dx(iT,1:nTargets) = x0(~idnan);
            Dy(iT,1:nTargets) = y0(~idnan);
            mx(iT) = nanmean(x0);
            my(iT) = nanmean(y0);
        end
    end
    Bxy.x = tsd(t,Dx);
    Bxy.y = tsd(t,Dy);
    Bxy.mx = tsd(t,mx);
    Bxy.my = tsd(t,my);
end

if nargout>4
    Dx = nan(length(t),maxTargets);
    Dy = nan(length(t),maxTargets);
    mx = nan(length(t),1);
    my = nan(length(t),1);
    for iT=1:size(intensity,2)
        id = intensity(1:maxTargets,iT)==1;
        if any(id)
            x0 = x(id,iT);
            y0 = y(id,iT);
            idnan = isnan(x0)|isnan(y0);
            nTargets = length(x0(~idnan));
            Dx(iT,1:nTargets) = x0(~idnan);
            Dy(iT,1:nTargets) = y0(~idnan);
            mx(iT) = nanmean(x0);
            my(iT) = nanmean(y0);
        end
    end
    Lumxy.x = tsd(t,Dx);
    Lumxy.y = tsd(t,Dy);
    Lumxy.mx = tsd(t,mx);
    Lumxy.my = tsd(t,my);
end