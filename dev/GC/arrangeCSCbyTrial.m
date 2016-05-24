function [X,missingCSCs] = arrangeCSCbyTrial(CSCs,T,t0)
% Produces a nCSCs x nTS x nTrials matrix X of the continuously-sampled
% channel signal for Granger causality analyses.
% [X,I] = arrangeCSCbyTrial(CSCs,T,t0)
% where         X           is nCSCs x nTS x nTrials matrix of signal
%                               values
%               I           is nCSCs x 1 x 1 vector of missing CSC signals
% 
%               CSCs        is cell array of length nCSCs with the
%                               continuously-sampled channel values
%               T           is a vector of length nTS with the
%                               trial-aligned time stamps to interpolate
%                               the signals of all CSCs and all trials
%               t0          is a vector of length nTrials with the start
%                               times of each trial event
%
%

CSCs = CSCs(:);
T = T(:);
t0 = t0(:);

window = [min(T) max(T)];
nCSCs = length(CSCs);
nTS = length(T);
nTrials = length(t0);
dT = median(diff(T));

X = nan(nCSCs,nTS,nTrials);
I = false(nCSCs,nTrials);
pct = unique(round(linspace(0,(ceil(nTrials)),11)));
pct = pct(2:end);
disp(['Interpolating ' num2str(nCSCs) ' signals in ' num2str(nTrials) ' trial windows [' num2str(window(1)) ',' num2str(window(2)) '] around event time stamp for ' num2str(nTS) ' time stamps in ' num2str(dT) 'sec increments...'])
for iCSC=1:nCSCs
    disp(['Signal ' num2str(iCSC) ':'])
    if ~isempty(CSCs{iCSC})
        tStart=clock;
        dT = CSCs{iCSC}.dt;
        for iTrl=1:nTrials
            t1 = t0(iTrl)+window(1);
            t2 = t0(iTrl)+window(2);

            t = range(CSCs{iCSC}.restrict(t1-10*dT,t2+10*dT)) - t0(iTrl);
            d = data(CSCs{iCSC}.restrict(t1-10*dT,t2+10*dT));

            if length(d)>2
                t = sort(t);
                [t,idT] = unique(t);
                d = d(idT);
                
                D = interp1(t,d,T);
                X(iCSC,1:length(D),iTrl) = D;
                if any(isnan(D))
                    I(iCSC,iTrl) = true;
                end
            else
                I(iCSC,iTrl) = true;
            end

            fprintf('.')
            if any(pct==iTrl)
                tNow=clock;
                elapsed=etime(tNow,tStart);
                remain = (elapsed/iTrl)*(length(t0)-iTrl);
                percent = round(iTrl/nTrials*100);
                fprintf('\n')
                fprintf('%d%% complete. %.1fsec remain.',percent,remain)
                fprintf('\n')
            end
        end
    else
        disp('CSC missing.')
        I(iCSC,:) = true;
    end
    fprintf('\n')
end
missingCSCs = all(I,2);
disp(['Excluded ' num2str(sum(missingCSCs)) ' bad CSCs.'])
X = X(~missingCSCs,:,:);
I = I(~missingCSCs,:);

I = any(I,1);
disp(['Excluded ' num2str(sum(I)) ' bad trials.'])
X = X(:,:,~I);