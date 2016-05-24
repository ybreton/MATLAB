function [isError,isCorrect] = RRDecisionInstability(sd)
% produces isError, isCorrect.
% VEH = RRDecisionInstability(VEH)
% where     isError             is nSubsess x nTrials matrix of error (skipped
%                                   when shouldstay or stayed when
%                                   shouldskip)
%           isCorrect           is nSubsess x nTrials matrix of correct
%                                   (skipped when shouldskip or stayed when
%                                   shouldstay).
%           sd                  is nSubsess x 1 structure of sd.
%
%

[ShouldStay,ShouldGo] = RRIdentifyShouldStayGo(sd);
StayGo = RRGetStaygo(sd);

idError = (StayGo==0&ShouldStay==1)|(StayGo==1&ShouldSkip==1);
idCorrect = (StayGo==0&ShouldSkip==1)|(StayGo==1&ShouldStay==1);

isError = nan(size(VEH.staygo));
isCorrect = nan(size(VEH.staygo));

isError(idError) = 1;
isCorrect(idError) = 0;
isError(idCorrect) = 0;
isCorrect(idCorrect) = 1;