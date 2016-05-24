function [params,LnL] = fit_DD_mountain(Laps,nPellets,Delays,Choices,A0,D0)
% Laps: lap number
% nPellets: pellet ratio
% Delays: last delay chosen
% Choices: delay side chosen
% A0: amount nondelayed side
% D0: delay nondelayed side
if nargin < 6
    D0 = 1;
end
if nargin < 5
    A0 = 1;
end
OPTIONS = optimset('display','off','algorithm','interior-point');
Logparams = fminsearch(@(Logparams) errfun(Laps,nPellets,Delays,Choices,A0,D0,Logparams),[1 0],OPTIONS);
LnL = errfun(Laps,nPellets,Delays,Choices,A0,D0,Logparams);
params = 10.^Logparams;
plot_mountainDD(Laps,nPellets,Delays,Choices,A0,D0,params);

function nLnL = errfun(Laps,nPellets,Delays,Choices,A0,D0,Logparams)
params = 10.^Logparams;
P = DD_mountain(params,Laps,nPellets,Delays,A0,D0);
L = nan(length(P),1);
idx1 = Choices==1;
idx0 = Choices==0;
L(idx1) = P(idx1);
L(idx0) = 1-P(idx0);
LnL = log(L);
sLnL = sum(LnL);
nLnL = -sLnL;
% 
% cla
% title(sprintf('%.1f',nLnL))
% plot_mountainDD(Laps,nPellets,Delays,Choices,A0,D0,params)
% drawnow


function P = DD_mountain(params,Laps,nPellets,Delays,A0,D0)
beta = params(1);
disc = params(2);

A1 = nPellets(:,1);
D1 = Delays(:,1);


U1 = A1./(1+disc*D1);
U0 = A0./(1+disc*D0);

P = U1.^beta./(U1.^beta+U0.^beta);



function plot_mountainDD(Laps,nPellets,Delays,Choices,A0,D0,params)

uniqueXY = unique([nPellets Delays],'rows');
Y = (uniqueXY(:,1));
X = (uniqueXY(:,2));
hold on
view(45,30)
for iXY = 1 : size(uniqueXY,1)
    nP = uniqueXY(iXY,1);
    D = uniqueXY(iXY,2);
    idx = nPellets==nP&Delays==D;
    [m,lb,ub] = binocis(sum(double(Choices(idx)==1)),sum(double(Choices(idx)==0)),1,0.05);
    predM = DD_mountain(params,Laps,nP,D,A0,D0);
    ph=plot3(X(iXY),Y(iXY),m,'ro','markerfacecolor','r');
    plot3([X(iXY) X(iXY)],[Y(iXY) Y(iXY)],[lb ub],'r-','linewidth',3)
    plot3([X(iXY) X(iXY)],[Y(iXY) Y(iXY)],[m predM],'k:','linewidth',2);
end
[gridY,gridX] = meshgrid(unique(Y),unique(X));
Z = DD_mountain(params,Laps,gridY(:),gridX(:),A0,D0);
gridZ = reshape(Z,size(gridY));
sh=surf(gridX,gridY,gridZ);
set(sh,'facealpha',0.1)
ylabel(sprintf('Amount'));
xlabel(sprintf('Delay'));
zlabel(sprintf('P[Choose Delay]'));
set(gca,'zlim',[-0.05 1.05])
set(gca,'ylim',[0 5])
set(gca,'xlim',[1 30])
set(gca,'xscale','log')
set(gca,'yscale','log')

legendStr{1} = sprintf('Choice,\n(\\pm 95%% CI)');
legendStr{2} = sprintf('Inverse temp:%.3f\nDiscount rate:%.3f',params(1),params(2));
legend([ph sh],legendStr)

hold off
