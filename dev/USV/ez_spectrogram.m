function [S,ph] = ez_spectrogram(signalCTSD,window,varargin)
%
%
%
%
Hamming = true;
Padding = true;
start = min(signalCTSD.range);
finish = max(signalCTSD.range);
usvDownsample = 30;
process_varargin(varargin);

dt = signalCTSD.dt;

if nargin<2
    window = 4*dt;
end

L = ceil(window/dt);
NFFT = 2^nextpow2(L);
nT = ceil((finish-start-window)/dt);
S.F = nan(NFFT/2+1,nT);
S.T = nan(NFFT/2+1,nT);
S.TimeBin = nan(NFFT/2+1,nT);
S.D = nan(NFFT/2+1,nT);
S.window = window;
S.dt = dt;
k = 1;
onePercent = ceil(nT/100);
tenPercent = ceil(nT/10);
fprintf('\n')
t1 = clock;
for t = start+window/2:dt:finish-window/2
    subSignal = signalCTSD.restrict(t-window/2,t+window/2);
    [F,P] = ez_fft(subSignal,[],'Hamming',Hamming,'Padding','Padding');
    F = F*usvDownsample;
    S.F(:,k) = F(:);
    S.D(:,k) = P(:);
    S.T(:,k) = t;
    S.TimeBin(:,k) = t-start;
    if mod(k,onePercent)==0
        fprintf('.')
    end
    if mod(k,tenPercent)==0
        t2 = clock;
        elapsed = etime(t2,t1);
        remaining = (nT-k)*(elapsed/k);
        fprintf('\n')
        fprintf('(%.1f%%) %.1fs elapsed, %.1fs remain.',k/nT*100,elapsed,remaining)
        fprintf('\n')
    end
    k = k+1;
end

if nargout>1
    ph=imagesc(S.T(1,:),S.F(:,1),S.D);
    axis xy
end
