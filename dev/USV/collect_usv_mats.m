function USV = collect_usv_mats(filter,varargin)
%
%
%
%

fd = pwd;
FrequencyField = 'Binned.F';
PowerField = 'Binned.D';
process_varargin(varargin);

fn = FindFiles(filter);

Freq = [];
Power = [];

if ischar(fd)
    fd = {fd};
end

for d = 1 : length(fd)
    pushdir(fd{d});
    for f = 1 : length(fn)
        [pn,filename] = fileparts(fn{f});

        pushdir(pn);

        usv = load(fn{f});
        ws = fieldnames(usv);
        for o = 1 : length(ws)
            obj = eval(['usv.' ws{o}]);

            for T = 1 : length(obj)
                Fin = eval(['obj(T).' FrequencyField]);
                Pin = eval(['obj(T).' PowerField]);
                nBins = length(Fin);
                extra = (nBins-size(Freq,2));

                if extra>0 & ~isempty(Freq) % there are more bins going in than there were before
                    Freq(1:size(Freq,1)-1,size(Freq,2)+1:size(Freq,2)+extra) = nan;
                    Power(1:size(Power,1)-1,size(Power,2)+1:size(Power,2)+extra) = nan;
                elseif extra<0 & ~isempty(Freq) % there are fewer bins going in than there were before
                    extra = abs(extra);
                    Fin(:, size(Fin,2)+1:size(Fin,2)+extra) = nan;
                    Pin(:, size(Pin,2)+1:size(Pin,2)+extra) = nan;
                end
                Freq = [Freq; Fin];
                Power = [Power; Pin];
            end
        end
        clf
        hold on
        plot(Freq'/1000,Power');
        hold off
        xlabel('kHz')
        ylabel('Power')
        title(filter)
        drawnow
        popdir;
    end
    popdir;
end

USV.F = Freq;
USV.D = Power;