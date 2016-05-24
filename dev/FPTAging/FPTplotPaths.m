function FPTplotPaths(sd,varargin)
%
%
%
%

tstart = sd.EnteringCPTime;
tend = sd.ExitingCPTime;
process_varargin(varargin);

% if isfield(sd,'EnteringCPTime_fix')
%     EnteringCPTime = sd.EnteringCPTime_fix;
% elseif isfield(sd,'EnteringCPTime')
%     EnteringCPTime = sd.EnteringCPTime;
% else
%     EnteringCPTime = nan;
% end

% if isfield(sd,'ExitingCPTime_fix')
%     ExitingCPTime = sd.ExitingCPTime_fix;
% elseif isfield(sd,'ExitingCPTime')
%     ExitingCPTime = sd.ExitingCPTime;
% else
%     ExitingCPTime = nan;
% end


x = log10(sd.IdPhi);
gmobj = gmmfit(x(~isnan(x)&~isinf(x)),2);
Z = (x-gmobj.mu(1))/gmobj.Sigma(1);
Z0 = abs(Z);
[Zmin,idMin] = min(Z0);
[Zmax,idMax] = max(Z);

MeanPath = [tstart(idMin) tend(idMin)];
MaxPath = [tstart(idMax) tend(idMax)];

hold on
for l = 1 : length(tstart);
    x = sd.x.restrict(tstart(l),tend(l));
    y = sd.y.restrict(tstart(l),tend(l));
    if ~isempty(x.data)&&~isempty(y.data)
        ph(1)=plot(x.data,y.data,'-','color',[0.8 0.8 0.8],'linewidth',1);
    end
end
x = sd.x.restrict(MeanPath(1),MeanPath(2));
y = sd.y.restrict(MeanPath(1),MeanPath(2));
ph(2)=plot(x.data,y.data,'r-','linewidth',2);

x = sd.x.restrict(MaxPath(1),MaxPath(2));
y = sd.y.restrict(MaxPath(1),MaxPath(2));
ph(3)=plot(x.data,y.data,'b-','linewidth',2);
hold off
legendStr{1} = sprintf('All paths');
legendStr{2} = sprintf('Log_{10}[I d\\phi]=%.1f',log10(sd.IdPhi(idMin)));
legendStr{3} = sprintf('Log_{10}[I d\\phi]=%.1f',log10(sd.IdPhi(idMax)));
legend(ph,legendStr);