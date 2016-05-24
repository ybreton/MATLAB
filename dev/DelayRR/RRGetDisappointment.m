function [Disapp,sdOut] = RRGetDisappointment(sd)
% Returns a structure array with logical fields indicating disappointment
% control conditions.
% Disapp1:
% shouldskip(t-1)==1 && staygo(t-1)==0 && shouldskip(t)==1
%
% Disapp2:
% shouldstay(t-1)==1 && staygo(t-1)==1 && shouldskip(t)==1
%
% [Disapp]    = RRGetDisappointment(sd)
% [Disapp,sd] = RRGetDisappointment(sd)
% where     Disapp      is a structure array with fields
%                   .Disapp1
%                   .Disapp2
%                           nSubsess x nTrials matrices of disappointment
%                           control conditions.
%
%           sd          is a standard session data structure.
%
%

shouldskip = RRIdentifyShouldSkip(sd);
shouldstay = RRIdentifyShouldStay(sd);
staygo = RRGetStaygo(sd);

Disapp1 = nan(length(sd),size(staygo,2));
Disapp2 = nan(length(sd),size(staygo,2));

for iSubsess = 1 : length(sd)
    Disapp1(iSubsess,2:end) = shouldskip(1:end-1)==1&staygo(1:end-1)==0&shouldskip(2:end);
    Disapp2(iSubsess,2:end) = shouldstay(1:end-1)==1&staygo(1:end-1)==1&shouldskip(2:end);
    if nargout>1
        sd0 = sd(iSubsess);
        sd0.Disapp1 = Disapp1(iSubsess,:);
        sd0.Disapp2 = Disapp2(iSubsess,:);
        sdOut(iSubsess) = sd0;
        clear sd0
    end
end
Disapp.Disapp1 = Disapp1;
Disapp.Disapp2 = Disapp2;