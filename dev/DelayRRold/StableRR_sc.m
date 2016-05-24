clear
%% produce structures for each condition

CNO = wrap_RR_analysis('CNO'); % modify for your own conditions.
VEH = wrap_RR_analysis('Saline'); % modify for your own conditions.

%% produce threshold plots
fh=wrap_RR_plotThresholds(VEH,1,'titleStr','Vehicle');
wrap_RR_plotThresholds(CNO,2,'fh',fh,'titleStr', 'CNO');

%% produce flavor preference plots

fh=wrap_RR_plotRMS(VEH,CNO,'plotAmount',false);

%% produce 2D histogram of stay duration vs delay

fh = wrap_RR_stayDuration2DHist(VEH,'titleStr','Vehicle');
fh2 = wrap_RR_stayDuration2DHist(CNO,'titleStr','CNO');

%% IdPhi

fh = wrap_RR_plotVTEhists(VEH,CNO);
fh = wrap_RR_plotVTEdiffs(VEH,CNO);
fh = wrap_RR_plotVTEviaThresh(VEH,CNO);
fh = wrap_RR_plotVTEviaGMM(VEH,CNO);