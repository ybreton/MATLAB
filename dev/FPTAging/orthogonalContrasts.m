function [p,table,stats,mult] = orthogonalContrasts(Y,groups,function_handle,varargin)
%
%
%
%
sorting = 1:size(groups,2);
posthoc = true;
process_varargin(varargin);

idnan = isnan(Y)|all(isnan(groups),2);
Y = Y(~idnan);
groups = groups(~idnan);

[groups,idSort] = sortrows(groups,sorting);
Y = Y(idSort);

x1 = zeros(length(Y),1);
x2 = ones(length(Y),1);

uniqueG = unique(groups,'rows');

p = nan(size(uniqueG,1)-1,1);

for iG = 1 : size(uniqueG,1)-1
    idG = all(repmat(uniqueG(iG,:),size(groups,1),1)==groups,2);
    idC = false(length(Y),1);
    for iC = iG+1 : size(uniqueG,1)
        idC = idC | all(repmat(uniqueG(iC,:),size(groups,1),1)==groups,2);
    end
    Xcomp = [x1(idG); x2(idC)];
    Ycomp = [Y(idG); Y(idC)];
    
    [sig,tab,st]=function_handle(Ycomp,Xcomp);
    if posthoc & nargout>3
        [c,m,h,gnames]=multcompare(st);
        tstruct = struct('c',c,'m',m,'h',h);
        
        mult(iG) = tstruct;
    end
    
    p(iG) = sig;
    table(iG).tab = tab;
    stats(iG) = st;
    
end