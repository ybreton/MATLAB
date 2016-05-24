function [] = FPTPromote(varargin)
%% 2011-02-14 AEP
% This function promotes one (D)elay (D)iscounting session.
CreateKeys = 1;
Blocks = [];
Nudges = [];
Weight = [];
PostFeed = [];
Notes = '';
SkipNotes = false;
process_varargin(varargin);

SSN = GetSSN('SingleSession');
fVT1 = strcat(SSN, '-vt.mat');

mpegs = FindFiles('*.mpg','CheckSubdirs',0);
for f = 1 : length(mpegs)
    [pathname,filename,ext] = fileparts(mpegs{f});
    smis = FindFiles([filename '.smi'],'CheckSubdirs',0);
    if ~isempty(smis)
        if f==1
            str = sprintf('!rename %s %s',[filename '.mpg'],sprintf('%s-VT1.mpg',SSN));
            eval(str);
            str = sprintf('!rename %s %s',[filename '.smi'],sprintf('%s-VT1.smi',SSN));
            eval(str);
%             movefile([filename '.mpg'],sprintf('%s-VT1.mpg',SSN))
%             movefile([filename '.smi'],sprintf('%s-VT1.smi',SSN))
        else
            str = sprintf('!rename %s %s',[filename '.mpg'],sprintf('%s-VT1_%02d.mpg',SSN,f));
            eval(str);
            str = sprintf('!rename %s %s',[filename '.smi'],sprintf('%s-VT1_%02d.smi',SSN,f));
            eval(str);
%             movefile([filename '.mpg'],sprintf('%s-VT1_%02d.mpg',SSN,f))
%             movefile([filename '.smi'],sprintf('%s-VT1_%02d.smi',SSN,f))
        end
    end
end

mpgfn = FindFiles('*-VT1*.mpg','CheckSubdirs',0);
if ~isempty(mpgfn)
    rtdfn = FindFiles('*-RatTrackData.mat','CheckSubdirs',0);
    if isempty(rtdfn)
        fprintf('\nAnalyzing %s.\n',mpgfn{1})
        
        analyze_VT_movie3(mpgfn{1})
        rtdfn = FindFiles('*-RatTrackData.mat','CheckSubdirs',0);
    end
    fprintf('\nPulling rat tracking from %s.\n',rtdfn{1})
    load(rtdfn{1})
    x = tsd(Hx.T,Hx.D);
    y = tsd(Hy.T,Hy.D);
else
    mp4fn = FindFiles('FPT-video-*.mp4','CheckSubdirs',0);
    rtdfn = FindFiles('*-RatTrackData.mat','CheckSubdirs',0);
    if isempty(rtdfn)
        fprintf('\nAnalyzing %s.\n',mp4fn{1})
        analyze_VT_movie3(mp4fn{1})
        rtdfn = FindFiles('*-RatTrackData.mat','CheckSubdirs',0);
    end
    fprintf('\nPulling rat tracking from %s.\n',rtdfn{1})
    load(rtdfn{1})
    x = tsd(Hx.T,Hx.D);
    y = tsd(Hy.T,Hy.D);
end
format bank
TOnT = min(x.range);
TOffT = max(x.range);
save(fVT1, 'x', 'y');

RenameFiles;
%% Create Keys file
if CreateKeys == 1;
    load(strcat(SSN,'-DD.mat'))
    CreateFPTKeys(TOnT, TOffT, 'Blocks', Blocks, 'Nudges', Nudges, 'Weight', Weight, 'PostFeed', PostFeed, 'Notes', Notes, 'SkipNotes', SkipNotes);
end
