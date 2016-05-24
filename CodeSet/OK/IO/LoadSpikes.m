function S = LoadSpikes(tfilelist, varargin)
%
% S = LoadSpikes(tfilelist)
%
% inp: tfilelist is a cellarray of strings, each of which is a
% 	tfile to open.  Note: this is incompatible with version unix3.1.
% out: Returns a cell array such that each cell contains a ts 
% 	object (timestamps which correspond to times at which the cell fired)

% ADR 1998
%  version L4.0
%  status: PROMOTED
% ADR 2011-12-28 updated for 2011

%-------------------
% DEFAULTS
%-------------------
display = false;
process_varargin(varargin);

%-------------------
% CHECK
%-------------------
assert(isa(tfilelist, 'cell'), 'LoadSpikes: tfilelist should be a cell array.');

nFiles = length(tfilelist);

%--------------------
% Read files
%--------------------

if display, fprintf(2, 'Reading %d files.', nFiles); end

% for each tfile
% first read the header, the read a tfile 
% note: uses the bigendian modifier to ensure correct read format.

S = cell(nFiles, 1);
for iF = 1:nFiles
	tfn = tfilelist{iF};
	if ~isempty(tfn)
		if display, 
			if rem(iF,100)==0, fprintf(2, '\n%d: ', iF); 
			else fprintf(2, '.'); end
		end
		tfp = fopen(tfn, 'rb','b');
		assert(tfp ~= -1, 'Could not open tfile %s.',tfn);
		
		ReadHeader(tfp);    
		S0 = fread(tfp,inf,'uint64');	%read as 64 bit ints
		
		% Set appropriate time units to seconds.
		S0 = S0/10000;		
		S{iF} = ts(S0);
		
		fclose(tfp);
		
	end 		% if tfn valid
end		% for all files
if display, fprintf(2,'\n'); end
