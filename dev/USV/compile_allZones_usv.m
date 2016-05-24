function compile_allZones_usv(varargin)

fd = pwd;
usvDownsample = 30;
Window = 0.6;
ToneDuration = 0.1;
process_varargin(varargin);

if ischar(fd)
    fd{1} = fd;
end

sess = 0;
for d = 1 : length(fd)
    pushdir(fd{d});
    
    sdfn = FindFiles('*-sd.mat');
    for f = 1 : length(sdfn)
        sess = sess+1;
        
        [pn,SSN] = fileparts(sdfn{f});
        SSN = SSN(1:end-3);
        disp(pn);
        pushdir(pn);
        load(sdfn{f});
        
        % idRegret is trials that have regret instance.
        % idNoRegret is trials that have no regret instance.
        
        CSCfn = FindFiles('*CSC*.ncs','CheckSubdirs',0);
        All0 = [];
        kAll = 1;
        if ~isempty(CSCfn)
            CSC = LoadCSC(CSCfn{1});
            Fs = 1./max(diff(CSC.range));
            dt = 1./Fs;
            D = CSC.data;
            T = CSC.range;
            T0 = min(T);
            Di = interp1(T(:),D(:),(T0:dt:max(T))');
            CSC = ctsd(T0,dt,Di(:));
            clear D T T0 Di
            
            fprintf('\nAll entries and exits: %d zones passed.\n',length(sd.EnteringZoneTime))
            tenPercent = ceil(length(sd.EnteringZoneTime)*0.1);
            onePercent = ceil(length(sd.EnteringZoneTime)*0.01);
            
            tsfed = ts(sd.FeederTimes*1e-6);
            freqsAll0 = [];
            All0 = [];
            Spectrum.F = [];
            Spectrum.D = [];
            clear USV
            usv = struct('Signal',tsd([],[]),'Binned',Spectrum);
            USV(length(sd.EnteringZoneTime)) = usv;
            tin = sd.EnteringZoneTime*1e-6+ToneDuration;
            tout = min(tin+Window,sd.ExitZoneTime);
            for iAll = 1 : length(sd.EnteringZoneTime)
                tfed = tsfed.restrict(tin(iAll),tout(iAll));
                if ~isempty(tfed.range)
                    tout(iAll) = min(tfed.range);
                end
            end
            
            t0 = clock;
            for iAllten = 0:ceil(length(sd.EnteringZoneTime)/10)
                start = (iAllten*10)+1;
                finish = min((iAllten*10)+10,length(sd.EnteringZoneTime));
                clear USVten
                usv = struct('Signal',tsd([],[]),'Binned',Spectrum);
                USVten(1:finish-start+1) = usv;
                for iAll = 1 : finish-start+1;
                    t1 = tin(iAll);
                    t2 = tout(iAll);

                    usv = make_usv_struct(t1,t2,CSC,usvDownsample,Frange);
                    USVten(iAll) = usv;
                end
                t = clock;
                elapsed = etime(t,t0);
                remaining = (length(sd.EnteringZoneTime)-finish)*(elapsed/finish);
                fprintf('\n(%.1f%%) %.1fmin elapsed, %.1f remain\n',(finish/length(sd.EnteringZoneTime))*100,elapsed/60,remaining/60);
                USV(start:finish) = USVten;
            end
            s = zeros(1,size(USV(1).Binned.F,2));
            N = 0;
            for iAll = 1 : length(USV)
                s = s+sum(USV(iAll).Binned.D.*USV(iAll).Binned.N);
                N = N+sum(USV(iAll).Binned.N);
            end
            m = s./N;
            clf;colormap('hsv');plot(USV(1).Binned.F'/1000,m','r-','linewidth',2);title(SSN);xlabel('kHz');ylabel('M');drawnow
            
            save([SSN '-usv.mat'],'USV');
            clear USV
        clear CSC
        else
            disp('No USV vocalizations.')
        end
        popdir;
    end
    popdir;
end
% AllZones.Sessions = sessA(:);
% AllZones.Amplitudes = All;
% AllZones.Frequencies = freqsAll;
% [BinCenter,binnedAmplitudes] = binned_USV_amplitude(AllZones.Frequencies,AllZones.Amplitudes);
% AllZones.BinnedF = BinCenter(:);
% AllZones.BinnedA = binnedAmplitudes;
% AllZones.MeanA = nanmean(binnedAmplitudes);
% AllZones.SEMA = nanstderr(binnedAmplitudes);

popdir all;

function usv = make_usv_struct(tin,tout,CSC,usvDownsample,Frange)

CSCall = CSC.restrict(tin,tout);
% Fs = 1./CSCall.dt;
% 
% L = length(CSCall.data);
% NFFT = 2^nextpow2(L);
% Y = fft(CSCall.data,NFFT)/L;
% freq = (Fs/2*linspace(0,1,NFFT/2+1))*usvDownsample;
% A = abs(Y(1:NFFT/2+1));
% A(2:end-1) = A(2:end-1)*2; % Two for positive/negative frequency pairs, one each for DC and Nyquist.

[freq,A]=ez_fft(CSCall);
freq = freq*usvDownsample;
id = freq>=Frange(1) & freq<=Frange(2);
usv.Signal = CSCall;
% usv.Spectrum.F = freq;
% usv.Spectrum.D = A;
[usv.Binned.F,usv.Binned.D,~,usv.Binned.N] = binned_USV_amplitude(freq(id),A(:,id));