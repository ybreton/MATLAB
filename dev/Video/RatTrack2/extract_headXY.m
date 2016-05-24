function HeadXY = extract_headXY(LED,PhiH,varargin)

r = 12;
process_varargin(varargin);
t = LED.T;
x0 = LED.D(:,1);
y0 = LED.D(:,2);

xy = [x0+cos(PhiH.D)*r y0+sin(PhiH.D)*r];
HeadXY = tsd(t,xy);