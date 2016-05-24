function Lm = mergeLabels(L,maxDist,varargin)
% Merge labels who are at most maxDist from each other.
%
debug=false;
process_varargin(varargin);
Lm = L;
converge = false;
while ~converge
    Lm = renameLabels(Lm);
    converge = true;
    if debug
        imagesc(Lm);
        colorbar;
        drawnow;
    end
    labels = unique(Lm(Lm>0));
    minDist = minimumDistance(Lm);
    I = minDist<=maxDist;
    
    for iL1=size(I,1):-1:1
        id = I(iL1,:);
        merge = labels(id);
        if ~isempty(merge)
            converge = false;
        end
        for iM=merge(:)'
            Lm(Lm==iM) = iL1;
            fprintf('Merging %.0f into %.0f...\n',iM,iL1);
        end
    end
end
Lm = renameLabels(Lm);

function Lr = renameLabels(L)
oldL = unique(L(L>0));
n = nan(length(oldL),1);
for iL=1:length(oldL)
    n(iL) = sum(L(:)==oldL(iL));
end
[~,I] = sort(n,'descend');
oldL = oldL(I);

Lr = zeros(size(L));
for iL=1:length(oldL);
    idx = L==oldL(iL);
    Lr(idx) = iL;
end

function minDist = minimumDistance(L)
xs = 1:size(L,2);
ys = 1:size(L,1);
[X,Y] = meshgrid(xs,ys);

labels = unique(L(L>0));

minDist = nan(length(labels));

for iL1=1:length(labels)-1
    x1 = X(L==labels(iL1));
    y1 = Y(L==labels(iL1));
    for iL2=iL1+1:length(labels)
        x2 = X(L==labels(iL2));
        y2 = Y(L==labels(iL2));
        
        d = nan(length(x2),length(x1));
        for ixy=1:length(x2)
            d(ixy,:) = sqrt((x1-x2(ixy)).^2+(y1-y2(ixy)).^2);
        end
        minDist(iL1,iL2) = min(d(:));
    end
end