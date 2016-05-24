classdef timedProgressBar
% Progress bar wrapper that includes estimated time to completion.
% barHandle = timedProgressBar(txt,maxval)
% where     barHandle       is a structure with fields
%                   .t1     start time of progress bar
%                   .t2     current time of progress bar
%                   .idx    current idx of progress bar
%                   .max    maximum idx of progress bar
%                   .txt    progress bar text
%                   .WindowHandle    
%                           handle to wait bar window
%                           (NaN if window has been closed)
%                   .isclosed
%                           logical indicating whether progress bar window
%                           is closed
%
%           txt             is a string with text for progress bar,
%           maxval          is a scalar with the maximum idx of progress
%                           bar.
%
% Methods:
% barHandle.update()
%       updates the progress bar with idx = idx+1
% barHandle.update(idx)
%       updates the progress bar with cutom idx.
% barHandle.close()
%       closes the progress bar.
%
%
% Example:
% The following code snippet will update the progress bar on every
% iteration of the simulation loop, indicating to the user when the
% set of simulations is expected to finish assuming the average future rate
% is equal to the average rate of computation up to now. When the final
% simulation update occurs, the update function will automatically close
% the wait bar window. If that has not happened, we can force closing after
% the loop has completed.
% 
% ... barHandle = timeProgressBar('Simulating',10000);
% ... for simulation = 1 : 10000
% ...     sim(simulation) = simulate(params);
% ...     barHandle = barHandle.update();
% ... end
% ... barHandle.close();
% 
%
% REVISION HISTORY:
% ****************
% 2016-05-16    (YAB)       made timedProgressBar a full object class with
%                           methods
%
properties
    t1 = [];
    t2 = [];
    idx = [];
    max = [];
    txt = [];
    WindowHandle = [];
    isclosed = [];

end
methods 
    function barHandle = timedProgressBar(txt,maxval)
        barHandle.t1 = clock;
        barHandle.t2 = clock;
        barHandle.idx = 0;
        barHandle.max = maxval;
        barHandle.txt = txt;

        barHandle.WindowHandle = waitbar(0,sprintf('%s\n ',txt));
        barHandle.isclosed = false;
    end
    function barHandle = update(barHandle,idx)
        barHandle.isclosed = isnan(barHandle.WindowHandle);

        if ~barHandle.isclosed
            if nargin<2
                idx = barHandle.idx+1;
            end
            barHandle.idx = idx;

            barHandle.t2 = clock;
            x = barHandle.idx/barHandle.max;
            wbh = barHandle.WindowHandle;
            txt = barHandle.txt;

            e = etime(barHandle.t2,barHandle.t1);
            remaining = (barHandle.max/barHandle.idx - 1)*e;
            dfrac = remaining/(60*60*24); % fraction of a day
            if dfrac>1
                days = floor(dfrac);
                dfrac= dfrac-days;
                if days>1
                    timeStr = sprintf('%.0f days, %s',days,datestr(dfrac,'HH:MM'));
                else
                    timeStr = sprintf('%.0f day, %s',days,datestr(dfrac,'HH:MM'));
                end
                scaleTxt = 'min';
            elseif dfrac>1/24
                timeStr = datestr(dfrac,'HH:MM');
                scaleTxt = 'min';
            elseif dfrac>1/(24*60)
                timeStr = datestr(dfrac,'MM:SS');
                scaleTxt = 'sec';
            else
                timeStr = datestr(dfrac,'MM:SS.FFF');
                scaleTxt = 'sec';
            end

            txt = sprintf('%s (%.1f%%)\n%.0f remain, %s%s',txt,(barHandle.idx/barHandle.max)*100,barHandle.max-barHandle.idx,timeStr,scaleTxt);
            try
                waitbar(x,wbh,txt);
            catch exception
                barHandle.isclosed = true;
            end
        end

        if ~barHandle.isclosed
            if barHandle.idx/barHandle.max>=1-eps;
                barHandle.close();
            end
        end
    end

    function barHandle = close(barHandle)
        wbh = barHandle.WindowHandle;
        txt = barHandle.txt;
        x = barHandle.idx/barHandle.max;
        if ~barHandle.isclosed
            try
                waitbar(x,wbh,sprintf('%s\nComplete.',txt));
                delete(barHandle.WindowHandle);
            end
        end
        barHandle.WindowHandle = nan;
        barHandle.isclosed = true;
    end
end

end