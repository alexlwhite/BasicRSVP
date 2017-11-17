displayInfo.name = 'EpsonPowerlite7250';
displayInfo.location = 'MR scanner projector @ HSB, tested in coil lab';
displayInfo.calibrationDate = '2016-Feb-23';

displayInfo.viewingDistance = 66; % cm
displayInfo.projectorThrowDistance = 295; % cm
displayInfo.screenSize = [33 24]; % cm wide x tall
displayInfo.resolution = [1024 768];
displayInfo.nBits = 8; % luminance resolution, 2^n luminance steps

% displayInfo.luminance.r = [4.37 7.01 14.0 29.3 56.4 93.2 141 191 243]; %cd/m^2  Old values from march...
% displayInfo.luminance.g = [4.36 16.3 48.7 125 267 455 708 999 1319];
% displayInfo.luminance.b = [4.38 5.10 7.00 11.1 18.3 28.7 42.5 61.0 84.4];
% displayInfo.luminance.w = [4.51 21.3 64.4 165 346 592 919 1279 1690];
% 
% displayInfo.luminance.r = [4.37 8.1 17.3 40.4 75.8 128 189 253 280]; % cd/m^2 values from December 2015
% displayInfo.luminance.g = [4.35 15.6 52.4 150 315 553 879 1272 1604];
% displayInfo.luminance.b = [4.34 5.09 7.03 11.9 19.9 32.1 50.3 77.1 110];
% displayInfo.luminance.w = [4.37 20.2 68.1 194 403 707 1118 1606 2001];
 
displayInfo.luminance.r = [4.80 10.8 23.9 55.6 103 170 245 321 350]; % cd/m^2 new values
displayInfo.luminance.g = [4.83 23.1 73.6 198 398 678 1044 1465 1802];
displayInfo.luminance.b = [4.81 5.77 8.30 14.5 24.6 39.9 62.2 94.7 133];
displayInfo.luminance.w = [4.86 30.1 95.7 256 513 871 1338 1860 2257];

displayInfo.luminance.w_rm = [5.03 28.6 93.5 249 510 865 1336 1889 2362];


rgb = [displayInfo.luminance.r' displayInfo.luminance.g' displayInfo.luminance.b'];

showFig = 1;
displayInfo.linearClut = mpsMakeCLUT(rgb,showFig);
% displayInfo.linearClut = mpsMakeCLUT(displayInfo.luminance.w',showFig);
% displayInfo.linearClut = mpsMakeCLUT(displayInfo.luminance.w_rm',showFig);
if showFig
subplot(1,3,1); title(displayInfo.calibrationDate); end

% save('EpsonPowerlite7250_scannerProjector_20151208_lightsoff_incoillab','displayInfo')