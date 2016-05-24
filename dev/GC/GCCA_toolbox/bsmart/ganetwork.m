function ganetwork(Fxy,Fyx,location,thre,time,fre1,fre2,chan)
% GANETWORK Analysis and visualization of the Granger causality network
% 
% Syntax:
%   ganetwork(Fxy,Fyx,location,thre,time,fre1,fre2,chan)
% 
% Input(s):
%   Fxy,Fyx     - Granger causality 
%   location    - Location of the sites
%   thre        - Threshold
%   time        - Specify the window number
%   fre1        - Starting frequency
%   fre2        - Ending frequency
%   chan        - Channels of interest
% 
% Example:
%   ganetwork(Fxy,Fyx,location,0.18,5,1,50,[9 10 11]);
% 
% See also: conetwork, mov_bi_ga, one_bi_ga.

% Copyright (c) 2006-2007 BSMART Group
% by Richard Cui
% $Revision: 0.2$ $Date: 14-Sep-2007 10:38:30$
% SHIS UT-Houston, Houston, TX 77030, USA.
%
% Lei Xu, Hualou Liang

% parameter settings
t  = time;
x1 = fre1;
x2 = fre2;
dat  = Fxy;
dat2 = Fyx;
dat3 = location;
s1   = size(dat);

% error checking
if ( x1>s1(2) )
    errordlg('please input correct start frequency','parameter lost');
    return
end
if ( x2>s1(2) )
    errordlg('please input correct end frequency','parameter lost');
    return
end
if(ndims(dat)>2)
    if ( t>s1(3) )
        errordlg('please input correct window','parameter lost');
        return
    end
end
if(ndims(dat)==2)
    if ( t~=1 )
        errordlg('please input correct window','parameter lost');
        return
    end
end

% find channel numbers
N = s1(1);
channel = (1+sqrt(1+8*N))/2;    % k = (1+sqrt(1+8N))/2, N = number of pairs of coherence

label = cell(1,channel);
for i = 1:channel
    label(1,i)={num2str(i)};
end

circle = zeros(channel,1);

dag  = zeros(channel,channel);
dag2 = dag;
left = dat3(1,:);
right = dat3(2,:);
data  = squeeze(dat(:,:,t))';
data2 = squeeze(dat2(:,:,t))';
xlabel = x1:x2;
for i = 1:N
    peak=fpeak(xlabel,data(xlabel,i),30,[x1,x2,0,1]);
    sizep=size(peak);
    if sizep(1)>=1
        for pi=1:sizep(1)
            if peak(pi,2)>thre
                kk=i;
                m=channel-1;
                while kk>0
                    kk=kk-m;
                    m=m-1;
                end
                ii=channel-1-m;
                jj=ii+kk+m+1;
                dag(ii,jj)=1;
            end
        end
    end
end
for i = 1:N
    peak=fpeak(xlabel,data2(xlabel,i),30,[x1,x2,0,1]);
    sizep=size(peak);
    if sizep(1)>=1
        for pi=1:sizep(1)
            if peak(pi,2)>thre
                kk=i;
                m=channel-1;
                while kk>0
                    kk=kk-m;
                    m=m-1;
                end
                ii=channel-1-m;
                jj=ii+kk+m+1;
                dag(jj,ii)=1;
            end
        end
    end
end
% set channels of interets
tp = true(1,channel);
tp(chan) = false;
chanary = 1:channel;
notchan = chanary(tp);
circle(chan) = 1; 
dag(notchan,:) = 0;
dag(:,notchan) = 0;
% plot figure
figure('Name','Granger Causality Network','NumberTitle','off')
draw_layout(dag,label,circle,left,right,'gc');
tstr = sprintf('Window: %d, Frequency: %.0f - %.0f Bins, Threshold: %.2f',time,fre1,fre2,thre);
title(tstr);

% if no peak is found
if dag==dag2
    for i=1:N
        for j=x1:x2
            if data(j,i)>thre
                kk=i;
                m=channel-1;
                while kk>0
                    kk=kk-m;
                    m=m-1;
                end
                ii=channel-1-m;
                jj=ii+kk+m+1;
                dag(ii,jj)=1;
            end
        end
    end
    for i=1:N
        for j=x1:x2
            if data2(j,i)>thre
                kk=i;
                m=channel-1;
                while kk>0
                    kk=kk-m;
                    m=m-1;
                end
                ii=channel-1-m;
                jj=ii+kk+m+1;
                dag(jj,ii)=1;
            end
        end
    end
    % set channels of interets
    tp = true(1,channel);
    tp(chan) = false;
    chanary = 1:channel;
    notchan = chanary(tp);
    circle(chan) = 1;
    dag(notchan,:) = 0;
    dag(:,notchan) = 0;
    % plot figure
    figure('Name','Granger Causality Network','NumberTitle','off')
    draw_layout(dag,label,circle,left,right,'gc');
    tstr = sprintf('No peak found. Window: %d, Frequency: %.0f - %.0f Bins, Threshold: %.2f',time,fre1,fre2,thre);
    title(tstr);
end

end%fucntion

% [EOF]