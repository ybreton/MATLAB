function cscFn = maxCSCpower(cscList,lo,hi,varargin)
% For each CSC filename in the list, finds the psd in the frequency band
% between lo and hi, averaging in frequency bins of 0.25s (configurable).
% The area under the curve between averaged psd and the PSD at lo 
% defines the size of the "bump" in the 1/f relationship of the psd in the
% lo-to-hi band. Returns the name of the csc with the largest bump.

psdFreqStep = 0.25;
debug=false;
maxF = 250;
detrend = true;
window = 1;
winstep = 0.5;
ch = get(0,'Children');
if isempty(ch); fh=1; else fh=max(ch)+1; end
process_varargin(varargin);

empty = cellfun(@isempty,cscList);
cscList = cscList(~empty);
p = nan(length(cscList),1); % mean summed psd in freq range

if detrend
    Fpsd = 1/window:psdFreqStep:2*hi;
else
    Fpsd = psdFreqStep:psdFreqStep:2*hi;
end

idBand=(Fpsd>=lo&Fpsd<=hi);
Z = nan(length(Fpsd),length(cscList));
t1=clock;
for iFn=1:length(cscList)
    disp(cscList{iFn});
    csc = LoadCSC(cscList{iFn});
    if detrend
        csc = tsd(csc.range,locdetrend(csc.data,1/csc.dt,[window winstep]));
    end
    
    Fs = 1/csc.dt;
    Fnew = 2*maxF;
    factor = ceil(Fs/Fnew);
    csc = CSC_downsample(csc,'factor',factor);
    psdObj = ez_psd(csc);
    psdx = psdObj.data;
    f = psdObj.freq;
    
    pSmooth = nan(length(Fpsd),1);
    parfor iBin=1:length(Fpsd)-1
        idx = f>=Fpsd(iBin)&f<Fpsd(iBin+1);
        if any(idx)
            pSmooth(iBin) = nanmean(psdx(idx));
        end
    end
%     fLo = max(Fpsd(Fpsd<lo));
%     pLo = pSmooth(Fpsd==fLo);
    pLo = min(pSmooth(Fpsd>0&Fpsd<lo));
    t2=clock;
    elapsed=etime(t2,t1);
    remain = (elapsed/iFn)*(length(cscList)-iFn);
    disp([num2str(elapsed) 'sec elapsed. ' num2str(remain) 'sec (' num2str(remain/60) 'min) remain.']);
    
    p0 = 10*log10(pSmooth)-10*log10(pLo);
    p(iFn) = max(p0(idBand));
    
    Z(:,iFn) = p0;
end

[maxP,idxP] = max(p);

if debug
    figure(fh);
    clf
    set(gca,'fontsize',18)
    hold on
    ph=plot(Fpsd,Z);
    e = max(max(abs(Z(Fpsd>=lo&Fpsd<hi,:))));
    ShadedErrorbar([lo hi],[0 0],[e e]);
    cmap=get(ph(idxP),'color');
    plot(Fpsd,Z(:,idxP),'color',cmap,'linewidth',2);
    legendStr = cell(length(cscList),1);
    for iStr=1:length(cscList)
        [~,legendStr{iStr}] = fileparts(cscList{iStr});
    end
    legend(ph,legendStr)
    xlabel(sprintf('Frequency\n(%.3fHz bins)',psdFreqStep))
    ylabel(sprintf('Power spectral density - PSD min (dB/Hz)\n(bin mean)'))
    hold off
    drawnow
end

cscFn = cscList{idxP};

disp(['Max power spectral density is ' num2str(maxP) 'dB above largest trough on ' cscFn '.'])