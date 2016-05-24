function mat = can2mat(can)

mat = nan(size(can));
parfor r = 1 : numel(can)
    if ~isempty(can{r})        
        if ischar(can{r})
            str = can{r};
            str = strrep(str,' ','');
            str = str2double(str);
            can{r} = str;
        end
        mat(r) = can{r};
    end
end
