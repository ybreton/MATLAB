function process_all_mp4(varargin)

fd = cd;
fd = {fd};
showProgress = false;
process_varargin(varargin);

for d = 1 : length(fd)
    pushdir(fd{d});
    fn = FindFiles('FPT-*.mp4');
    fprintf('\n');
    for f = 1 : length(fn)
        fd0 = fileparts(fn{f});
        pushdir(fd0);
        VTmat = FindFiles('*-vt.mat','CheckSubdirs',false);
        RTDmat = FindFiles('*-RatTrackData.mat','CheckSubdirs',false);
        if isempty(VTmat) && isempty(RTDmat)
            fprintf('Extracting position from %s \n',fn{f});
            analyze_VT_movie3(fn{f})
            java.lang.Runtime.getRuntime().gc
        end
        popdir;
    end
    popdir;
end