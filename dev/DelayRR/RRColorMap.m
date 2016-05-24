function cmapFace = RRColorMap(zone)
% Produces the RRow colour map for marker faces.
% cmapFace = RRColorMap
% where cmapFace is
% [Cherry       [196 0   0;          
%  Banana    =   255 204 51;   /255  
%  White         255 255 255;        
%  Chocolate]    139 69  19] 
%
% cmapFace = RRColorMap(zone) will produce the RGB triplet for the zone.
%
%

cmapFace = [255 0   0;
            255 204 51;
            255 255 255;
            139 69  19];
cmapFace = cmapFace./255;

if nargin>0
    cmapFace = cmapFace(zone);
end