function spectrograph_usv(filter,varargin)
%
%
%
%

if nargin<1
    filter = '-USV';
end
fd = pwd;
window = 1;
timebin = 0.01;
FbinSize = 1000;
usvDownsample = 30;
process_varargin(varargin);

if ischar(fd)
    fd = {fd};
end

ts = 0 : timebin : ceil(window/timebin)*timebin-timebin;
nBins = length(ts);
spectrumS = nan(nBins,500);
spectrumN = nan(nBins,500);
spectrumF = nan(nBins,500);

for d = 1 : length(fd)
    pushdir(fd{d});
    
    fn = FindFiles([filter '*.mat']);
    for f = 1 : length(fn)
        pn = fileparts(fn{f});
        
        pushdir(pn);
        
        USV0 = load(fn{f});
        obj = fieldnames(USV0);
        
        for o = 1 : length(obj)
            USV = eval(['USV0.' obj{o}]);
            
            for T = 1 : length(USV)
                usv = USV(T);
                
                signal = usv.Signal;
                t1 = min(signal.range);
                signal = signal.restrict(t1,t1+window);
                
                dt = signal.dt;
                Fs = 1/dt;
                tsBin = 1;
                for t = 0 : timebin : ceil(window/timebin)*timebin-timebin
                    t2 = t1+t+timebin;
                    
                    y = signal.restrict(t1+t,t2);
                    L = length(y.data);
                    NFFT = 2^nextpow2(L);
                    
                    Y = fft(y.data,NFFT)/L;
                    Y = Y(:)';
                    F = (Fs/2)*linspace(0,1,NFFT/2+1)*usvDownsample;
                    Ymag = abs(Y(1:NFFT/2+1));
                    
                    [BinCenter,~,binnedSums,binnedNs] = binned_USV_amplitude(F,Ymag,'binSize',FbinSize);
                    
                    spectrumS(tsBin,1:size(binnedSums,2)) = binnedSums;
                    spectrumN(tsBin,1:size(binnedNs,2)) = binnedNs;
                    spectrumF(tsBin,1:size(BinCenter,2)) = BinCenter;
                    tsBin = tsBin+1;
                end
                F = [];
                for t = 1 : size(spectrumS,1)
                    idnan = isnan(spectrumF(t,:));
                    F0 = spectrumF(t,~idnan);
                    if length(F0)>length(F)
                        F = F0;
                        nCol = length(F);
                    end
                end
                idnan = isnan(spectrumF(:,1));
                nRow = length(spectrumF(~idnan,1));
                
                clf
                imagesc(ts,F/1000,spectrumS(1:nRow,1:nCol)'./spectrumN(1:nRow,1:nCol)')
                axis xy
                xlabel('Time since zone entry')
                ylabel('kHz')
                set(gca,'ylim',[10 70])
                colorbar
                drawnow
            end
        end
        
        popdir;
    end
    
    popdir;
end