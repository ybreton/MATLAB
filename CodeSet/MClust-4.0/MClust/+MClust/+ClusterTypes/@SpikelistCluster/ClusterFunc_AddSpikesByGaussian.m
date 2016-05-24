function  ClusterFunc_AddSpikesByGaussian(self)

% PreCut Clusters - ClusterFunction_AddSpikesByConvexHull
%
% Adds ability to add individual spikes

% parameters
thorn = 1;
minSpikes = 100;
sigmaStep = 1.1;
sigma0 = 50;
h = [];
sigma = sigma0 * eye(2);
inCluster = [];

% function

MCC = self.getAssociatedCutter();
MCC.StoreUndo('Add Spikes by Gaussian');

% get axes
xFeat = MCC.get_xFeature(); Xd = xFeat.GetData;
yFeat = MCC.get_yFeature(); Yd = yFeat.GetData;
X = [Xd, Yd];

% starting point
if isempty(MCC.CC_figHandle)
    warning('MClust:Cutter', 'No axes to draw on.');
    return;
end
if ~MCC.get_redrawStatus()
    warning('MClust:Cutter', 'RedrawAxes is not checked.  Axes not aligned.');
    return
end
MCC.FocusOnAxes();
[xg,yg] = ginput(1);
mu = [xg, yg];

% Slider to find sigma
D = figure('Name', 'slider to get sigma');

uicontrol(D, 'Style', 'text', 'String','initial sigma', 'FontSize', 24, ...
            'Units', 'normalized','Position', [0.1 0.5 0.25 0.1]);
sigma0INP = uicontrol(D, 'Style', 'edit', 'FontSize', 24,'String', num2str(sigma0), ...
            'Units', 'normalized','Position', [0.4 0.5 0.25 0.1]);

uicontrol(D, 'Style', 'text', 'String','sigma step', 'FontSize', 24,...
        'Units', 'normalized','Position', [0.1 0.3 0.25 0.1]);
sigmaStepINP = uicontrol(D, 'Style', 'edit', 'FontSize', 24,'String', num2str(sigmaStep), ...
    'Units', 'normalized','Position', [0.4 0.3 0.25 0.1]);
  
Recalculate();

S = uicontrol(D, 'Style','slider', ...
    'Units', 'normalized','Position', [0.05 0.80 0.9 0.1], ...
    'callback', @SliderCallback, 'DeleteFcn', @CloseSlider, ...
    'value', 1, 'min', 1, 'max', 100, 'Foreground', 'r');

uicontrol(D, 'Style', 'pushButton', ...
    'Units', 'normalized','Position', [0.7 0.05 0.2 0.1], ...
    'FontSize', 24,'callback', @CloseOK, 'String', 'OK');
uicontrol(D, 'Style', 'pushButton', ...
    'Units', 'normalized','Position', [0.4 0.05 0.2 0.1], ...
    'FontSize', 24,'callback', @CloseCancel, 'String', 'Cancel');
uicontrol(D, 'Style', 'pushButton', ...
    'Units', 'normalized','Position', [0.05 0.05 0.3 0.1], ...
    'FontSize', 24,'callback', @Recalculate, 'String', 'Recalculate');
    
%------------ 
% CALLBACKS

    function Recalculate(~,~,~)
        if ishandle(h); delete(h); end
        sigma0 = str2double(get(sigma0INP, 'String'));
        sigmaStep = str2double(get(sigmaStepINP, 'String'));
        
        % Calculate 100 steps
        L = nan(100,1);
        sigma = cell(100,1); sigma{1} = sigma0 * eye(2);
        MCC.FocusOnAxes(); hold on;
        h = plot(xg,yg,'r*');
        
        for iC = 1:100;
            inCluster = find(det(sigma{iC}) * mvnpdf(X, mu, sigma{iC}) > thorn);
            if isempty(inCluster)
                sigma{iC+1} = sigma{iC}*sigmaStep;
            else
                if length(inCluster)<minSpikes
                    sigma{iC+1} = sigma{iC}*sigmaStep;
                else
                    sigma{iC+1} = cov([Xd(inCluster),Yd(inCluster)])*sigmaStep;
                end
            end
        end
    end
 
        
    function SliderCallback(~,~,~)
        if ishandle(h); delete(h); end
        v = floor(get(S, 'value'));
        inCluster = find(det(sigma{v}) * mvnpdf(X, mu, sigma{v}) > thorn);
        MCC.FocusOnAxes(); hold on;
        h = plot(Xd(inCluster), Yd(inCluster), 'ro');
    end

    function CloseSlider(~,~,~)
        if ishandle(h); delete(h); end
    end

    function CloseOK(~,~,~)
        close(D);        
        self.AddSpikes(inCluster);
        MCC.RedrawAxes();
    end

    function CloseCancel(~,~,~)
        close(D);
    end

end

