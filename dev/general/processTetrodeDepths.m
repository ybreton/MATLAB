function processTetrodeDepths(fn,varargin)

TTrow = true; % Indicates that tetrodes increment across rows, at one column per session.
dirprefix = ''; % Indicates that sessions are prefixed with this directory first.
prefix = '';    % Indicates that session directories are prefixed with this string first.
readFcn = @xlsread; % Function used to read the file.
process_varargin(varargin);

[depths,labels] = readFcn(fn);

if TTrow==true
    TT = labels(2:end,1);
    SSN = labels(1,2:end);
else
    TT = labels(1,2:end);
    SSN = labels(2:end,1);
end

ca = cell(length(TT),2);
ca(:,1) = TT;
for iFd = 1:length(SSN)
    if ~isempty(dirprefix)
        pushdir(dirprefix);
    end
    fd = [prefix SSN{iFd}];
    if exist(fd,'dir')==7
        pushdir(fd);
        disp(fd);
        
        ca(:,2) = mat2can(depths(:,iFd));
        writeCA([fd '-TTdepth.csv'],ca);
        
        popdir;
    else
        disp([fd ' does not exist.'])
    end
    if ~isempty(dirprefix)
        popdir;
    end
end

function writeCA(fn,ca)
 fid = fopen(fn,'wt');
 if fid>0
     for m=1:size(ca,1)
         for n=1:size(ca,2)
             c = ca{m,n};
             if ischar(c)
                 fprintf(fid,'%s',c);
             elseif isnumeric(c)
                 if abs(c-round(c))<10^-16
                     fprintf(fid,'%d',c);
                 else
                     fprintf(fid,'%f',c);
                 end
             end
                 
             if n<size(ca,2)
                 fprintf(fid,',');
             else
                 fprintf(fid,'\n');
             end
         end
     end
     fclose(fid);
 end