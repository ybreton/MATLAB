function A = RRrotateDecoding2(B,sd)

T = B.pxs.range;
D = B.pxs.data;
for iT=1:length(T)
    q = sd.quadrant.data(T(iT));
    if q == 2
        %(-y,x)
        D0 = squeeze(D(iT,:,:));
        D(iT,:,:) = (fliplr(D0))';
    end
    if q == 3
        %(-x,-y)
        D0 = squeeze(D(iT,:,:));
        D(iT,:,:) = flipud(fliplr(D0));
    end
    if q == 4
        %(y,-x)
        D0 = squeeze(D(iT,:,:));
        D(iT,:,:) = (flipud(D0))';
    end
end
A = B;
A.pxs = tsd(T,D);
