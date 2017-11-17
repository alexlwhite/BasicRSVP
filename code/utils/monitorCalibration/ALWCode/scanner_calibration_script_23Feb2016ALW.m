
%SCRIPT TO GENERAGE INVERSE NORMALIZED LOOKUP TABLE GIVEN MEASURED DISPLAY LUMIANNCE VALUES 
% By Alex White (based on script by Michael-Paul Schallmo). 
% Notes: When the photometer failed to make a measurement at low light, set to 0.1 (rather than NaN). 
% There are three fitting "methods" available in the function alwMakeNormGammaTable:
% 1. Fit a exponent (gamma value) to luminance measurements epressed as a proportion 
%    of the total RANGE. So to normalize luminance values (and the RGB
%    values), subtract the minimum, then divide by max. 
% 2. Fit a exponent (gamma value) to luminance measurements epressed as a proportion 
%    of the MAX value measured. So to normalize luminance values (and the RGB
%    values), simply divide by the max. Recommended first by J. Palmer, but
%    ALW now doesn't think it works for this purpose, because fits are bad,
%    and our goals is just to *linearize* the output luminance values, so
%    all that really matters is variation within the whole range (absolute
%    value of lowest level doesn't matter). 
% 3. Fit both an exponent and a lower asymptoite to luminance measurements epressed as a proportion 
%    of the MAX value measured. This is an attempt to improve the fits of
%    method 2. The lower asymptote tries to improve estimate of the
%    exponent (gamma), and then the inverse normalized table is generated
%    by giving output values from 0 to 1 (proportion of full range),
%    putting them to power (1/gamma), and ignoring the lower asymptote. 
% 
% Recommendation: method 1, simplest, does the job of making an inverse
% table to linearize the output. 


clear; close all;

%% choices: 
method = 1;
methodLabels = {'FitPropOfRange','FitPropOfMax','FitPropOfMaxWithLowerAsympt'};

grayOnly = false;

%% data specific to this calibration: screen properties and luminance measurements 
fileName = 'ScannerProjector_23Feb2016';


display.monName = 'EpsonPowerlite7250';
display.location = 'MR scanner projector @ HSB, tested in coil lab';

%stable parameters: 
display.goalResolution = [1280 1024];
display.skipSyncTests = 1;

display.calibDate ='2016-Feb-23';

display.dist = 66; % cm
display.projectorThrowDistance = 295; % cm
display.screenSize = [33 24]; % cm wide x tall
display.width = display.screenSize(1); 
display.height = display.screenSize(2); 
display.resolution =[1024 768];
display.nBits = 8; % luminance resolution, 2^n luminance steps

%monitor output gun values used: ?
display.gunValues = [0 32 64 96 128 160 192 224 255];

%Measured luminance in candelas per meter squared
display.luminance.r = [4.80 10.8 23.9 55.6 103 170 245 321 350]; % cd/m^2 new values
display.luminance.g = [4.83 23.1 73.6 198 398 678 1044 1465 1802];
display.luminance.b = [4.81 5.77 8.30 14.5 24.6 39.9 62.2 94.7 133];
display.luminance.w = [4.86 30.1 95.7 256 513 871 1338 1860 2257];

%measurement with rachel's computer: 
display.luminance.w_rm = [5.03 28.6 93.5 249 510 865 1336 1889 2362];

%KLUGE!! Correction to red gun, because last value just looks too low to be true
% without correction, fit is bad, gamma value is quite low 
display.luminance.r(end)=400; % cd/m^2 new values\

rgb = [display.luminance.r' display.luminance.g' display.luminance.b'];


%ACTUALLY DON'T ALLOW NANs for missing values 
%Set to something very small
rgb(isnan(rgb)) = 0.1;
display.luminance.w(isnan(display.luminance.w))=0.1;

% set all guns to have same luminance at level 0, if level 0 was used
% (because in principle they must all be the samo)
if display.gunValues(1)==0 %if the 1st level used for all guns was 0...
    %then they should all have the same cd/m2, set to the average
    rgb(1,:) = mean([rgb(1,:) display.luminance.w(1)]);
    display.luminance.w(1) = rgb(1,1);
end

showFig = 1;
if ~grayOnly
    [display.normlzdGammaTable, display.fitGamma, display.fitLowA] = alwMakeNormGammaTable(display.gunValues,rgb,method,showFig);
else
    [display.normlzdGammaTable, display.fitGamma] = alwMakeNormGammaTable(display.gunValues,display.luminance.w',method,showFig);
    fileName = [fileName '_Gray'];
end
if showFig
    subplot(1,3,1); title(display.calibDate); 
end

display.method = method;
display.methodName = methodLabels{method};

save([fileName '.mat'],'display')
figName = sprintf('%s_Method%i.eps',fileName,method);
exportfig(gcf,figName,'Format','eps','bounds','loose','color','rgb','LockAxes',0,'FontMode','fixed','FontSize',12);
