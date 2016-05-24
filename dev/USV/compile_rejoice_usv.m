function compile_rejoice_usv(varargin)

fd = pwd;
usvDownsample = 30;
window = 0.9;
Frange = [10*1000 70*1000];
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
        load(sdfn{f});
        
        [idRejoice,idNoRejoice] = find_RR_instances(sd,'rejoice');
        
        RejoiceTimes = sd.EnteringZoneTime(idRejoice)*multiplier;
        NoRejoiceTimes = sd.EnteringZoneTime(idNoRejoice)*multiplier;
        
        CSCfn = FindFiles('*CSC*.ncs','CheckSubdirs',0);
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
            
            fprintf('\n %d rejoice instances.\n',length(RejoiceTimes))
            for iRegret = 1 : length(RejoiceTimes)
                CSCregret = CSC.restrict(RejoiceTimes(iRegret),RejoiceTimes(iRegret)+window);
                
% %                 Fs = 1./CSCregret.dt;
%                 L = length(CSCregret.data);
%                 NFFT = 2^nextpow2(L);
%                 Y = fft(CSCregret.data,NFFT)/L;
%                 freq = (Fs/2*linspace(0,1,NFFT/2+1))*usvDownsample;
%                 A = abs(Y(1:NFFT/2+1));
%                 A(2:end-1) = A(2:end-1)*2; % there are two of each f-component except the DC and Nyquist F
                [freq,A] = ez_fft(CSCregret);
                
%                 if length(A)>size(Regret0,2)
%                     extras = length(A)-size(Regret0,2);
%                     Regret0(1:kR-1,size(Regret0,2)+1:size(Regret0,2)+extras) = nan;
%                 elseif length(A)<size(Regret0,2)
%                     extras = size(Regret0,2)-length(A);
%                     A(length(A)+1:length(A)+extras) = nan;
%                 end
%                 
%                 Regret0(kR,1:length(A)) = A(:)';
%                 
%                 freqsR0(kR,1:length(freq)) = freq;
%                 sessR(kR) = sess;
%                 kR = kR + 1;
                freq = freq*usvDownsample;
                id = freq>=Frange(1) & freq<=Frange(2);
                fprintf('.')
                if mod(iRegret,10)==0
                    fprintf('\n')
                end
                usv.Signal = CSCregret;
                usv.Spectrum.F = freq(id);
                usv.Spectrum.D = A(:,id);
                [usv.Binned.F,usv.Binned.D,~,usv.Binned.N] = binned_USV_amplitude(freq(id),A(:,id));
                rejoiceUSV(iRegret) = usv;
                clear CSCregret usv
            end
            save([SSN '-rejoiceUSV.mat'],'rejoiceUSV')
            clear regretUSV
%             [BinCenter,binnedAmplitudes] = binned_USV_amplitude(freqsR0,Regret0);
%             subplot(2,1,1);colormap('hsv');plot(BinCenter(:)/1000,binnedAmplitudes');title(sprintf('%s',SSN));set(gca,'ylim',[0 1024]);set(gca,'xtick',[0:10:200]);xlabel('kHz');ylabel('FFT');drawnow; % for debug.
            
            fprintf('\n %d non-rejoice instances.\n',length(NoRejoiceTimes))
            for iNoRegret = 1 : length(NoRejoiceTimes)
                CSCnoregret = CSC.restrict(NoRejoiceTimes(iNoRegret),NoRejoiceTimes(iNoRegret)+window);
                
%                 Fs = 1./CSCnoregret.dt;
%                 L = length(CSCnoregret.data);
%                 NFFT = 2^nextpow2(L);
%                 Y = fft(CSCnoregret.data,NFFT)/L;
%                 freq = (Fs/2*linspace(0,1,NFFT/2+1))*usvDownsample;
%                 A = abs(Y(1:NFFT/2+1));
%                 A(2:end-1) = A(2:end-1)*2; % Two for positive/negative frequency pairs, one each for DC and Nyquist.

                [freq,A] = ez_fft(CSCnoregret);
%                 if length(A)>size(NoRegret0,2)
%                     extras = length(A)-size(NoRegret0,2);
%                     NoRegret0(1:kR-1,size(NoRegret0,2)+1:size(NoRegret0,2)+extras) = nan;
%                 elseif length(A)<size(NoRegret0,2)
%                     extras = size(NoRegret0,2)-length(A);
%                     A(length(A)+1:length(A)+extras) = nan;
%                 end
%                 
%                 NoRegret0(kNR,1:length(A)) = A(:)';
%                 freqsNR0(kNR,1:length(freq)) = freq;
%                 sessNR(kNR) = sess;
%                 kNR = kNR + 1;
                freq = freq*usvDownsample;
                id = freq>=Frange(1) & freq<=Frange(2);
                fprintf('.')
                if mod(iNoRegret,10)==0
                    fprintf('\n')
                end
                
                usv.Signal = CSCnoregret;
                usv.Spectrum.F = freq(id);
                usv.Spectrum.D = A(:,id);
                [usv.Binned.F,usv.Binned.D,~,usv.Binned.N] = binned_USV_amplitude(freq(id),A(:,id));
                norejoiceUSV(iNoRegret) = usv;
                
                clear CSCnoregret usv
            end
            save([SSN '-norejoiceUSV.mat'],'norejoiceUSV')
%             [BinCenter,binnedAmplitudes] = binned_USV_amplitude(freqsNR0,NoRegret0);
%             subplot(2,1,2);colormap('hsv');plot(BinCenter(:)/1000,binnedAmplitudes');set(gca,'ylim',[0 1024]);set(gca,'xtick',[0:10:200]);xlabel('kHz');ylabel('FFT');drawnow; % for debug.
        clear CSC
        fprintf('\n')
        else
            disp('No USV vocalizations.')
        end
        popdir;
    end
    popdir;
end

popdir all;