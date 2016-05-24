function nPelletsPerDrop = fix_nPellets_Per_Drop(nPelletsPerDrop,ZoneIn,varargin)

ZF = 10;
process_varargin(varargin);

if numel(nPelletsPerDrop)<length(unique(ZoneIn(ZoneIn<ZF)))
    nPelletsPerDrop = repmat(nPelletsPerDrop(:)',1,length(unique(ZoneIn(ZoneIn<ZF))));
end
    z0 = 1;
    for z = 1 : length(ZoneIn)
        if ZoneIn(z)<ZF
            zone = ZoneIn(z);
            nP(z0) = nPelletsPerDrop(zone);
            z0 = z0+1;
        end
        if ZoneIn(z)>=ZF & z>1
            nP(z0) = nP(z0-1);
            z0 = z0+1;
        end
    end
nPelletsPerDrop = nP(1:length(ZoneIn));