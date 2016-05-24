function tso = placeFieldXYtsd(s,pf,varargin)
% Constructs a structure array with tsd's of place field data pf
% corresponding to spike times in s, as well as tsd's of cell IDs.
% tso = placeFieldXYtsd(s,pf)
% where     tso         is a structure with fields
%               .(fname)...
%                       with the tsd of the value of field fname in pf time
%                       stamped with the times the cell for that value
%                       fired
%               .cellnum
%                       with the tsd of the cell ID in s time stamped with
%                       its spike times
%
%           s           a nCell x 1 cell array of spike time ts arrays
%           pf          a nCell x 1 structure array of place field
%                       information
%
% OPTIONAL ARGUMENTS:
% ******************
% fname     (default: 'Centroid')
%   field name for which to assemble the tsd.
%
% Example:
% s is a 29 x 1 cell array of spike ts
% sd is a standard session data structure
% pf = placeField(s,sd.x,sd.y)
%
% >> tso = placeFieldXYtsd(s,pf)
% tso.Centroid.x, tsd with spike times and centroid x location of
%                   associated place field
% tso.Centroid.y, tsd with spike times and centroid y location of
%                   associated place field
% tso.cellnum, tsd with spike times and cell ID such that 
%                   tso.cellnum.data = I at spike time s{I}.data
%

fname = 'Centroid';
process_varargin(varargin);

if ~iscell(s)
    s = {s};
end

% Each entry of nCell x 1 pf corresponds to an entry of nCell x 1 s.
% The data for cell iC is in pf(iC).(fname).(a)...
% The time stamps for cell iC are in s{iC}
% The full field name of tso is (a)...
field = parseField(s,pf,fname);
tso.(fname) = field;
% Add a field for cell ID as a tsd
t = [];
d = [];
for iC=1:length(s)
    t = cat(1,t,s{iC}.data);
    d = cat(1,d,ones(length(s{iC}.data),1)*iC);
end
[t,I]=sort(t);
d = d(I);
tso.cellnum = tsd(t,d);

function field = parseField(spikes,sa,fname)
if isstruct(sa(1).(fname))
    fnames = fieldnames(sa(1).(fname));
    for iF=1:length(fnames)
        for iC=1:length(sa)
            sa0(iC) = sa(iC).(fname);
        end
        field.(fnames{iF}) = parseField(spikes,sa0,fnames{iF});
    end
else
    disp(fname);
    
    nC = length(sa);
    sz = [-inf -inf];
    for iC=1:nC
        sz0 = size(sa(iC).(fname));
        sz = [sz;
              sz0];
        sz = max(sz,[],1);
    end
    sz = [1 sz];
    t = [];
    d = nan([0 sz(2:end)]);
    for iC=1:length(sa)
        fprintf('.')
        nt = length(spikes{iC}.data);
        t = cat(1,t,spikes{iC}.data);
        d1 = nan(sz);
        % d1 is 1 x A x B x ... x C
        
        sz0 = [1 size(sa(iC).(fname))];
        d0 = reshape(sa(iC).(fname),[1 sz0]);
        % d0 has been reshaped to  1 x n x m x ... x p
        str = '(1,';
        for idim=2:length(sz0)
            % for each dimension of dat, 
            % set d1(...,1:sz0(idim),...) = d0
            str = [str '1:' num2str(sz0(idim)) ','];
        end
        for xdim=length(sz0)+1:length(sz);
            str = [str '1,'];
        end
        str = str(1:end-1);
        str = [str ')'];
        eval(['d1' str '=d0;']);
        
        dN = repmat(d1,[nt ones(1,length(sz))]);
        
        d = cat(1,d,dN);
    end
    fprintf('\n')
    [t,I] = sort(t);
    d = d(I,:);
    field = tsd(t,d);
end