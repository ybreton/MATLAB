function ph = plot_preference_curve(choice,alternate,standard)
%
%
%
%

% Each lap is a binomial choice for alternate or standard.
% The value of the alternate on every lap is in alternate.

uniqueX = unique(alternate);

% When the alternate is A, there are Y choices to go to A out of all the N
% times that A is presented.
Y = zeros(length(uniqueX),1);
N = zeros(length(uniqueX),1);
for alt = 1 : length(uniqueX)
    A = uniqueX(alt);
    idx = alternate == A;
    C = choice(idx);
    Y(alt) = sum(double(C));
    N(alt) = length(C);
end

[mY,lo,hi] = binocis(Y,N-Y,2,0.05);

hold on
plot(uniqueX,mY,'ko')
eh=errorbar(uniqueX,mY,mY-lo,hi-mY);
set(eh,'linestyle','none')
set(eh,'color','k')
ylabel('Proportion of times chosen')
set(gca,'xlim',[min([alternate(:);standard(:)])-1 max([alternate(:);standard(:)])+1])
set(gca,'ylim',[-0.05 1.05])
set(gca,'ytick',[0:0.1:1])
hold off