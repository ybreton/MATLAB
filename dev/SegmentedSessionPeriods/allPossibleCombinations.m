function combos = allPossibleCombinations(Y,varargin)
%
%
%
%

minDuration = 1;
process_varargin(varargin);

id = Y(:,1)>=minDuration;
Y = Y(id,:);
Y = uint8(Y);

if size(Y,2)<2
    combos = Y;
else
    % Set X to column 1
    nValid = (sum(double(~isnan(Y)),1));
    nCols = (size(Y,2));
    for c = 1:nCols-1
        repetitions(c) = (prod(nValid(c+1:end)));
    end
    nRows = (prod(nValid));
    
    nTiles = (nRows/nValid(nCols)); % last column is tiled this many times.
    
    X = zeros(nRows,nCols,'uint8');
    for c = 1 : nCols-1
        id = ~isnan(Y(:,c));
        validY = Y(id,c);
        
        start = zeros(length(validY),1,'uint8');
        finish = zeros(length(validY),1,'uint8');
        
        start(1) = uint8(1);
        for id = 1 : length(validY)-1
            finish(id) = start(id)+repetitions(c)-1;
            start(id+1) = finish(id)+1;
        end
        finish(length(validY)) = nRows;
        for Yid = 1 : length(start)
            X(start(Yid):finish(Yid),c) = validY(Yid);
        end
    end
    id = ~isnan(Y(:,end));
    validY = Y(id,end);
    X(:,nCols) = repmat(validY(:,end),nTiles,1);
    combos = X;
    
    % At this point, combos has all columns of Y.
    
end