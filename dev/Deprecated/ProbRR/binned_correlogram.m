function [Z,C] = binned_correlogram(ST,F,PSD,varargin)
%
%
%
%

numBins = 300;
process_varargin(varargin);

Fmin = min(F);
Fmax = max(F);
dF = (Fmax-Fmin)/numBins;
Flist = linspace(Fmin,Fmax+dF,numBins+1);
LB = Flist(1:end-1);
UB = Flist(2:end);
C = LB+(UB-LB)/2;

st = unique(ST,'rows');

Z = nan(length(C));
S = ST(:,1);
T = ST(:,2);
sess = st(:,1);
trial = st(:,2);

P = nan(size(st,1),length(C));
parfor r = 1 : size(st,1)
    idT = S==sess(r)&T==trial(r);
    f = F(idT);
    psd = PSD(idT);
    row = nan(1,length(C));
    for c = 1 : length(C);
        idF = f>=LB(c) & f<UB(c);
        row(c) = sum(psd(idF));
    end
    P(r,:) = row;
end
for c1 = 1 : length(C)
    for c2 = c1 : length(C)
        r = corrcoef(P(:,c1),P(:,c2));
        Z(c1,c2) = r(2);
        Z(c2,c1) = r(2);
    end
end


hold on
imagesc(C,C,Z)
set(gca,'xlim',[min(C) max(C)])
set(gca,'ylim',[min(C) max(C)])
ch=colorbar;
set(get(ch,'ylabel'),'string','Correlation')
set(get(ch,'ylabel'),'rotation',-90)
caxis([-1 1])
hold off

