function h = RRplotDecodingAnalysis(DecodingGoalAtEntry,suffix,varargin)
% For script DecodingAnalysis_sc, plots the 2x2 CNO vs Saline, Skip vs Stay
% plots of the decoding structure in DecodingGoalAtEntry with fields
% Decoding  Pxs.REGION
%                   .Current        Current zone decoding,
%                   .Next           Next zone decoding,
%                   .Previous       Previous zone decoding,
%                   .Opposite       Opposite zone decoding,
%                   .OutZone        Non-specific zone decoding,
%                   .nCells         Number of cells participating in decoding
%           .T                      Time aligned to test event
%           .value                  Threshold - Delay, more positive means more valuable, more negative means less valuable 
%           .delay                  Delay of offer
%           .threshold              Threshold for flavour on session
%           .Rat
%                   .Names          Cell array of rat names
%                   .R###           Boolean for rat
%           .Condition
%                   .Names          Cell array of condition names ('Saline' or 'CNO') 
%                   .CNO            Boolean for CNO sessions
%                   .Saline         Boolean for Saline sessions
%           .Session                Session pair number
%           .stayGo                 1==stayed, 2==skipped
%           .IdPhi                  IdPhi value at choice point
%  .VTE                    zIdPhi value exceeds criterion (0.5)

minCells = 5;
idsubset = true(size(DecodingGoalAtEntry.stayGo)); % by default, subset all trials.
process_varargin(varargin);

if nargin<2
    suffix = '';
end
if ~isempty(suffix)
    suffix = ['_' suffix];
end

% For stays vs skips,
idStay = DecodingGoalAtEntry.stayGo==1&idsubset==1;
idSkip = DecodingGoalAtEntry.stayGo==0&idsubset==1;
% For CNO vs Saline,
idSAL = DecodingGoalAtEntry.Condition.Saline==1;
%idCNO = DecodingGoalAtEntry.Condition.CNO==1;

fname = fieldnames(DecodingGoalAtEntry.Pxs);

h = nan(length(fname),1);
for region=1:length(fname)
    disp(fname{region})
    ah = nan(2,2);
    
    h(region)=figure;
    set(gcf,'Name',[fname{region} suffix])
    
    ah(1,1)=subplot(2,1,1);
    title('Stay')
    hold on
    id = idStay&idSAL;
    idCells = DecodingGoalAtEntry.Pxs.(fname{region}).nCells>=minCells;
    x0 = DecodingGoalAtEntry.T(id);
    x = unique(x0(isOK(x0)));
    disp('Saline stays...')
    if any(id(:)&idCells(:))
        eh=plotter(x,DecodingGoalAtEntry,fname{region},id&idCells);
        ylabel('Decoded P[Goal]')
    else
        xlabel(sprintf('[No stays with at least %.0f cells.]',minCells))
    end
    drawnow

%     ah(1,2)=subplot(2,2,2);
%     title('Stay, CNO')
%     hold on
%     id = idStay&idCNO;
%     x0 = DecodingGoalAtEntry.T(id);
%     x = unique(x0(isOK(x0)));
%     disp('CNO stays...')
%     eh=plotter(x,DecodingGoalAtEntry,fname{region},id,minCells);
%     drawnow
    
    ah(2,1)=subplot(2,1,2);
    title('Skip')
    hold on
    id = idSkip&idSAL;
    idCells = DecodingGoalAtEntry.Pxs.(fname{region}).nCells>=minCells;
    x0 = DecodingGoalAtEntry.T(id);
    x = unique(x0(isOK(x0)));
    disp('Saline skips...')
    if any(id(:)&idCells(:))
        eh=plotter(x,DecodingGoalAtEntry,fname{region},id&idCells);
        ylabel('Decoded P[Goal]')
        xlabel('Time aligned to test event')
    else
        xlabel(sprintf('[No skips with at least %.0f cells.]',minCells))
    end
    drawnow
%     
%     ah(2,2)=subplot(2,2,4);
%     title('Skip, CNO')
%     hold on
%     id = idSkip&idCNO;
%     x0 = DecodingGoalAtEntry.T(id);
%     x = unique(x0(isOK(x0)));
%     disp('CNO skips...')
%     eh=plotter(x,DecodingGoalAtEntry,fname{region},id,minCells);
%     xlabel('Time aligned to test event')
%     legend('Current','Next','Previous','Opposite')
%     drawnow

%     ranges = nan(numel(ah),2);
%     domains = nan(numel(ah),2);
%     for ih=1:numel(ah)
%         ranges(ih,:) = get(ah(ih),'ylim');
%         domains(ih,:) = get(ah(ih),'xlim');
%     end
%     Ylo = min(ranges(:,1));
%     Yhi = max(ranges(:,2));
%     Xlo = min(domains(:,1));
%     Xhi = max(domains(:,2));
%     for ih=ah(:)';
%         set(ih,'xlim',[Xlo Xhi]);
%         set(ih,'ylim',[Ylo Yhi]);
%     end
    drawnow
end

function eh=plotter(T,D,region,id)
y = nan(length(T),4);
s = nan(length(T),4);
for ix=1:length(T)
    fprintf('.')
    idT = D.T==T(ix);
    c = D.Pxs.(region).Current(id&idT);
    n = D.Pxs.(region).Next(id&idT);
    p = D.Pxs.(region).Previous(id&idT);
    o = D.Pxs.(region).Opposite(id&idT);
    y(ix,1) = nanmean(c);
    y(ix,2) = nanmean(n);
    y(ix,3) = nanmean(p);
    y(ix,4) = nanmean(o);
    s(ix,1) = nanstderr(c);
    s(ix,2) = nanstderr(n);
    s(ix,3) = nanstderr(p);
    s(ix,4) = nanstderr(o);
end
fprintf('\n')
eh = nan(size(y,2),1);
cmap = [0 0 1;
        0 1 0;
        1 0 0;
        0 1 1];
for iz=1:size(y,2)
    eh(iz)=errorbar(T,y(:,iz),s(:,iz),'linewidth',2,'color',cmap(iz,:));
end
xlim([min(T) max(T)])
ylim([min(y(:)-s(:)) max(y(:)+s(:))])
