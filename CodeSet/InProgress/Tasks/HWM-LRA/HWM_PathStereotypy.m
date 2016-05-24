function [DL,DR] = HWM_PathStereotypy(sd)

% step 1 find all Fcl to Fr paths (RIGHT)
% and all Fcr to Fl paths (LEFT)

nR = length(sd.Fcl);
R0 = sd.Fcl; R1 = nan(nR,1);
for iR = 1:nR
    f = find(sd.Fr>sd.Fcl(iR), 1, 'first');
    if ~isempty(f), R1(iR) = sd.Fr(f); end
end

nL = length(sd.Fcr);
L0 = sd.Fcr; L1 = nan(nL,1);
for iL = 1:nL
    f = find(sd.Fl>sd.Fcr(iL), 1, 'first');
    if ~isempty(f), L1(iL) = sd.Fl(f); end
end

% step 2 calculate distances
DL = HWM_nykampDistance(sd, L0, L1);
DR = HWM_nykampDistance(sd, R0, R1);

% check
% for iL = 1:nL
%     x0 = sd.x.restrict(L0(iL), L1(iL)); y0 = sd.y.restrict(L0(iL), L1(iL));
%     plot(-sd.y.data, -sd.x.data, 'k.', -y0.data, -x0.data, 'ro');
%     title(sprintf('lap %d: DL = %.2f', iL, DL(iL)));
%     pause;
% end
% 
% for iR = 1:nR
%     x0 = sd.x.restrict(R0(iR), R1(iR)); y0 = sd.y.restrict(R0(iR), R1(iR));
%     plot(-sd.y.data, -sd.x.data, 'k.', -y0.data, -x0.data, 'go');
%     title(sprintf('lap %d: DR = %.2f', iR, DR(iR)));
%     pause;
% end

