function s = ThueMorseSequence(nSymbols,nSequence)
% Fair-share sequence, generalized for any number of symbols.
% s = ThueMorseSequence(nSymbols,nSequence)
% where     s           is the sequence, coded with 1:nSymbols
%           
%           nSymbols    is the number of symbols
%           nSequence   is the length of the sequence
%
% When the number of symbols is 2, this is the Thue-Morse Fair-Share
% sequence:
% 0-1-1-0-1-0-0-1
% and subsequently replacing each 0 with 01 and 1 with 10 for each doubling
% of the sequence length.
% 
% In their book on the problem of fair division, Steven Brams and Alan
% Taylor invoked the Thue–Morse sequence but did not identify it as such.
% When allocating a contested pile of items between two parties who agree
% on the items' relative values, Brams and Taylor suggested a method they
% called balanced alternation, or taking turns taking turns taking turns..., 
% as a way to circumvent the favoritism inherent when one party chooses
% before the other. An example showed how a divorcing couple might reach a
% fair settlement in the distribution of jointly-owned items. The parties
% would take turns to be the first chooser at different points in the
% selection process: Ann chooses one item, then Ben does, then Ben chooses
% one item, then Ann does.
%
% The generalized Thue-Morse Sequence therefore provides a pretty good
% randomized injection sequence of 2, 3, or more compounds that we wish to
% provide with as much "fairness" for each alternative as possible.
% Assuming a sufficiently long sequence, the probability of each symbol
% preceding any other symbol converges on equal for all symbols.
%

idx = 0:nSequence-1;
s = nan(1,nSequence);
for ii = 1:length(idx);
    str = dec2base(idx(ii),nSymbols);
    basen = zeros(1,length(str));
    for fig=1:length(str)
        % convert the number to base-nSymbols.
        basen(fig) = base2dec(str(fig),10);
    end
    % sum the digits in base-n.
    sumdig = nansum(basen);
    % the symbol is the sum of the digits in base-nSymbols modulo nSymbols.
    s(ii) = mod(sumdig,nSymbols);
end