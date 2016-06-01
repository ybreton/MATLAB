function [ulti_raw] = BrianUploaderRR(ulti_raw, animals, days)
%Uploads new Anymaze data to mainframe system

for itA = animals
    for itD = days
        
        %.xlsx??
        name = strcat('Animal', num2str(itA), ...
            '_Day', num2str(itD), '.xlsx');
        
        %Does the data exist?
        if exist(fullfile(cd, name), 'file') == 2
            %Raw data
            ulti_raw{itA, itD} = xlsread(name);

            fprintf(1, '%s uploaded successfully.\n', name)
        else
            fprintf(2, 'There is no %s file in %s!\n', name, cd)
        end
    end    
end
end

