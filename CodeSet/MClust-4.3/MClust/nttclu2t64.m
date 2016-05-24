function [t64,success] = nttclu2t64(filenames,varargin)
% Converts clusters indicated in files with filenames:
%
% filename{i}.clusters, 
% filename{i}.ntt
%
% to a uint64-formatted t-file with name:
% 
% filename{i}_0j._t     if clusters{j}.name contains "maybe", "cut", "doublet", or "ghost"
%                       or filename{i}_0j._t already exists
%
% filename{i}_0j.t      otherwise.
%
%
%

debug = true;
progressBar = true;
process_varargin(varargin);

if ischar(filenames)
    filenames = {filenames};
end

if progressBar
    pbh = timedProgressBar('Converting to UINT64',length(filenames));
end
t64 = cell(length(filenames),1);
success = false(length(filenames),1);
for iF=1:length(filenames)
    disp(['Parsing ' filenames{iF} '...'])
    [fd,fn] = fileparts(filenames{iF});
    cluFn = fullfile(fd,[fn '.clusters']);
    nttFn = fullfile(fd,[fn '.ntt']);
    disp('Loading clusters...')
    try
        clu = load(cluFn,'-mat');
        isClu = true;
    catch ME
        warning(ME.message)
        isClu = false;
    end
    disp('Loading NTT...')
    try
        ntt = LoadTT_NeuralynxNT(nttFn);
        isNtt = true;
    catch ME
        warning(ME.message)
        isNtt = false;
    end
    
    if isClu && isNtt
        if debug
            clf
            hold on
            xlim([min(ntt), max(ntt)]);
            ylim([0, length(clu.Clusters)+1])
        end
        for iC=1:length(clu.Clusters)
            fn2 = sprintf('%s_%02.0f',fn,iC);

            C = clu.Clusters{iC};
            name = C.name;
            use__t = ~isempty(regexpi(name,'maybe')) | ~isempty(regexpi(name,'cut')) | ~isempty(regexpi(name,'doublet')) | ~isempty(regexpi(name,'ghost'));
            
            pushdir(fd);
            if exist(fullfile(fd,[fn2 '.t']),'file')==2
                use__t = false;
            end
            if exist(fullfile(fd,[fn2 '._t']),'file')==2
                use__t = true;
            end
            popdir;
            
            if use__t
                fx2 = '._t';
            else
                fx2 = '.t';
            end
            fn2 = fullfile(fd,[fn2 fx2]);
            disp(['Processing file ' fn2])
            t64{iF} = fn2;
            
            spikes = C.mySpikes;

            tSpikes = ntt(spikes);
            disp([num2str(length(tSpikes)) ' spikes in cluster.'])

            fp = fopen(fn2, 'wb', 'b');
            if (fp == -1)
                errordlg(['Could not open file"' fn '".']);
            end

            WriteHeader(fp, ...
              'T-file', ...
              'Output from MClust', ...
              'Time of spiking stored in timestamps (tenths of msecs)',...
              'as unsigned integer: uint64');

            tSpikes = uint64(tSpikes*10000); % NEED TO CONVERT TO NEURALYNX's .t format save in integers of 0.1ms
            fwrite(fp, tSpikes, 'uint64');
            fclose(fp);
            disp([fn2 ' written.'])
            success(iF) = true;
            if debug
                color = C.color;
                if use__t
                    marker = 'ko';
                    markerfacecolor = 'w';
                else
                    marker = 'k.';
                    markerfacecolor=color;
                end
                plot(tSpikes/1e4,ones(length(tSpikes),1)*iC,marker,'markerfacecolor',markerfacecolor,'markeredgecolor',color);
            end
        end
        
        if debug
            hold off
            drawnow
        end
    end
    if progressBar
        pbh = pbh.update();
    end
end
pbh.close();

function WriteHeader(fp,varargin)
MCS.VERSION = 4.3;

fprintf(fp, '%%%%BEGINHEADER\n');
fprintf(fp, '%% Program: matlab\n');
fprintf(fp, '%% MClust version: %s\n', MCS.VERSION);
fprintf(fp, '%% Date: %s\n', datestr(now));
fprintf(fp, '%% Directory: %s\n', pwd);

if ~isempty(getenv('HOST'))
   fprintf(fp, [ '%% Hostname: ', getenv('HOST'), '\n']);
end
if ~isempty(getenv('USER'))
   fprintf(fp, [ '%% User: ', getenv('USER'), '\n']);
end

for iH = 1:length(varargin)
   if isa(varargin{iH}, 'cell')
      for jH = 1:length(varargin{iH})
         fprintf(fp, '%% %s\n', varargin{iH}{jH});
      end
   elseif isa(varargin{iH}, 'char')
      fprintf(fp, '%% %s\n', varargin{iH});
   else
      error('Unknown input type.');
   end
end
fprintf(fp, '%%%%ENDHEADER\n');