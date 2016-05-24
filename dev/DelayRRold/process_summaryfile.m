function summaryOut = process_summaryOutmaryfile(fn)
%
%
%
%

summaryOut.Drug='';
summaryOut.Dose=nan;
summaryOut.Weight=[];
summaryOut.Pellets=[];
summaryOut.Laps=[];
summaryOut.Skips=[];
summaryOut.Blocks=[];
summaryOut.Nudges=[];
summaryOut.PostFeed=[];
summaryOut.Notes={};

if ~isempty(fn)

    fid=fopen(fn,'r');
    tline = fgetl(fid);
    notesfield = false;
    note=0;
    while ischar(tline)
        if ~notesfield
            if length(tline)>4
                str = tline(1:4);
                switch str
                    case 'Drug'
                        id = regexpi(tline,':');
                        Drug = tline(id+2:end);
                        summaryOut.Drug = Drug;
                    case 'Dose'
                        id = regexpi(tline,':');
                        id2  = regexpi(tline,'mg/kg');
                        Dose = tline(id+2:id2-1);
                        summaryOut.Dose = str2double(Dose);
                    case 'Weig'
                        id = regexpi(tline,':');
                        id2  = max(regexpi(tline(7:end),'g'));
                        if isempty(id2)
                            id2 = length(tline)+1;
                        end
                        Weight = tline(id+2:id2-1);
                        summaryOut.Weight = str2double(Weight);
                    case 'Pell'
                        id = regexpi(tline,':');
                        id2  = regexpi(tline,'(');
                        Pellets = tline(id+2:id2-1);
                        summaryOut.Pellets = str2double(Pellets);
                        if ~isempty(regexpi(Pellets,'='))
                            id = regexpi(tline,'=');
                            Pellets = tline(id+1:id2-1);
                            summaryOut.Pellets = str2double(Pellets);
                        end
                    case 'Laps'
                        id = regexpi(tline,':');
                        Laps = tline(id+2:end);
                        summaryOut.Laps = str2double(Laps);
                        if ~isempty(regexpi(Laps,'='))
                            id = regexpi(tline,'=');
                            Laps = tline(id+1:end);
                            summaryOut.Laps = str2double(Laps);
                        end
                    case 'Skip'
                        id = regexpi(tline,':');
                        Skips = tline(id+2:end);
                        summaryOut.Skips = str2double(Skips);
                        if ~isempty(regexpi(Skips,'='))
                            id = regexpi(tline,'=');
                            Skips = tline(id+1:end);
                            summaryOut.Skips = str2double(Skips);
                        end
                    case 'Bloc'
                        id = regexpi(tline,':');
                        id2 = max(regexpi(tline,'/'));
                        Blocks = tline(id+2:id2-1);
                        Nudges = tline(id2+1:end);
                        summaryOut.Blocks = str2double(Blocks);
                        summaryOut.Nudges = str2double(Nudges);
                    case 'Post'
                        id = regexpi(tline,':');
                        id2 = regexpi(tline,'g');
                        PostFeed = tline(id+2:id2-1);
                        summaryOut.PostFeed = str2double(PostFeed);
                    case 'Note'
                        notesfield = true;
                        note = note+1;
                end
            end
        else
            summaryOut.Notes{note} = tline;
        end

        tline = fgetl(fid);
    end
    
end