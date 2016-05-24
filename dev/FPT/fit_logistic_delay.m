function stats = fit_logistic_delay(sessions, delays, choices, varargin)
% Produces a structure array "stats" with the statistics of a logistic
% regression of choice for the delayed side as a function of the log-delay.
% stats = fit_logistic_delay(sessions, delays, choices, varargin)
% where     stats is a session-by-subject output structure array with
%           fields
%               .rational : logical for subject in session has decreasing
%                           preference for delayed side when the delayed side is
%                           increased and choses either side more than 10% of the time.
%               .beta     : vector of intercept and slope of logistic
%                           regression Y = 1./(1+e^-Z); Z = [1 X] * [intercept;slope].
%               .threshold: threshold delay producing equi-preference
%                           between delay and non-delayed sides.
%               .t        : t-statistic associated with betas.
%               .dfe      : degrees of freedom for error.
%               .p        : probability of observing t statistics assuming
%                           the null hypothesis (intercept and slope are 0) is true in
%                           a t distribution with dfe degrees of freedom.
%               .Rsq      : pseudo-R^2 statistic, taking deviance of a null
%                           model (with only intercept) as total sum of squares and the
%                           deviance of the full model (intercept/slope) as the
%                           residual. As SS_T = SS_A + SS_resid, R^2 =
%                           (SS_T-SS_resid)/SS_T.
% and
%           sessions is a vector of session numbers (empty for 1 sessions),
%           delays is a vector of encountered delays,
%           choices is a logical vector of when the subject chose the
%               delayed/non-delayed side.
% OPTIONAL:
%           'subjects'      : vector of subject numbers (default is ones(length(sessions),1).
%           'logTransformX' : perform the regression on log10(delay) rather
%                             than delay (default is true).
%           'minY'          : minimum percentage of choices to either side.
%                             Any less than minY choices left or right are not "rational".
%                             (default is 0.1).
%

logTransformX = true;
minY = 0.1;
subjects = ones(length(sessions),1);
process_varargin(varargin);

if isempty(sessions)
    sessions = ones(length(delays),1);
    subjects = ones(length(delays),1);
end

subjects = subjects(:);
sessions = sessions(:);
delays = delays(:);
choices = choices(:);
uniqueSubj = unique(subjects);
for subj = 1 : length(uniqueSubj)
    idSubj = uniqueSubj(subj)==subjects;
    sessions0 = sessions(idSubj);
    
    uniqueSess = unique(sessions0);
    cmap = hsv(length(uniqueSess)+2);
    cmap = cmap(2:end-1,:);
    legendStr = cell(1,length(uniqueSess));
    if length(uniqueSubj)>1
        subplot(m,n,subj)
        hold on
        title(sprintf('S %d',uniqueSubj(subj)))
        hold off
    end
    for s = 1 : length(uniqueSess)
        idx = sessions == uniqueSess(s) & idSubj;

        X = delays(idx);
        rng = [min(X) max(X)];
        Y = logical(choices(idx));
        if logTransformX
            X = log10(X);
            [ph(s),eh] = plot_grouped_Y(10.^X,Y,'dist','binomial');
        else
            plot_grouped_Y(X,Y);
        end
        clear out
        hold on
        xlabel('Delay')
        ylabel('Proportion laps delay side chosen')
        set(ph,'color',cmap(s,:))
        set(eh,'color',cmap(s,:))
        legendStr{s} = sprintf('Sess %d',uniqueSess(s));

        if sum(double(Y))/length(Y)<0.1 | sum(double(~Y))/length(Y)<0.1
            % Chose exclusively one side
            out.rational = false;
            Rsq = 0;
            if logTransformX
                plot(10.^X,ones(length(X),1)*sum(double(Y))/length(Y),':','color',cmap(s,:))
            else
                plot(X,ones(length(X),1)*sum(double(Y))/length(Y),':','color',cmap(s,:))
            end
            out.threshold = inf;
        else
            [beta,SSresid,stat]=glmfit(X,Y,'binomial');
            [beta0,SStotal,stat0]=glmfit(ones(length(X),1),Y,'binomial','constant','off');
            Rsq = (SStotal-SSresid)/SStotal;
            if logTransformX & beta(2)<0
                plot(10.^unique(X),glmval(beta,unique(X),'logit'),'-','color',cmap(s,:))
            elseif beta(2)<0
                plot(X,glmval(beta,unique(X),'logit'),'-','color',cmap(s,:))
            end
            if logTransformX & beta(2)>=0
                plot(10.^unique(X),glmval(beta,unique(X),'logit'),':','color',cmap(s,:))
            elseif beta(2)>=0
                plot(X,glmval(beta,unique(X),'logit'),':','color',cmap(s,:))
            end
        end
        out.beta = beta;
        % 0 = -z0 = -(beta(1)+beta(2)*x0)
        % 0 = -beta(1) -beta(2)*x0
        % beta(1)/(-beta(2)) = x0.
        out.threshold = out.beta(1)./(-out.beta(2));
        if logTransformX
            out.threshold = 10.^(out.threshold);
        end
        if beta(2)<0 & out.threshold>=rng(1) & out.threshold<=rng(2)
            out.rational = true;
        else
            out.rational = false;
        end
        out.t = stat.t;
        out.p = stat.p;
        out.dfe = stat.dfe;
        out.Rsq = Rsq;
        hold off
        stats(s,subj) = out;
    end
    legend(ph,legendStr)
end