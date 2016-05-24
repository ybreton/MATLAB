function ph = RRPlotChoice(delays,staygo,varargin)
% Plots choices and sigmoid.
% ph = RRPlotChoice(delays,staygo)
% where     ph  is 3x1 vector of plot handles for
%                   ph(1) P[Stay]
%                   ph(2) Sigmoid fit
%                   ph(3) Threshold value
%           delays is n x 1 vector of delays
%           staygo is n x 1 vector of stay (1) or go (0)
% OPTIONAL:
% ah        (default gca)   axes handle to place plot
% fh        (default gcf)   figure handle to place plot

fh = gcf;
ah = gca;
process_varargin(varargin);

set(0,'currentfigure',fh);
set(fh,'currentaxes',ah);

[th,b] = RRthreshold(delays(:),staygo(:));

uniqueDs = unique(delays(:));
m = nan(length(uniqueDs),1);
for iD = 1 : length(uniqueDs)
    idxDelay = uniqueDs(iD)==delays;
    m(iD) = nanmean(staygo(idxDelay));
end
ph = nan(3,1);
hold on
ph(1) = plot(uniqueDs,m,'ko');
ph(2) = plot(uniqueDs,glmval(b(:),uniqueDs,'logit'),'k-');
ph(3) = plot(th,0.5,'xk');
hold off
xlabel(sprintf('Delay (s)'));
ylabel(sprintf('P[Stay]'));