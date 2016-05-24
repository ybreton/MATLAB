function Icc = FindCellsAcrossDaysTask(FD,varargin)
% written by nate Powell, 03-2013
% a Function based on the combined approach of setting a threshold using a
% pre-determined 

%Vars:  Threshold for FindConsistentCells (NCST)?
%       Threshold parameters for ROC Tolias Threshold
%       Specific Init Function somehow?
%       ThresholdPlots (flag)

%%%% need a skimmed down simplified init that should work for any task, and
%%%% will find the bits we need... waveforms and loading cells mostly.
%%% might be worth having a flag to run CreateCQ if necessary as well...
%%% maybe...

ThresholdPlots = false;
False_Positive_Rate = .1;
True_Positive_Rate = .99;
ChooseThresholdGraphically = false;

process_varargin(varargin);

adx = 1;
bdx = 0;

for idx=1:length(FD)-1
	sd1 = WVinit(FD{idx},varargin);sd2 = WVinit(FD{idx+1},varargin); 
	%sd1 = MTinitAS(FD{idx});sd2 = MTinitAS(FD{idx+1}); 
	if idx ==1; bdx = length(sd1.S)+adx; end
	[d1 d2] = Tolias_FindDistances(sd1,sd2);
	D1(adx:adx+length(sd1.S)-1,bdx:bdx+length(sd2.S)-1)=d1;
	D2(adx:adx+length(sd1.S)-1,bdx:bdx+length(sd2.S)-1)=d2;
	
	I{idx}=FindConsistentCells(sd1,sd2);
	for cdx = 1:length(I{idx})
		%Min = FRV.Cell(find(FRV.Day_Cell == 1 & FRV.Day == idx,1,'first'))-1;
		Ic{idx}(:,1)=I{idx}(:,1)+adx-1;
		%Min = FRV.Cell(find(FRV.Day_Cell == 1 & FRV.Day == idx+1,1,'first'))-1;
		Ic{idx}(:,2)=I{idx}(:,2)+bdx-1;
	end
	
	mask(adx:adx+length(sd1.S)-1,bdx:bdx+length(sd2.S)-1) = zeros(length(sd1.S),length(sd2.S));
	for jdx = 1:size(I{idx},1)
		mask(Ic{idx}(jdx,1),Ic{idx}(jdx,2))=1;
	end
	Days1{idx} = adx:adx+length(sd1.S)-1;
	Days2{idx} = bdx:bdx+length(sd2.S)-1;
	adx = length(sd1.S)+adx;
	bdx = length(sd2.S)+bdx;
end

Icc = Ic{1};
NCells = bdx-1;

for idx=2:length(Ic) % originally length(I), modified 9.2.2014
	Icc = cat(1,Icc,Ic{idx});
end

mask(NCells,NCells)=0;
D1(NCells,NCells) = 0;
D2(NCells,NCells) = 0;

D1(isinf(D1)) = max(D1(~isinf(D1))); %% preserves high value while eliminating errors...
D2(isinf(D2)) = max(D2(~isinf(D2))); %% preserves high value while eliminating errors...

% finding the discriminator by Tolias Paper method:
bDum(:,1) = D1(mask ==0 & D1 ~=0);
bDum(:,2) = D2(mask ==0 & D2 ~=0);


bDm(:,1) = D1(mask==1);
bDm(:,2) = D2(mask==1);


mu1 = nanmean(bDm);
mu2 = nanmean(bDum);
Q1 = nancov(bDm);
Q2 = nancov(bDum);

V = (mu2 - mu1)/(Q1+Q2);

W = sign(V(1))* V/(V(1)^2 + V(2)^2)^.5;

Data(:,1) = D1(D1~=0);
Data(:,2) = D2(D1~=0);

dtilde = (W*Data')';

Data1(:,1) = D1(mask == 1 &D1~=0);
Data1(:,2) = D2(mask == 1 &D1~=0);
Data2(:,1) = D1(mask == 0 &D1~=0);
Data2(:,2) = D2(mask == 0 &D1~=0);

dtilde1 = (W*Data1')';
dtilde2 = (W*Data2')';


%% I THINK THIS IS WHERE I NEED AN EXPLICIT THRESHOLDING FUNCTION
R2 = dtilde/max(dtilde);
R1 = mask(D1~=0);
[tpr,fpr,thresholds] = roc(~R1',R2');

if ~ChooseThresholdGraphically
	Thresh = mean(thresholds(find(fpr<False_Positive_Rate & tpr >True_Positive_Rate)))*max(dtilde);
	if isempty(Thresh)
		sprintf('Threshold meeting criteria not found, please Choose Threshold Graphically...')
	end
end

if ChooseThresholdGraphically || isempty(Thresh)
	plot(thresholds,fpr,'r',thresholds,tpr,'g','linewidth',2);
	legend('False Positive Rate','True Positve Rate')
	[gx,gy] = ginput(1);
	Thresh = gx*max(dtilde);
end

%%% put in more threshold selecting options here...%%%%

if ThresholdPlots  % produce nice threshold plots if desired...
	Data1(:,1) = D1(mask == 1 &D1~=0);
	Data1(:,2) = D2(mask == 1 &D1~=0);
	Data2(:,1) = D1(mask == 0 &D1~=0);
	Data2(:,2) = D2(mask == 0 &D1~=0);
	
	dtilde1 = (W*Data1')';
	dtilde2 = (W*Data2')';
	
	[x,n]=hist(dtilde,100);
	[x1,n]=hist(dtilde1,n);
	[x2,n]=hist(dtilde2,n);
	
	figure
	%bar(n,x)
	hold on
	bar(n,x2,'r')
	bar(n,x1,'g')
	
	title('Cell Distribution by Linearized Tolias Distance ','fontsize',18)
	xlabel('Linearized Tolias Distance','fontsize',14)
	ylabel('Total Cells','fontsize',14)
	legend('Putative Unmatched Cells','Putative Matched Cells')
	set(gca,'fontsize',14)
	
	figure
	
	plot(n,cumsum(x1)/sum(x1),'g','linewidth',3)
	hold on
	plot(n,cumsum(x2)/sum(x2),'r','linewidth',3)
	plot([Thresh,Thresh],[0 1],'k','linewidth',3)
	
	title('Cell Cumulative Counts by Linearized Tolias Distance ','fontsize',18)
	xlabel('Linearized Tolias Distance (Normalized)','fontsize',14)
	ylabel('Cumulative Percent of Cells','fontsize',14)
	legend('Putative Matched Cells','Putative Unmatched Cells','Threshold Line')
	set(gca,'fontsize',14)
end


% keep the cells below our threshold
KeepCells = find(dtilde < Thresh);
D1t = D1(:)~=0;


clear temp1 temp2 index
for idx = 1:length(KeepCells)
	index = find(cumsum(D1t) ==KeepCells(idx),1,'first');
	temp1 = mod(index,NCells);
	temp2 = ceil(index/NCells);
	nIcc(idx,1) = min(temp1,temp2);
	nIcc(idx,2) = max(temp1,temp2);
end


%check for duplicate matches
%%%%Seems to be working...%%%%

nIcc0 = nIcc;
for idx = 1:length(nIcc)
	clear temp1
	temp1 = find(nIcc(:,1) == nIcc(idx,1));
	if length(temp1) > 1 && nIcc(idx,1) ~=0
		for jdx = 1:length(temp1)
			clear temp2
			temp2(jdx) = W*[D1(nIcc(temp1(jdx),1),nIcc(temp1(jdx),2)),D2(nIcc(temp1(jdx),1),nIcc(temp1(jdx),2))]';
		end
		[~,kdx] = min(temp2);
		for jdx = 1:length(temp1)
			if jdx ~=kdx
				nIcc(temp1(jdx),1:2) = 0;
			end
		end
	end
end
for idx = 1:length(nIcc)
	clear temp1
	temp1 = find(nIcc(:,2) == nIcc(idx,1));
	if length(temp1) > 1 & nIcc(idx,1) ~=0
		for jdx = 1:length(temp1)
			clear temp2
			temp2(jdx) = W*[D1(nIcc(temp1(jdx),1),nIcc(temp1(jdx),2)),D2(nIcc(temp1(jdx),1),nIcc(temp1(jdx),2))]';
		end
		[~,kdx] = min(temp2);
		for jdx = 1:length(temp1)
			if jdx ~=kdx
				nIcc(temp1(jdx),1:2) = 0;
			end
		end
	end
end
		
nIcc1 = nIcc;
nIcc = nIcc0;

for idx = 1:length(nIcc)
	clear temp1
	temp1 = find(nIcc(:,1) == nIcc(idx,2));
	if length(temp1) > 1 && nIcc(idx,2) ~=0
		for jdx = 1:length(temp1)
			clear temp2
			temp2(jdx) = W*[D1(nIcc(temp1(jdx),1),nIcc(temp1(jdx),2)),D2(nIcc(temp1(jdx),1),nIcc(temp1(jdx),2))]';
		end
		[~,kdx] = min(temp2);
		for jdx = 1:length(temp1)
			if jdx ~=kdx
				nIcc(temp1(jdx),1:2) = 0;
			end
		end
	end
end
for idx = 1:length(nIcc)
	clear temp1
	temp1 = find(nIcc(:,2) == nIcc(idx,2));
	if length(temp1) > 1 && nIcc(idx,1) ~=0
		for jdx = 1:length(temp1)
			clear temp2
			temp2(jdx) = W*[D1(nIcc(temp1(jdx),1),nIcc(temp1(jdx),2)),D2(nIcc(temp1(jdx),1),nIcc(temp1(jdx),2))]';
		end
		[~,kdx] = min(temp2);
		for jdx = 1:length(temp1)
			if jdx ~=kdx
				nIcc(temp1(jdx),1:2) = 0;
			end
		end
	end
end

nIcc2 = nIcc;
%combine results of both cleaning into final Icc
fIcc = nIcc1;
fIcc(nIcc2==0)=0;

oIcc = Icc;
clear Icc
Icc = fIcc(fIcc(:,1)~=0,1:2);

% find multiple cells across multiple days (candidates)
%%%******THIS NEEDS TO BE MADE MORE GENERAL... GOOD PLACE FOR
%%%RECURSION...%%%%%
% col = 2;
% while ~all(Icc(:,col)==0)
% for idx=1:length(Icc)
% 	if sum(Icc(:,col-1)==Icc(idx,col))
% 		Icc(idx,col+1) = Icc(find(Icc(:,col-1)==Icc(idx,col),1) ,col);
% 	end
% end
% col=col+1;
% end


% cleans the tree, keeping only the single sets of matched cells
% keep = true(length(Icc),1);
% for idx = 1:length(Icc)
% 	jdx = find(Icc(idx,:)==0,1,'first');
% 	found = find(any(Icc' == Icc(idx,jdx-1)));
% 	if any(found ~= idx) %if there are some doubles of the last cell number
% 		keep(found(2:end))=false;
% 	end
% 	clear found
% end
% 
% %FIcc = Icc;
% Icc = Icc(keep,:);

end



function sd = WVinit(fd,varargin)
% sd = WVinit;
% sd = WVinit(pwd);
%
% A simple Universal init function for loading just the Waveforms and spike
% data for use with the FindCellsAcrossDaysTask function.
%written by nate Powell, 4/1/2013, partially based off of DDinit, etc.

SET_MinSpks = 100;
Use__Ts = false;

if mod(length(varargin),2)~=0;
	varargin{end+1}=nan;
end

%process_varargin(varargin);

if nargin>0 && ~isempty(fd)
	pushdir(fd);
else
	fd = pwd;
end

assert(exist(fd, 'dir')==7, 'Cannot find directory %s.', fd);

[~, SSN, ~] = fileparts(fd);
sd.SSN = SSN;
%% keys
keysfn = [strrep(SSN, '-', '_') '_keys'];
assert(exist(keysfn, 'file')==2, 'Cannot find keys file %s.', keysfn);
eval(keysfn);
sd.ExpKeys = ExpKeys;
sd.ExpKeys.SSN = SSN;
sd.ExpKeys.fd = fd;

%% spike Data
fc = FindFiles('*.t', 'CheckSubdirs', 0);
if Use__Ts; fc = cat(1, fc, FindFiles('*._t', 'CheckSubdirs',0));  end 
S = LoadSpikes(fc);
%%% added 09/02/2014
B = barspikes(S, 'display', 0);
S = S(find(B >= SET_MinSpks)); 
%%%
L = zeros(length(S));
for iC = 1:length(S)
	S{iC} = S{iC}.restrict(ExpKeys.TimeOnTrack, ExpKeys.TimeOffTrack);
	L(iC) = length(S{iC}.data);
end
keep = L>0;
sd.S = S(keep);
sd.fc = fc(find(B >= SET_MinSpks));
sd.fn = {};
for iC = 1:length(sd.fc)
	[~,sd.fn{iC}] = fileparts(sd.fc{iC});
	sd.fn{iC} = strrep(sd.fn{iC}, '_', '-');
end
sd.fn = sd.fn';

%% Waveforms

fcw = FindFiles('*wv.mat');
for fdx=1:length(fcw)
	load(fcw{fdx});
	WF{fdx}.mWV = mWV;
	WF{fdx}.sWV = sWV;
	WF{fdx}.xrange = xrange;
end
sd.WaveForms = WF(find(B >= SET_MinSpks));

%--------------
if nargin > 0 && ~strcmp(fd,pwd);
	popdir;
end

end