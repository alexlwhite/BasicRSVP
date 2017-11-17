function out = CCUnitToGun(cal,p1,p2,unit)% out = CCUnitToGun(cal,p1,p2,unit)% convert unit value to gun output using calibration info% this is not proportional to luminance because of the black level% e.g. unit 1 = gun 255, unit 0 = gun 0 % 10/5/02	created UnittoGun% 10/21/02	renamed EXUnitToGun% 10/23/02	renamed CLUnitToGun% 12/6/12   updated for OS10% 3/16/15   JP renamed CCUnitToGun for new set of routinesif unit == 0	out = 0;elseif p2 == 0	out = cal.gunmax*unit^(1/p1);else	out = cal.gunmax*10^(( -p1 + sqrt( p1^2 + 4*p2*log10(unit))) / (2*p2));end;