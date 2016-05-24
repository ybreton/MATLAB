function [blocks,usedSequences] = ExperimentBlocks(nConditions)

P = perms(1:nConditions);
iR = ceil(rand(1)*size(P,1));
B(1,:) = P(iR,:);
for iBlock = 2 : size(P,2)
    % for each row of B
    idEx1 = false(size(P,1),size(B,1));
    for iB = 1 : size(B,1)
        comp = repmat(B(iB,:),size(P,1),1);
        % if any column numbers match, exclude it.
        idEx1(:,iB) = any(P==comp,2);
    end
    idEx1 = any(idEx1,2);
    
    P0 = P(~idEx1,:);
%     idEx2 = false(size(P0,1),1);
%     for r = 1 : size(P0,1)
%         clear sequence
%         sequence(1,1) = Bt(end);
%         sequence(1,2) = P0(r,1);
%         for c = 2 : size(P0,2)
%             sequence(c,1) = P0(r,c-1);
%             sequence(c,2) = P0(r,c);
%         end
%         newSequences = unique(sequence,'rows');
%         for s = 1 : size(newSequences,1)
%             if any(newSequences(s,1)==usedSequences(:,1)&newSequences(s,2)==usedSequences(:,2))
%                 idEx2(r) = true;
%             end
%         end
%     end
%     P0 = P0(~idEx2,:);
    
    if ~isempty(P0)
        iR = ceil(rand(1)*size(P0,1));
        B(iBlock,:) = P0(iR,:);
    end
end

sequence = nan(numel(B)-1,2);
Bt = B';
for iR = 1 : numel(Bt)-1
    sequence(iR,1) = Bt(iR);
    sequence(iR,2) = Bt(iR+1);
end
usedSequences = unique(sequence,'rows');

blocks = B;