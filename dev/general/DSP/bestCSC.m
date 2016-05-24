function CSCbest = bestCSC(cscs, lo, hi, varargin)
% Finds the csc with the highest power in the frequency band [lo,hi).
% CSCbest = bestCSC(cscs, lo, hi)
% where     CSCbest     is the filname of the best csc,
%
%           cscs        is a cell array of CSC file names,
%           lo          is the lower bound of the frequency band
%           hi          is the upper bound of the frequency band
%
debug=false;
process_varargin(varargin);

pow = nan(length(cscs),1);

if debug
    Flo = 0:2:500;
    Fhi = [Flo(2:end) inf];
    Fbin = nanmean([Flo;Fhi],1);
    Fbin(end) = -inf;
    Pall = nan(length(cscs),length(Fbin));
end

for icsc=1:length(cscs)
    fd = fileparts(cscs{icsc});
    pushdir(fd);
    keysFn = FindFiles('*_keys.m');
    if ~isempty(keysFn)
        fn=keysFn{end};
        [~,fn] = fileparts(fn);
        eval(fn);
        
        TimeOnTrack = ExpKeys.TimeOnTrack;
        TimeOffTrack = ExpKeys.TimeOffTrack;
    else
        TimeOnTrack = -inf;
        TimeOffTrack = inf;
    end
    popdir;
    
    disp(cscs{icsc});
    csc = LoadCSC(cscs{icsc});
    
    csc = csc.restrict(TimeOnTrack, TimeOffTrack);
    csc = tsd(csc.range,nanzscore(csc.data));
    csc = ctsd(min(csc.range),csc.dt,csc.data);
    disp('psd...')
    psd = ez_psd(csc);
    Pxx = psd.data;
    Fxx = psd.freq;
    
    if debug
        Fbin(end) = max(Fbin(end),1/csc.dt/2);
        for ibin=1:length(Flo)
            Pall(icsc,ibin) = nanmean(Pxx(Fxx>=Flo(ibin)&Fxx<Fhi(ibin)));
        end
    end
    
    flo = repmat(lo(:)',[length(Fxx) 1]);
    fhi = repmat(hi(:)',[length(Fxx) 1]);
    F = repmat(Fxx(:),[1 length(lo)]);
    
    I = F>=flo & F<fhi;
    id = any(I,2);
    pow(icsc) = nansum(Pxx(id));
end
[m,I] = max(pow);
txt = sprintf('[%.0f, %.0f)Hz, ',lo,hi);
txt = txt(1:end-2);
fprintf('Maximum total power in frequency band %s: %.3f\n', txt, m);
CSCbest = cscs{I};

if debug
    indices = 1:length(cscs);
    P = Pall(I,:);
    Pothers = Pall(indices(indices~=I),:);
    
    clf
    subplot(2,1,1)
    hold on
    plot(Fbin,log10(P),'b-','linewidth',2);
    plot(Fbin,log10(Pothers),'r-','linewidth',1);
    xlabel('Frequency')
    ylabel('Log_{10}[Power]')
    title(fn)
    hold off
    subplot(2,1,2)
    hold on
    plot(log10(Fbin),log10(P),'b-','linewidth',2);
    plot(log10(Fbin),log10(Pothers),'r-','linewidth',1);
    xlabel('Log_{10}[Frequency]')
    ylabel('Log_{10}[Power]')
    hold off
    drawnow;
end