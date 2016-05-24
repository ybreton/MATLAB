function compile_stayskip_usv(varargin)
fd = pwd;
usvDownsample = 30;
window = 0.9;
multiplier = 1e-6;
process_varargin(varargin);

if ischar(fd)
    fd{1} = fd;
end

% kR = 1;
% kNR = 1;
% kAll = 1;
% Regret0 = [];
% NoRegret0 = [];
% All0 = [];
% sess = 0;
for d = 1 : length(fd)
    pushdir(fd{d});
    
    sdfn = FindFiles('*-sd.mat');
    for f = 1 : length(sdfn)
%         sess = sess+1;
        [pn,SSN] = fileparts(sdfn{f});
        SSN = SSN(1:end-3);
        disp(pn);
        pushdir(pn);
        
        CSCfn = FindFiles('*CSC*.ncs','CheckSubdirs',0);
        if ~isempty(CSCfn)
            load(sdfn{f});
            in = sd.EnteringZoneTime(:)*multiplier;
            out = sd.ExitZoneTime(:)*multiplier;
            Ntrials = min(length(in),length(out));
            delay = sd.ZoneDelay(:);
            spent = out-in;
            stay = spent(1:Ntrials)>=delay(1:Ntrials);
            
            CSC = LoadCSC(CSCfn{1});
            Fs = 1./max(diff(CSC.range));
            dt = 1./Fs;
            D = CSC.data;
            T = CSC.range;
            T0 = min(T);
            Di = interp1(T(:),D(:),(T0:dt:max(T))');
            CSC = ctsd(T0,dt,Di(:));
            clear D T T0 Di
            
            kSkip = 1;
            kStay = 1;
            t1 = clock;
            for iTrial = 1 : Ntrials
                CSC0 = CSC.restrict(in(iTrial),in(iTrial)+window);
%                 L = length(CSC0.data);
%                 NFFT = 2^nextpow2(L);
%                 Y = fft(CSC0.data,NFFT)/L;
%                 freq = (Fs/2*linspace(0,1,NFFT/2+1))*usvDownsample;
%                 A = abs(Y(1:NFFT/2+1));
%                 A(2:end-1) = A(2:end-1)*2;

                [freq,A]=ez_fft(CSC0);
                freq = freq*usvDownsample;
                usv.Signal = CSC0;
                usv.Spectrum.F = freq;
                usv.Spectrum.D = A;
                [usv.Binned.F,usv.Binned.D,~,usv.Binned.N] = binned_USV_amplitude(freq,A);
                
                if stay(iTrial)
                	stayUSV(kStay) = usv;
                    kStay = kStay + 1;
                    fprintf('o')
                else
                    skipUSV(kSkip) = usv;
                    kSkip = kSkip + 1;
                    fprintf('x')
                end
                
                if mod(iTrial,10)==0
                    t2 = clock;
                    elapsed = etime(t2,t1);
                    tper = elapsed/iTrial;
                    remaining = (Ntrials-iTrial)*tper;
                    fprintf('\n')
                    fprintf('(%.1f%%) %.1fmin elapsed, %.1fmin remain.',iTrial/Ntrials*100,elapsed/60,remaining/60)
                    fprintf('\n')
                end
                
                clear CSC0 usv
            end
            save([SSN '-stayUSV.mat'],'stayUSV');
            save([SSN '-skipUSV.mat'],'skipUSV');
        end
        popdir;
    end
    popdir;
end