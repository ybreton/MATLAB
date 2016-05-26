function [t1,t2] = combineOverlappingWindows(t1,t2)
% Combs through list of t1 and t2 times to identify which windows can be
% combined.
% If:
%   - start time of window A occurs before end time of window B, and
%   - end of time of window A occurs after end of time of window B
% Then combine windows A and B with start time equal to start time of A and
% end time equal to end time of B.
%
% [t1,t2] = combineOverlappingWindows(t1,t2)
%

assert(numel(t1)==numel(t2),'t1 and t2 must have equal numbers of elements.')

t1 = t1(:);
t2 = t2(:);
[t1,I] = sort(t1);
t2 = t2(I);

iArt=1;
while iArt<length(t1)
    k1 = find(t1<t2(iArt)&t1>t1(iArt),1,'first');
    % Find first window start time that occurred 
    % before the current start time ends and 
    % after the current start time began
    k2 = find(t1<t2(iArt)&t1>t1(iArt),1,'last');
    % Find last window start time that occurred
    % before the current start time ends and 
    % after the current start time began
    if ~isempty(k1);
        % If window end time is after the start time of
        % the next window, overlapping:
        % replace the current artifact's end with the next end
        % and remove that next one
        t2(iArt)= max(t2(k2),t2(iArt));
        t1(k1:k2) = [];
        t2(k1:k2) = [];
    else
        % If no window start time occurs between the start and end of the
        % current window, move on to the next window.
        if mod(iArt,100)==1
            fprintf('\n')
        end
        fprintf('.')
        iArt=iArt+1;
    end
end
fprintf('\n')