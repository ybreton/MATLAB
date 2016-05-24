function tab = struc2tab(s,fields,varargin)
%
%
%
%
reserved = {'dimNames' 'dimLevels' 'dimNumeric'};
process_varargin(varargin);

if nargin<2
    fields = sort(fieldnames(s));
end
fields = fields(~ismember(fields,reserved));

k=1;
for iF=1:length(fields)
    fname = fields{iF};
    if isstruct(s.(fname))
        bools = fieldnames(s.(fname));
        for ibool=1:length(bools)
            bname = bools{ibool};
            tab.Header{1,k} = [fname '_' bname];
            dat{k} = s.(fname).(bname)(:);
            k = k+1;
        end
    else
        dat{k} = s.(fname)(:);
        tab.Header{1,k} = fname;
        k = k+1;
    end
end

n = cellfun(@length,dat);
cel = cellfun(@iscell,dat);

if any(cel)
    tab.Data = cell(max(n),length(tab.Header));
    for iK=1:length(dat)
        d = dat{iK};
        for iR=1:n(iK)
            if isnumeric(d) || islogical(d)
                tab.Data{iR,iK} = d(iR);
            else
                tab.Data{iR,iK} = d{iR};
            end
        end
    end
else
    tab.Data = nan(max(n),length(tab.Header));
    for iK=1:length(dat)
        d = dat{iK};
        tab.Data(1:n(iK),iK) = d;
    end
end
end
