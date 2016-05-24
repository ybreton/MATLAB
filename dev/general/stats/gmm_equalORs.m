function equal = gmm_equalORs(gmobj)
% Returns the values of x in gmobj
%
%
%

mus = gmobj.mu;
equal = nan(gmobj.NComponents,gmobj.NComponents,gmobj.NDimensions);
for iComponent = 1:gmobj.NComponents-1;
    for comparison=iComponent+1:gmobj.NComponents;
        k = [iComponent comparison];
        lo = min(mus(k,:),[],1);
        hi = max(mus(k,:),[],1);
        x = fminbnd(@(x) lossFcn(gmobj,k,x),lo,hi);
        
        equal(iComponent,comparison,:) = x;
        equal(comparison,iComponent,:) = x;
    end
end

function rss = lossFcn(gmobj,k,x)
x = x(:)';
p = gmmpdf(gmobj,x)';
pComp = p(:,k);
diff = pComp(:,1)-pComp(:,2);
rss = diff(:)'*diff(:);
