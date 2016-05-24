function [I d1 d2 C] = FindConsistentCells(sd1,sd2,varargin)
% function written by nate Powell 8/7/2012 to identify potential cells that
% are consistently recorded across days from MT maze data based on waveform
% and being on the same tetrode
%sd1 = MTinitAS(FD{1});
%sd2 = MTinitAS(FD{2});



for idx=1:length(sd1.S)
    % Find tetrode reference for comparison to other Cell (must both be on
    % same tetrode...
	itr = 0;
	%Tref2(jdx) = str2num(sd2.fc{jdx}((end-5):(end-4))); %tetrode reference
	while isempty(str2num(sd1.fc{idx}((end-5-itr):(end-4-itr))))
		itr = itr+1;
	end
	Tref1(idx) = str2num(sd1.fc{idx}((end-5-itr):(end-4-itr))); %tetrode reference
	
    
    
    for jdx=1:length(sd2.S)
        
        C(idx,jdx) = mean(diag(corr(sd1.WaveForms{idx}.mWV(:,:),sd2.WaveForms{jdx}.mWV(:,:))));
            
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
end

for idx=1:length(sd1.S)
	for jdx = 1:length(sd1.S)
		C1(idx,jdx) = mean(diag(corr(sd1.WaveForms{idx}.mWV(:,:),sd1.WaveForms{jdx}.mWV(:,:))));
	end
end
for idx=1:length(sd2.S)
	for jdx = 1:length(sd2.S)
		C2(idx,jdx) = mean(diag(corr(sd2.WaveForms{idx}.mWV(:,:),sd2.WaveForms{jdx}.mWV(:,:))));
	end
end
% adaptive threshold, based on the percent correlation necessary to reduce
% the self-correlation waveform matrixes to diagonals...
peref = .95;
while ~isequal((C1>peref),eye(length(sd1.S)))
    while ~isequal((C2>peref),eye(length(sd2.S)))
        peref = peref+.001;
        if peref == 1
            peref = .999;
            break
        end
    end
    peref = peref+.001;
    if peref == 1
        peref = .999;
        break
    end
end
Comb = C(:)>peref & CT(:);
Comb = reshape(Comb,length(sd1.S),length(sd2.S));

[d1 d2] =find(Comb==1);

I = [d1 d2];
