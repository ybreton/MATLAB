function unpacked = testCircleUnpack(testCircle,x,y)
% returns 4D 
% yRez x xRez x phiH x phiB
% logical with test circle indices indicated by
% LEDx x LEDy x phiB x phiH
% cells of x and y fields in testCircle.

rez = [720 480];

unpacked = false(rez(2),rez(1),size(testCircle.x,1),size(testCircle.x,2));
for iB = 1 : size(testCircle.x,1)
    for iH = 1 : size(testCircle.x,2)
        xLoc = round(testCircle.x{iB,iH}+x);
        yLoc = round(testCircle.y{iB,iH}+y);
        invalid = xLoc<=0|yLoc<=0|isnan(xLoc)|isnan(yLoc)|xLoc>rez(1)|yLoc>rez(2);
        valid = ~invalid;
        ind = sub2ind([rez(2) rez(1)],yLoc(valid),xLoc(valid));
        I = false(rez(2),rez(1));
        I(ind) = true;
        
        unpacked(:,:,iH,iB) = I;
    end
end