% Rat SSN Weight Blocks Nudges PostFeed Notes
% ToPromote={
%     'R262' 'R262-2012-12-21' 264.0 11 12 0 ''
% };
fn=uigetfile('*.csv','CSV of cycle-3 aging rat/SSN/Weight/Block/Nudge/PostFeed/Notes');
ascii = import_ascii_text(fn);
ToPromote = cell(numel(ascii),7);
for r = 1 : numel(ascii)
    rowStr = ascii{r};
    delim = regexpi(rowStr,',');
    delim = [0 delim length(rowStr)+1];
    for c = 2 : length(delim)
        contents = rowStr(delim(c-1)+1:delim(c)-1);
        ToPromote{r,c-1} = contents;
    end
end
notProcessed = cell(0,0);
curDir = cd;
fprintf('\n')
for d = 1 : size(ToPromote,1)
    Rat = ToPromote{d,1};
    SSN = ToPromote{d,2};
    Weight = str2double(ToPromote{d,3});
    Blocks = str2double(ToPromote{d,4});
    Nudges = str2double(ToPromote{d,5});
    PostFeed = str2double(ToPromote{d,6});
    if isempty(ToPromote{d,7})
        Notes = '';
    else
        Notes = ToPromote{d,7};
    end
    
    % If doesn't exist as a session, can't promote.
    canPromote = isdir([curDir '\' Rat '\' SSN]);
    if canPromote

        % If already promoted, no need to promote.
        promoted = isdir(['\\adrlab15\db\DataInProcess\' Rat '\' SSN]);
%         if ~promoted
            try
                cd([curDir '\' Rat '\' SSN])
                fprintf('Promoting %s to the database.\n',SSN)
                FPTPromote('Blocks',Blocks,'Weight',Weight,'Nudges',Nudges,'PostFeed',PostFeed,'SkipNotes',true,'Notes',Notes);
                FN{1} = FindFiles('*_keys.m','CheckSubdirs',0);
                FN{2} = FindFiles('*-DD.mat','CheckSubdirs',0);
                FN{3} = FindFiles('*-Events.Nev','CheckSubdirs',0);
                FN{4} = FindFiles('*-vt.mat','CheckSubdirs',0);
                FN{5} = FindFiles('*-VT1.zip','CheckSubdirs',0);
                FN{6} = FindFiles('FPT-tracking-*.txt','CheckSubdirs',0);
                for f = 1 : 5
                    fn = FN{f};
                    if ~isempty(fn)
                        [pathname,filename,ext]=fileparts(fn{1});
                        destination = ['\\adrlab15\db\DataInProcess\' Rat '\' SSN];
                        mkdir('\\adrlab15\db\DataInProcess\',Rat);
                        mkdir(['\\adrlab15\db\DataInProcess\' Rat],SSN)
                        copyfile(fn{1},[destination '\' filename ext])
                    end
                end
                cd(curDir)
            catch exception
                if isempty(notProcessed)
                    clear notProcessed
                    notProcessed = exception;
                else
                    notProcessed(length(notProcessed)+1) = exception;
                end
            end
%         else
%             fprintf('Skipping %s. Already promoted.\n',SSN)
%         end
    else
        fprintf('Skipping %s. Session not run.\n',SSN)
    end
end