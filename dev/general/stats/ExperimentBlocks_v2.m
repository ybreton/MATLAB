function Order = ExperimentBlocks_v2(n)
% Randomizes a latin-square ordering of n conditions that is first-order
% crossed (equal carryover effects everywhere) and row-complete (all
% conditions presented equally in each position).

Order = zeros(0,n);

    init = randperm(n);
    for c = 2 : n
        init(c,1:n-1) = init(c-1,2:end);
        init(c,n) = init(c-1,1);
    end
    for c = 1 : n
        row = init(c,:);
        mirror = init(c,end:-1:1);
        mrg = [];
        for iM = 1 : n
            mrg = [mrg row(iM) mirror(iM)];
        end
        O(c,:) = mrg;
    end
    O = [O(1:n,1:n);O(1:n,n+1:end)];
    
    if mod(n,2)==0
        O = O(1:n,:);
    end
    Order = cat(1,Order,O);

    id = randperm(size(Order,1));
    Order = Order(id,:);