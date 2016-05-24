function sd = FPTbackpack(sd)
% Adds field BPx and BPy for backpack location as tracked by Cheetah.
%
%
%

nvtfn = FindFiles('*.nvt','CheckSubdirs',false);
smifn = FindFiles('*.smi','CheckSubdirs',false);
fptfn = FindFiles('FPT-tracking-*.txt','CheckSubdirs',false);
if isempty(nvtfn)&&isempty(fptfn);
    zipfn = FindFiles('*.zip');
    contentsPre = FindFiles('*.*','CheckSubdirs',false);
    unzipped = true;
    for iZ=1:length(zipfn);
        disp(['Unzipping ' zipfn{iZ}])
        unzip(zipfn{iZ});
    end
    contentsPost = FindFiles('*.*','CheckSubdirs',false);
    nvtfn = FindFiles('*.nvt','CheckSubdirs',false);
    smifn = FindFiles('*.smi','CheckSubdirs',false);
    fptfn = FindFiles('FPT-tracking-*.txt','CheckSubdirs',false);
    if ~isempty(nvtfn) && ~isempty(smifn);
        [sd.BPx,sd.BPy]=LoadVT_lumrg(nvtfn{1});
        [NVTts,MOVts] = get_smi_ts(smifn{1});
        % MOVts(1) -> smits(1), MOVts(2)->smits(2), etc.
        xD = sd.BPx.data(NVTts);
        yD = sd.BPy.data(NVTts);
        sd.BPx = tsd(MOVts,xD);
        sd.BPy = tsd(MOVts,yD);
    elseif ~isempty(fptfn)
        [sd.BPx,sd.BPy]=LoadFPT_tracking(fptfn{1});
    else
        sd.BPx = tsd([],[]);
        sd.BPy = tsd([],[]);
    end
    
    contentsZip = contentsPost(~ismember(contentsPost,contentsPre));
    for iC=1:length(contentsZip)
        disp(['Cleaning up ' contentsZip{iC}])
        delete(contentsZip{iC});
    end
else
    if ~isempty(nvtfn) && ~isempty(smifn);
        [sd.BPx,sd.BPy]=LoadVT_lumrg(nvtfn{1});
        [NVTts,MOVts] = get_smi_ts(smifn{1});
        % MOVts(1) -> smits(1), MOVts(2)->smits(2), etc.
        xD = sd.BPx.data(NVTts);
        yD = sd.BPy.data(NVTts);
        sd.BPx = tsd(MOVts,xD);
        sd.BPy = tsd(MOVts,yD);
    elseif ~isempty(fptfn)
        [sd.BPx,sd.BPy]=LoadFPT_tracking(fptfn{1});
    else
        sd.BPx = tsd([],[]);
        sd.BPy = tsd([],[]);
    end
end