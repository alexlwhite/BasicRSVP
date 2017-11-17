function [normTable, fitGamma] = alwMakeNormGammaTable(gunVals,luminance,doPlot)

%This version: a slight edit to code written by Michael-Paul Schallmo 
%But following John Palmer's advice, the luminance values are normalized in a different
%way before refitting. Rather than subtracting the minimum then dividing by
%the max (so goes from 0-1), this simply divides by the max, so they are
%ratios. 
%Also, fitting excludes any NaNs in the luminance data. NaNs are used when
%the photometer failed to make a measurement due to low light. 

if ~exist('doPlot','var')
    doPlot = 0;
end

data_size = size(luminance);
if data_size(2) ~= 3 && data_size(2) ~= 1
    error('Data should be in a matrix of #_steps x #_color channels (RGB = 3, or grayscale = 1)')
end
nChans = size(luminance,2);

if doPlot
    figure
    set(gcf,'pos',[100 100 800 400],'color','w')
end

if nChans==1
    colors = {'k'};
else
    colors = {'r','g','b'};
end

xSteps = 0:1/255:1;
normTable = zeros(length(xSteps),nChans);

for iC = 1:nChans
    
    %normalize luminance simply by dividing by the max
    L = luminance(:,iC);
    normL = L/max(L);
    %normL = (L-min(L))/max(L);
    
    %exclude missing data points
    goodis = ~isnan(normL);
    normL = normL(goodis);
    gunsFit = gunVals(goodis);
    gunsFitNorm = gunsFit/max(gunsFit); %also normalize output gun values (ratio)
    
    fitGamma(iC) = alwFitGamma(gunsFitNorm,normL);
    
    normTable(:,iC) = xSteps.^(1/fitGamma(iC));
    
    if doPlot
        subplot(1,3,1)
        ylabel('cd / m^2');
        hold on
        plot(gunsFit,L(goodis),[colors{iC} 'o'])
        axis([0 255 0 max(luminance(:))*1.1])
        
        subplot(1,3,2)
        hold on
        plot(gunsFitNorm,normL,[colors{iC} 'o'])
        plot(xSteps,xSteps.^fitGamma(iC),[colors{iC} '-'])
        text(.10,.8+.06*iC,num2str(fitGamma(iC)),'color',colors{iC});
        axis([0 1 0 1])
        
        subplot(1,3,3)
        hold on
        plot(0:255,xSteps.^(1/fitGamma(iC)),[colors{iC} '-'])
        axis([0 255 0 1])
    end
end


end

function fitGamma = alwFitGamma(v,L)
initParam = 1;
fitGamma = lsqcurvefit(@(gamma,v) v.^(gamma),initParam,v',L);
end