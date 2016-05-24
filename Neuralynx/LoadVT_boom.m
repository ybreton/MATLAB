function [A,B,C] = LoadVT_boom(fn)

% [TS] = LoadVT(fn) : ts-obj
% [X,Y] = LoadVT(fn) : 2 tsd-obj
% [X,Y,PHI] = LoadVT(fn): 3 tsd-obj
%
%
% X,Y returned in camera coordinates
% PHI returned in radians
% NOTE: timestamps returned are in seconds!
%
% Status: UnderConstruction
% ADR: 2001, JCJ: 2002 (New loading engine returns location of colors.)
% Version v2.0

A = []; B = []; C = [];

switch nargout
case 1 % TS only
	TS = LoadVT0_boom(fn);
	A = ts(TS'/1e6);
case 2 % X,Y only
	[TS,Xb,Yb,Xr,Yr] = LoadVT1_boom(fn);
    XintB=interp1(TS(~isnan(xb)),xb(~isnan(xb)),TS);
    YintB=interp1(TS(~isnan(yb)),yb(~isnan(yb)),TS);
    XintR=interp1(TS(~isnan(xr)),xr(~isnan(xr)),TS);
    YintR=interp1(TS(~isnan(yr)),yr(~isnan(yr)),TS);
       

    A=tsd(TS'/1e6,mean([XintB' XintR'],2));
    B=tsd(TS'/1e6,mean([YintB' YintR'],2));
case 3 % X,Y,PHI
    [TS,xb,yb,xr,yr] = LoadVT1_boom(fn);
    
    XintB=interp1(TS(~isnan(xb)),xb(~isnan(xb)),TS);
    YintB=interp1(TS(~isnan(yb)),yb(~isnan(yb)),TS);
    XintR=interp1(TS(~isnan(xr)),xr(~isnan(xr)),TS);
    YintR=interp1(TS(~isnan(yr)),yr(~isnan(yr)),TS);
       
    phi=atan2(YintB-YintR,XintB-XintR);
    
    
    A=tsd(TS'/1e6,mean([XintB' XintR'],2));
    B=tsd(TS'/1e6,mean([YintB' YintR'],2));
    C=tsd(TS'/1e6,phi');
    

otherwise
	error('Invalid function call.');
end