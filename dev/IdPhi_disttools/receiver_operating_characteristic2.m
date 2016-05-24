function [ROC,fh] = receiver_operating_characteristic2(Theta,varargin)
% Calculates a receiver operating characteristic and plots its curve,
% assuming distributions are gaussian.
% [ROC,fh] = receiver_operating_characteristic(Theta,varargin)
% where
%           ROC is the receiver operating characteristic
%           fh is a handle to the ROC curve
%           Theta is a matrix with entries [tau;mu;sigma] for each gaussian
%               component
% varargin  nCriteria, number of criteria to evaluate for ROC (default 1e6)
%           rangeOfCriteria, range of criteria to evaluate for ROC (default [0 10])
%

% number of criteria to evaluate.
nCriteria = 1e6;
% range of criteria to evaluate.
rangeOfCriteria = [0 10];
process_varargin(varargin);
rangeOfCriteria = sort(rangeOfCriteria);

% Theta is assumed to be in the form [tau;mu;sigma] for each component i.

[~,jComponent] = max(Theta(2,:));

components = 1 : size(Theta,2);
comparisonDists = components~=jComponent;
criteria = linspace(rangeOfCriteria(1),rangeOfCriteria(2),nCriteria)';
FP = zeros(nCriteria,1);
% TP = 1-Theta(1,jComponent)*normcdf(criteria,Theta(2,jComponent),Theta(3,jComponent));
TP = 1-normcdf(criteria,Theta(2,jComponent),Theta(3,jComponent));
parfor iCrit = 1 : nCriteria
    crit = criteria(iCrit);
    FP(iCrit) = mixSurvFunc(Theta(:,comparisonDists),crit);
end
[FP,idx] = sort(FP);
TP = TP(idx);

% BTP = TP*tau(j)/(TP+FP)
% BFP = FP*tau(i~=j)/(TP+FP)
BTP = TP*Theta(1,jComponent)./(TP+FP);
BFP = FP*sum(Theta(1,comparisonDists))./(TP+FP);
BTP(isnan(BTP)) = 0;
BFP(isnan(BFP)) = 0;

% The area between the curve designated by TP and FP is the ROC.
% If TP=FP, lies on the curve and ROC=0.
% If TP>FP, lies above the curve and ROC>0.
% If TP<FP, lies below the curve and ROC<0.
d = BTP(:) - BFP(:);
w = zeros(length(BFP),1);
w(1) = BFP(2)-BFP(1);
parfor iCrit = 2 : length(BFP)-1
    up = (BFP(iCrit+1) - BFP(iCrit))/2;
    down = (BFP(iCrit) - BFP(iCrit-1))/2;
    w(iCrit) = up+down;
end
w(end) = BFP(end)-BFP(end-1);
% Each rectange has width w and height d. The area is the sum of these tiny
% rectangles.
ROC = sum(d.*w);

clf
fh = gcf;
set(fh,'position',[1975 533 1182 420])
subplot(1,2,1)
axis square
set(gca,'xlim',[0 1])
set(gca,'ylim',[0 1])
title('Receiver Operating Characteristic Curve')
hold on
ph(1)=plot(BFP,BTP,'k-');
ph(2)=plot(BFP,BFP,'r:');
legendStr = {'ROC' 'H_0'};
lh=legend(ph,legendStr);
set(get(lh,'title'),'string',sprintf('AUC=%0.4f',ROC+.50))
set(lh,'location','southeast')
set(lh,'edgecolor',[1 1 1])
xlabel(sprintf('P[ Log[ I d\\phi ]~Non-VTE Distributions | Log [ I d\\phi ]>criterion ]\n(P[False Positive Posterior])'))
ylabel(sprintf('P[ Log[ I d\\phi ]~VTE Distribution | Log[ I d\\phi ]>criterion ]\n(P[True Positive Posterior])'))
hold off
subplot(1,2,2)
hold on
compDens = mixDensFunc(Theta(:,comparisonDists),criteria);
compDens = compDens/max(compDens)*sum(Theta(1,comparisonDists));
VTEdens = normpdf(criteria,Theta(2,jComponent),Theta(3,jComponent))/(normpdf(Theta(2,jComponent),Theta(2,jComponent),Theta(3,jComponent)))*Theta(1,jComponent);
ph=plot(criteria,compDens,'r-');
ph(2)=plot(criteria,VTEdens,'k-');
legendStr = {'No-VTE Dists' 'VTE Distribution'};
lh=legend(ph,legendStr);
set(lh,'location','northeast')
set(lh,'edgecolor',[1 1 1])
xlabel(sprintf('Log [ I d\\phi ]'))
ylabel(sprintf('Normalized Probability Density'))
hold off


function survivor = mixSurvFunc(Theta,LogIdPhi)

s = zeros(length(LogIdPhi),size(Theta,2));
for iComponent = 1 : size(Theta,2)
    s(:,iComponent) = 1-normcdf(LogIdPhi,Theta(2,iComponent),Theta(3,iComponent));
end
survivor = (s*(Theta(1,:))')/sum(Theta(1,:));


function density = mixDensFunc(Theta,LogIdPhi)

d = zeros(length(LogIdPhi),size(Theta,2));
for iComponent = 1 : size(Theta,2)
    d(:,iComponent) = normpdf(LogIdPhi,Theta(2,iComponent),Theta(3,iComponent));
end
md = (d*(Theta(1,:))');
density = md;