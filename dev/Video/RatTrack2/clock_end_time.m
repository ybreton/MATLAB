function t2 = clock_end_time(t1,remaining)
% finds the [YY MM DD hh mm ss] that is remaining time from t1.
% t2 = clock_end_time(t1,remaining)
%
%

T = repmat(t1,[6 1])+eye(6);
% Matrix T is one year, one month, one day, one hour, one minute and one
% second from now.
for r = 1 : 6
    A(r,1) = etime(T(r,:),t1);
end

C = t1*A;
% Current seconds.
F = C+remaining;
% Finish seconds.

Y = floor(F/A(1));
M = floor((F-Y*A(1))/A(2));
D = floor((F-([Y M]*A(1:2)))/A(3));
h = floor((F-([Y M D]*A(1:3)))/A(4));
m = floor((F-([Y M D h]*A(1:4)))/A(5));
s = (F-[Y M D h m]*A(1:5))/A(6);

t2 = [Y M D h m s];