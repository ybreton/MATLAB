function process_nvts(varargin)
% Produces SSN-VT1.mat files for every subdirectory encountered.
% if VT1.zip does not exist, VT1.nvt will be automatically zipped.
% varargin switches:
% overwrite_vt1 	allow *-vt1.mat to be overwritten from nvt (default false)
% overwrite_nvt 	allow vt1.nvt to be overwritten from zip (default false)
% keep_only_zip 	remove vt1.nvt after processing and zipping if necessary (default false).
%
%
%

overwrite_vt1 = false;
overwrite_nvt = false;
keep_only_zip = false;
process_varargin(varargin);



zipped_nvts = FindFiles('VT1.zip');
for fid = 1 : length(zipped_nvts)
    [zip_parts{fid,1},zip_parts{fid,2},zip_parts{fid,3}] = fileparts(zipped_nvts{fid});
end
if overwrite_nvt
    % If overwriting nvts, anywhere there are zips, extract them.
    to_extract = zip_parts;
else
    % If not overwriting nvts, extract zips in directories that don't
    % already have nvts.
    nvt_files = FindFiles('VT1.nvt');
    if ~isempty(nvt_files)
        for fid = 1 : length(nvt_files)
            [nvt_parts{fid,1},nvt_parts{fid,2},nvt_parts{fid,3}] = fileparts(nvt_files{fid});
        end
        [common,different] = find_common_different_paths(zip_parts(:,1),nvt_parts(:,1));
    else
        different = true(size(zip_parts,1),1);
    end
    to_extract = zip_parts(different,:);
end
for fid = 1 : size(to_extract,1)
    source = [to_extract{fid,1} '\' to_extract{fid,2} to_extract{fid,3}];
    destination = [to_extract{fid,1} '\'];
    fprintf('Extracting %s\n',source)
    unzip(source,destination)
end
nvt_files = FindFiles('VT1.nvt');
for fid = 1 : length(nvt_files)
    [nvt_parts{fid,1},nvt_parts{fid,2},nvt_parts{fid,3}] = fileparts(nvt_files{fid});
end

if overwrite_vt1
    % If overwriting VT1s, anywhere there are nvts, there will be a VT1
    % produced.
    to_process = nvt_parts;
else
    % If not overwriting VT1s, exclude the nvts that are in directories
    % that already have VT1s.
    processed_vt1s = FindFiles('*-vt.mat');
    if ~isempty(processed_vt1s)
        for fid = 1 : length(processed_vt1s)
            [vt1_parts{fid,1},vt1_parts{fid,2},vt1_parts{fid,3}] = fileparts(processed_vt1s{fid});
        end
        [common,different] = find_common_different_paths(nvt_parts(:,1),vt1_parts(:,1));
    else
        different = true(size(nvt_parts,1),1);
    end
    to_process = nvt_parts(different,:);
end
for fid = 1 : size(to_process,1)
    source = to_process{fid,1};
    id0 = regexpi(source,'\');
    SSN = source(max(id0)+1:end);
    destination = [source '\' SSN '-vt.mat'];
    pushdir(source);
    fprintf('Producing VT1 for %s\n', SSN)
    nvt = FindFiles('vt1.nvt');
    [x,y,phi] = LoadVT_lumrg(nvt{1});
    save(destination,'x','y','phi')
    zip = FindFiles('vt1.zip');
    if isempty(zip)
        zip('VT1.zip','VT1.nvt')
        % notify user.
        fprintf('Zipping VT1.nvt to VT1.zip.\n')
    end
    popdir;
    clear x y
end
if keep_only_zip
    for fid = 1 : size(to_process,1)
        source = to_process{fid,1};
        pushdir(source)
        nvt = FindFiles('vt1.nvt');
        % if keeping only zip files, remove VT1.nvt files.
        cmd_str = sprintf('!del %s',nvt{1});
        eval(cmd_str)
        fprintf('Removing VT1.nvt.\n')
        popdir
    end
end

function [common,different] = find_common_different_paths(A,B)
common = false(size(A,1),1);
different = false(size(A,1),1);
for r1 = 1 : size(A,1)
    a0 = A{r1};
    idDupe = false(size(B,1),1);
    for r2 = 1 : size(B,1)
        b0 = B{r2};
        idDupe(r2) = strcmp(a0,b0);
    end
    if any(idDupe)
        common(r1) = true;
    else
        different(r1) = true;
    end
end