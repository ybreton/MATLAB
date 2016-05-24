function AllSessions = wrap_RR_collectSess(fd,varargin)
% Wrapper to collect all sessions of restaurant row in a structure array.
% AllSessions = wrap_RR_collectSess(fd)
% where     AllSessions         is 1 x nSessions structure with field sd
%                                   containing nSubsess x 1 sd data.
%
%           fd                  is nSessions x 1 cell array of file
%                                   directories to init
% OPTIONAL ARGUMENTS:
% ******************
% VTEtime   (default 3)         seconds to do LogIdPhi and zIdPhi.
% forceInit (default false)     forces RRInit even if sd file exists.

forceInit = false;
VTEtime = 3;
process_varargin(varargin);

for d = 1 : length(fd)
    pushdir(fd{d});
    disp(fd{d});
%     if forceInit
        sd = RRInit;
%     else
%         sdfn = FindFiles('*-sd.mat','Checksubdirs',false);
%         if isempty(sdfn)
%             sd = RRInit;
%         else
%             for f = 1 : length(sdfn)
%                 load(sdfn{f});
%             end
%         end
%     end
    
        
    sess0 = wrap_RR_session(sd,'VTEtime',VTEtime);
    
    AllSessions(d).sd = sess0;
    
    popdir;
end