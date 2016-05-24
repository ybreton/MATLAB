function step_through_csc_fts(varargin)
%
%
%
%

process_varargin(varargin)

fn = FindFiles('*CSC*.ncs');
for f = 1 : length(fn)
    pn=fileparts(fn{f});
    pushdir(pn);
    
    CSC = LoadCSC(fn{f});
    CSC = ctsd(max(CSC.range),min(diff(CSC.range)),CSC.data);
    Fs = 1./CSC.dt;
    L = length(CSC.data);
    NFFT = 2^nextpow2(L);
    Y = fft(CSC.data,NFFT)/L;
    freq = (Fs/2*linspace(0,1,NFFT/2+1))*30;
    A = 2*abs(Y(1:NFFT/2+1));
    
    clf
    title(pn)
    hold on
    plot(freq/1000,A)
    set(gca,'xlim',[10 100])
    hold off
    pause;
    
    popdir;
end