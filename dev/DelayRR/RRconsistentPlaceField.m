function [x,y,SS] = RRconsistentPlaceField(sd,PF,seq)
% Returns a tsd of the x,y locations of the most consistent place fields in
% the sequence, using standard session data structure sd and place field
% structure PF.
% [x,y,SS] = consistentPlaceField(sd,PF,seq)
% where     x       is a tsd of centroid x locations of most consistent
%                   place field,
%           y       is a tsd of centroid y locations of most consistent
%                   place field,
%           
%           sd      is a standard session data structure with linearization
%                   information,
%           PF      is a nCells x 1 structure with place field information
%                   for each cell,
%           seq     is a tsd of the cell id that fired in the sequence.
%
%
%

nPF = arrayfun(@(PF) length(PF.Centroid.x),PF);
nPFs = max(nPF);
nCells = length(seq.data);

F.x = nan(nCells, nPFs);
F.y = nan(nCells, nPFs);
PFlist = cell(nCells,1);

cells = seq.data;
times = seq.range;
SeqList = cell(1,0);
SeqRep = [];
for iSeq=1:nCells
    C = cells(iSeq);
    F.x(iSeq,1:nPF(C)) = PF(C).Centroid.x;
    F.y(iSeq,1:nPF(C)) = PF(C).Centroid.y;
    PFlist{iSeq} = 1:nPF(C);
    if iSeq>1 
        if cells(iSeq-1)~=cells(iSeq);
            SeqList{end+1} = 1:nPF(C);
            SeqRep = [SeqRep; 1];
        else
            SeqRep(end) = SeqRep(end)+1;
        end
    else
        SeqList{1} = 1:nPF(C);
        SeqRep = 1;
    end
end
% Exhaustively list all combinations of place fields in sequence
combos0 = AllCombinations(SeqList);
combos = [];
for iCol=1:size(combos0,2)
    combos = [combos, repmat(combos0(:,iCol),[1 SeqRep(iCol)])];
end

SS = nan(size(combos,1),1);

% if size(combos,1)>1000
%     pbh=timedProgressBar('Exhaustively searching seq scores',size(combos,1));
%     parfor iRow=1:size(combos,1)
%         L = nan(size(combos,2),1);
%         for iSeq=1:size(combos,2)
%             iF = combos(iRow,iSeq);
%             if ~isnan(iF)
%                 x = F.x(iSeq,iF);
%                 y = F.y(iSeq,iF);
%                 t = times(iSeq);
%                 L(iSeq) = RRlinearizedVal(sd,t,x,y);
%             end
%         end 
%         SS(iRow) = SequenceScore(times,L);
%     end
%     pbh=pbh.update(size(combos,1));
% else
    pbh=timedProgressBar('Exhaustively searching seq scores',size(combos,1));
    for iRow=1:size(combos,1)
        L = nan(size(combos,2),1);
        for iSeq=1:size(combos,2)
            iF = combos(iRow,iSeq);
            if ~isnan(iF)
                x = F.x(iSeq,iF);
                y = F.y(iSeq,iF);
                t = times(iSeq);
                L(iSeq) = RRlinearizedVal(sd,x,y);
            end
        end 

        SS(iRow) = SequenceScore(times,L);
        pbh=pbh.update();
    end
% end
pbh.close();

[SS,I] = max(SS);

BestCombination = combos(I,:);
x = nan(size(BestCombination,2),1);
y = nan(size(BestCombination,2),1);
for iSeq=1:size(BestCombination,2)
    ix = BestCombination(iSeq);
    if ~isnan(ix)
        x(iSeq) = F.x(iSeq,ix);
        y(iSeq) = F.y(iSeq,ix);
    end
end
x = tsd(times,x);
y = tsd(times,y);
