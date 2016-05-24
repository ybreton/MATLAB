function TTs = RRassignTetrodes(sd,varargin)
% Provides the tetrode number for each fn in sd.fn.
%
% TTs = RRassignTetrodes(sd)
% where     TTs     is n x 1 vector of tetrode numbers.
% 
%           sd      is a standard session data structure.
%
% OPTIONAL ARGUMENTS:
% ******************
% fn        (default sd.fn)     is the list of file names to assign
%                                   tetrodes.
% TTstr     (default '-TT')     is a string that specifies the prefix to
%                                   the tetrode number
% CLUdelim  (default '-')       is a string that specifies the delimiter
%                                   between the tetrode number and the
%                                   cluster number.
%
% Notes:
% Support function that indicates the tetrode number that corresponds to
% each sd.fn file name. Assumes file names have SSN-{TTstr}##{CLUdelim}##
% format, like SSN-TT##-## (e.g., R279-2014-01-10-TT01-01 for
% R279-2014-01-10, Tetrode 1, Cluster 1).
%
TTstr = '-TT';
CLUdelim = '-';
fn = sd.fn;
process_varargin(varargin);

TTs = nan(1,length(fn));
for iClu = 1 : length(fn)
    str = fn{iClu};
    idTT = regexpi(str,[TTstr '[0-9]']);
    TT_CLU = str(idTT+length(TTstr):end);
    idCLU = regexpi(TT_CLU,CLUdelim);
    TTs(iClu) = str2double(TT_CLU(1:idCLU-1));
end