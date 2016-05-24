function ShowWaveformForDisplay(varargin)

% ShowWaveformForDisplay(xrange, mWV, sWV, parms)
% ShowWaveformForDisplay(wv.matFileName, parms)
%
% parms
%
% nGray = 100
% gain = [];

if ischar(varargin{1}) && mod(length(varargin),2)==1 
    % first arg is wv.mat file name
    load(varargin{1});
    varargin = varargin(2:end);
elseif isnumeric(varargin{1}) && length(varargin)>3 && mod(length(varargin),2)==1 
    % args are xrange, mWV, sWV
    xrange = varargin{1};
    mWV = varargin{2};
    sWV = varargin{3};
    varargin = varargin(4:end);
else
    error('argument mismatch');
end

nGray = linspace(-1,1,100);
gain = [];
Extract_varargin;

if ~isempty(gain)
    mWV = mWV * gain / 4096;
    sWV = sWV * gain / 4096;
end

figure; hold on
for iC = 1:length(nGray)
    plot(xrange, mWV-nGray(iC)*sWV, 'color', [0.75 0.75 0.75]);
end
plot(xrange, mWV, 'k', 'LineWidth', 2);

set(gca, 'Xtick', [], 'FontSize', 16);
if isempty(gain)
    ylabel('Cheetah arb-units');
else
    ylabel('uV');
end