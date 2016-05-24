function [d1,d2] = Tolias_FindDistances(sd1,sd2,varargin)
%written by nate Powell 8/20/2012
%a function to find the distances d1 and d2 using the method described by
%Tolias et. al. 2007, to provide a 2-axis measure of cell similarity for
%scoring cells recorded from tetrodes across multiple days 

%Tolias Method
% find alphas, weighting function, Cell 1, Cell 2, channel
%alpha is the weighting factor on Cell 1.
CT = nan(length(sd1.S),length(sd2.S));
for tdx = 1:2
	if tdx ==2
		temp = sd1;
		sd1=sd2;
		sd2 = temp;
	end
	
	A = nan(length(sd1.S),length(sd2.S),4);
	DiffN = nan(length(sd1.S),length(sd2.S),4);
	Tref1 = nan(length(sd1.S),1);
	Tref2 = nan(length(sd2.S),1);
	Adiff = zeros(4,4);
	ADiff = nan(length(sd1.S),length(sd2.S));
	for idx=1:length(sd1.S)
		% Find tetrode reference for comparison to other Cell (must both be on
		% same tetrode...
		if tdx==1
			itr = 0;
			%Tref2(jdx) = str2num(sd2.fc{jdx}((end-5):(end-4))); %tetrode reference
			while isempty(str2num(sd1.fc{idx}((end-5-itr):(end-4-itr))))
				itr = itr+1;
			end
			Tref1(idx) = str2num(sd1.fc{idx}((end-5-itr):(end-4-itr))); %tetrode reference
		end
		
		
		for jdx=1:length(sd2.S)
			
			if tdx==1
				if idx==1
					itr = 0;
					%Tref2(jdx) = str2num(sd2.fc{jdx}((end-5):(end-4))); %tetrode reference
					while isempty(str2num(sd2.fc{jdx}((end-5-itr):(end-4-itr))))
						itr = itr+1;
					end
					Tref2(jdx) = str2num(sd2.fc{jdx}((end-5-itr):(end-4-itr))); %tetrode reference
					
				end
				CT(idx,jdx) = Tref1(idx)==Tref2(jdx); %Matrix of same Tetrodes
			end
			
			%if CT(idx,jdx) == 1 %% Comment out to check all cells, not just
			%from the same tetrode...
			for chdx = 1:4 % find Alpha if both cells are from same tetrode
				[A(idx,jdx,chdx) D] = ToliasFindAlpha(sd1.WaveForms{idx}.mWV(:,chdx),sd2.WaveForms{jdx}.mWV(:,chdx));
				DiffN(idx,jdx,chdx) = D/sum(sd2.WaveForms{jdx}.mWV(:,chdx).^2)^.5;
			end
			
			%calculation for d2 later...
			for tidx=1:4
				for tjdx=1:4
					Adiff(tidx,tjdx) = log(A(idx,jdx,tidx))-log(A(idx,jdx,tjdx));
				end
			end
			ADiff(idx,jdx) = max(max(abs(Adiff)));
			%end
			
			
		end
	end
	
	if tdx ==1
		%d1(idx, jdx) = {SUM ACROSS 4 CHANNELS}(sum((A(idx,jdx,ch)*sd1.WaveForms{idx}.mWV(:,ch) - sd2.WaveForms{jdx}.mWV(:,ch)).^2)^.5);
		d1 = nansum(DiffN,3);
		d1(d1==0)=nan;
		
		d2 = max(abs(log(A)),[],3) + ADiff;
	else
		d1 = nansum(DiffN,3)' + d1;
		
		d2 = (max(abs(log(A)),[],3) + ADiff)' + d2;
	end
end