function [th,correct,incorrect,LSE] = RRheaviside(delay,staygo)
% Fit heaviside function of delay to RR stay/go data by least squares
% [th,correct,incorrect,LSE] = RRheaviside(delay,staygo)
% where     th  is the threshold,
%           correct  is the number of accurately predicted choices,
%           incorrect is the number of inaccurately predicted choices,
%           LSE is the least squared deviation of observed from predicted.
%

idnan = isnan(delay)|isnan(staygo);
delay(idnan) = [];
staygo(idnan) = [];
delay = delay(:);
staygo = staygo(:);

uniqueDs = unique(delay(:));

if length(uniqueDs)>1
    width = diff(uniqueDs)/2;
    width = [width(1);width(:)];

    x0list = unique([uniqueDs-width;uniqueDs;uniqueDs+width]);
    SSE = nan(length(x0list),1);
    correct = nan(length(x0list),1);
    incorrect = nan(length(x0list),1);
    for iX = 1 : length(x0list)
        x0 = x0list(iX);
        predY = nan(length(staygo),1);
        predY(delay<x0) = 1;
        predY(delay>x0) = 0;
        predY(delay==x0) = 0.5;

        SSE(iX) = (staygo-predY)'*(staygo-predY);
        correct(iX) = nansum(predY==staygo);
        incorrect(iX) = nansum(predY~=staygo);
    end
    [LSE,idMin]=min(SSE);
    th = x0list(idMin);
    correct = correct(idMin);
    incorrect = incorrect(idMin);
else
    th = nan;
    correct = nan;
    incorrect = nan;
    LSE = inf;
end