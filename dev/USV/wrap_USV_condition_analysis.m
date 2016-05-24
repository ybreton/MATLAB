function AllUSV = wrap_USV_condition_analysis(filter,USVobj,fField,pField,varargin)

fd=pwd;
ToneDuration = 0.2;
Window = 0.9;
process_varargin(varargin);
if ischar(fd)
    fd = {fd};
end

% for d = 1 : length(fd)
%     pushdir(fd{d});
%     fn = FindFiles(filter);
%     for f = 1 : length(fn)
%         pn = fileparts(fn{f});
%         pushdir(pn);
% 
%         load(fn{f})
%         eval([USVobj '= usv_tone_subtraction(' USVobj ',''ToneDuration'',ToneDuration,''Window'',Window)']);
%         save(fn{f},USVobj,'-append')
%         popdir;
%     end
%     popdir;
% end
fField = 'Binned.F';
pField = 'Binned.D';
AllUSV = collect_usv_mats(filter,'fd',fd,'FrequencyField',fField,'PowerField',pField);