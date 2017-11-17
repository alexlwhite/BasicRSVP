function [normTable, fitGamma, fitLowAs] = alwMakeNormGammaTableWithLowA(gunVals,luminance,doPlot)
%This version: fit a lower asymptote to the luminance measurements as a
%function of RGB intensity. 
%NOT recommended: it produces imaginary values in the resulting normTable. 
%We assume that L = A + V^g
    % where L is luminance (as a fraction of max luminance for that gun) 
    %       A is lower asympotote (also a fraction of max) 
    %       V is gun intensity value (ranges from 0 to 1)
    %       g is the gamma exponent 
%This means that after fitting A and g (the free parameters), we can invert the function 
%to produce a normalized lookup table to make roughly linear output 
  

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

fitGamma = zeros(1,nChans);
fitLowAs = zeros(1,nChans);

for iC = 1:nChans
    
    %normalize luminance simply by dividing by the max
    L = luminance(:,iC);
    normL = L/max(L);
    
    %exclude missing data points
    goodis = ~isnan(normL);
    normL = normL(goodis);
    gunsFit = gunVals(goodis);
    gunsFitNorm = gunsFit/max(gunsFit); %also normalize output gun values (ratio)
    
    fitParams = alwFitGamma(gunsFitNorm,normL);
    fitLowAs(iC) = fitParams(1);
    fitGamma(iC) = fitParams(2); 
    
    %
    xStepsCorrectedForLowA = linspace(fitLowAs(iC),1,256);    
    normTable(:,iC) = (xStepsCorrectedForLowA-fitLowAs(iC)).^(1/fitGamma(iC));
    
    if doPlot
        subplot(1,3,1)
        ylabel('cd / m^2');
        hold on
        plot(gunsFit,L(goodis),[colors{iC} 'o'])
        axis([0 255 0 max(luminance(:))*1.1])
        
        subplot(1,3,2)
        hold on
        plot(gunsFitNorm,normL,[colors{iC} 'o'])
        plot(xSteps,fitLowAs(iC)+xSteps.^fitGamma(iC),[colors{iC} '-'])
        text(.10,.98-.06*iC,sprintf('%.3f, %.3f',fitGamma(iC),fitLowAs(iC)),'color',colors{iC});
        axis([0 1 0 1])
        
        subplot(1,3,3)
        hold on
        plot(0:255,normTable(:,iC),[colors{iC} '-'])
        axis([0 255 0 1])
    end
end


end

function fitParams = alwFitGamma(v,L)
initParam = [1 0];
fitParams = lsqcurvefit(@(params,v) params(1)+v.^(params(2)),initParam,v',L);
end