function gammaInverse = CCMakeInverseGamma(cal)
% gammaInput = CCMakeGamma(cal)
% creates inverse gamma table for use with 'LoadNormalizedGammaTable'
% 3/15/15   JP created CCMakeGamma 

gammaInverse = zeros(256,3);
for i = 0:255
    gammaInverse(i+1,1) = CCUnitToGun(cal,cal.r.p1,cal.r.p2,i/255)/255;
    gammaInverse(i+1,2) = CCUnitToGun(cal,cal.g.p1,cal.g.p2,i/255)/255;
    gammaInverse(i+1,3) = CCUnitToGun(cal,cal.b.p1,cal.b.p2,i/255)/255;
end;
