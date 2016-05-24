function [isError,isCorrect,sd] = RRDecisionInstability(sd)
% produces isError, isCorrect.
% [isError,isCorrect] = RRDecisionInstability(sd)
% where     isError             is nSubsess x nTrials matrix of error (skipped
%                                   when shouldstay or stayed when
%                                   shouldskip)
%           isCorrect           is nSubsess x nTrials matrix of correct
%                                   (skipped when shouldskip or stayed when
%                                   shouldstay).
%           if sd output is specified, will add fields isError and isCorrect to each subsession.
%
%           sd                  is nSubsess x 1 structure of sd.
%
%

ShouldSkip = RRIdentifyShouldSkip(sd);
ShouldStay = RRIdentifyShouldStay(sd);
stayGo = RRGetStaygo(sd);

idError = (stayGo==0&ShouldStay==1)|(stayGo==1&ShouldSkip==1);
idCorrect = (stayGo==0&ShouldSkip==1)|(stayGo==1&ShouldStay==1);

isError = nan(size(stayGo));
isCorrect = nan(size(stayGo));

isError(idError) = 1;
isCorrect(idError) = 0;
isError(idCorrect) = 0;
isCorrect(idCorrect) = 1;

if nargout>1
    for s = 1 : numel(sd)
        sd0 = sd(s);
        sd0.isError = isError(s,:);
        sd0.isCorrect = isCorrect(s,:);
        sdOut(s) = sd0;
    end
end