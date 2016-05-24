function process_date_mp4(Sess,varargin)
%
%
%
%

showProgress = false;
process_varargin(varargin);

fn = FindFiles(['*' Sess '*.mp4']);
for f = 1 : length(fn)
    fd{f} = fileparts(fn{f});
end

process_all_mp4('fd',fd,'showProgress',showProgress)