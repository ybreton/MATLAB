function [alpha Diff] = ToliasFindAlpha(X,Y,varargin)
% very simple script to find alpha that gives minimum difference between
% waveforms of tetrode channels a la the Tolias 2007 cells across days
% algorithm
% X = sd1.WaveForms{idx}.mWV(:,ch);
% Y = sd2.WaveForms{jdx}.mWV(:,ch);


A0 = 0;
process_varargin(varargin);

alpha = fminsearch(@Tfun,A0);
Diff = Tfun(alpha);

	function [Diff] = Tfun(A)


		Diff = (sum((A*X - Y).^2)^.5);
	end

end