function s0 = strucdim2fielddim(s,varargin)
% Convert structure dimensions to field dimensions
%
% s0 = strucdim2fielddim(s)
% where         s0          is a 1 x 1 structure array with fields
%                 .(field)  is a M x N x ... x P  x  A x B x ... C field
%
%               s           is a M x N x ... x P structure array with
%                           fields
%                 .(field)  is a A x B x ... x C field
%
%   Converts a (m x n x ... x p) structure array 
%   with fields that are (a x b x ... x c)
%   into a 1x1 structure array with fields that are
%   (m x n x ... x p   x   a x b x ... x c)
%
% OPTIONAL ARGUMENTS:
% ******************
% fields        (default: all fields in s)
%   Cell array of the fields to extract from s. Default extracts all
%   fields.
%
%

fields = fieldnames(s(1));
process_varargin(varargin);

fields = fields(:);
sz = size(s);

for iF=1:length(fields)
    if isstruct(s(1).(fields{iF}))
        disp([fields{iF} ' is a structure array field...'])
        clear s1
        for iS=1:numel(s)
            s1(iS) = s(iS).(fields{iF});
        end
        s0.(fields{iF})=strucdim2fielddim(s1);
    else
        disp([fields{iF} ' is a valid array field...'])
        fz0 = -inf(1,2);
        for iS=1:numel(s)
            fz = size(s(iS).(fields{iF}));
            for iDim=1:length(fz)
                if length(fz0)>=length(fz)
                    fz0(iDim) = max(fz0(iDim),fz(iDim));
                else
                    fz0(iDim) = fz(iDim);
                end
            end
        end
        % fz0 is now the largest field size necessary; which means sz0 will
        % be [sz fz0]:
        sz0 = [sz fz0];
        
        if ~iscell(s(1).(fields{iF}));
            v = nan(sz0);
            v = reshape(v,[prod(sz) prod(fz0)]);
            for iS=1:numel(s)
                x = nan(fz0);
                fz = size(s(iS).(fields{iF}));

                str = sprintf('1:%.0f,',fz);
                str = str(1:end-1);
                eval(['x (' str ') = s(iS).(fields{iF});']);
                v(iS,:) = x(:);
            end
        else
            v = cell(sz0);
            v = reshape(v,[prod(sz) prod(fz0)]);
            for iS=1:numel(s)
                x = cell(fz0);
                fz = size(s(iS).(fields{iF}));

                str = sprintf('1:%.0f,',fz);
                str2= '';
                for iExDim=1:length(fz)-length(sz0)
                    str2 = [str2 ':,'];
                end
                str = [str str2];
                str = str(1:end-1);
                eval(['x (' str ') = s(iS).(fields{iF});']);
                v(iS,:) = x(:);
            end
        end
        v = reshape(v,sz0);
        
        s0.(fields{iF}) = v;
    end
end