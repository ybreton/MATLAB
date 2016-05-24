function MATLAB_LED_TRACK(varargin)
%
%
%
%

trackHead = false;
replace = true;
excludeFilter = cell(0,1);
includeFilter = '*.mpg';
process_varargin(varargin);
getOrientation = trackHead;
if ischar(excludeFilter)
    excludeFilter = {excludeFilter};
end

mpegFn = FindFiles(includeFilter);
inc = true(length(mpegFn),1);
for f = 1 : length(mpegFn)
    fn = mpegFn{f};
    excl = 1;
    while excl<=length(excludeFilter) & inc(f)
        filter = excludeFilter{excl};
        if ~isempty(regexp(fn,filter))
            inc(f) = false;
        end
        excl = excl+1;
    end
end
mpegFn = mpegFn(inc);

for f = 1 : length(mpegFn)
    [pathname,fn,ext] = fileparts(mpegFn{f});
    s = dir(mpegFn{f});
    if s.bytes>eps
        pushdir(pathname);

        rtfn = FindFiles([fn '-RatTrackData.mat'],'CheckSubDirs',false);
        if isempty(rtfn) | replace

            analyze_VT_movie3([fn ext],'getOrientation',getOrientation)
            load([fn '-RatTrackData.mat'],'RatTrackData')
            RatTrack(f) = RatTrackData;
            clear RatTrackData
        else

            fprintf('\nRat tracking for %s already produced.\n',mpegFn{f})

        end
        popdir;
    else
        fprintf('\n %s is empty.\n',mpegFn{f})
    end
end
