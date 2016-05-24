function [fGrid,tGrid,aGrid,eGrid] = makeSpectrumGrid(F0,T0,SSN,A,PSD)
%
%
%
%

minF = min(F0);
maxF = max(F0);
F = linspace(min(0,minF),maxF,300)';
LB = F(1:end-1);
UB = F(2:end);
C = LB+(UB-LB)/2;

uniqueT0SSN = unique([SSN T0],'rows');
T = 1:length(uniqueT0SSN);

[fGrid,tGrid] = meshgrid(C,T);
[nr,nc] = size(fGrid);
aGrid = nan(nr,nc);

outArgs = nargout;

if outArgs==3
    for t = 1 : length(T)
        st = uniqueT0SSN(t,:);
        idT = T0==st(2)&SSN==st(1);
        parfor f = 1 : length(LB)
            idF = F0>=LB(f)&F0<UB(f);
            Afts = A(idT&idF);
            aGrid(t,f) = mean(Afts);
        end
    end
end

if outArgs>3 && nargin>4
    eGrid = nan(nr,nc);
    
    for t = 1 : length(T)
        st = uniqueT0SSN(t,:);
        idT = T0==st(2)&SSN==st(1);
        parfor f = 1 : length(LB)
            idF = F0>=LB(f)&F0<UB(f);
            Afts = A(idT&idF);
            Pfts = PSD(idT&idF);
            aGrid(t,f) = mean(Afts);
            Energy = sum(Pfts);
            
            eGrid(t,f) = Energy;
        end
    end
end
