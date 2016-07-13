function [t64,success] = nttclu2t64(filenames,varargin)
% Converts clusters indicated in files with filenames:
% filename{i}.clusters, 
% filename{i}.ntt
% to a uint64-formatted t-file with name:
% 
% filename{i}_0j._t     if clusters{j}.name contains "maybe", "cut", "doublet", "ghost", or "sparse"
%                       or filename{i}_0j._t already exists
%
% filename{i}_0j.t      if filename{i}_0j.t already exists
%						or clusters{j}.name does not contain "maybe", "cut", "doublet", "ghost", or "sparse"
%
% [t64,success] = nttclu2t64(filenames)
% where 	t64 		is a cell array of the t64 file names (full path)
% 			success 	is a flag indicating successful file open/write
%
% 			filenames 	is a cell array of the file prefixes to be used for converting to t64
%
% OPTIONAL ARGUMENTS:
% ******************
% debug 		(default false)
% 	Displays debugging plots indicating cluster number vs. spike time as recorded on disk
% progressBar 	(default true)
% 	Displays a progress bar that updates with every file. Requires the timedProgressBar class.
% name_t 		(default {'maybe' 'cut' 'cutoff' 'doublet' 'ghost' 'bad' 'sparse'})
% 	Strings contained in cluster names that should be automatically dumped to _t files.
%
% Example:
% >> [t64,success] = nttclu2t64({'R000-2016-05-26-TT1'})
% 	will search current directory for R000-2016-05-26-TT1.clusters and R000-2016-05-26-TT1.ntt,
% 	extract the relevant information from the .clusters and .ntt file,
% 	identify for each cluster whether cluster name contains any of the name_t strings,
% 	identify for each cluster whether a ._t or .t file already exists, and
% 	write the file R000-2016-05-26-TT1_xx.t64 (or R000-2016-05-26-TT1_xx._t64) as appropriate
% 	using uint64 spike time stamps.
%

debug = false;
progressBar = true;
name_t = {'maybe' 'cut' 'cutoff' 'doublet' 'ghost' 'bad' 'sparse'};
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
            use__t = strCheckANY(name_t,name); % Are any of the strings in name_t contained in name?
            
            if ~isempty(fd)
                pushdir(fd);
            end
            if exist(fullfile(fd,[fn2 '.t']),'file')==2
                use__t = false;
            end
            if exist(fullfile(fd,[fn2 '._t']),'file')==2
                use__t = true;
            end
            if ~isempty(fd)
                popdir;
            end
            
            if use__t
                fx2 = '._t64';
            else
                fx2 = '.t64';
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

function TF = strCheckANY(ca,name)
TF = false;
for iN=1:length(ca)
	TF = TF | ~isempty(regexpi(name,ca{iN}));
end

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