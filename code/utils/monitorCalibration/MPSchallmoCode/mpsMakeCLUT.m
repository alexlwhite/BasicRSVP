function [CLUT fitGamma] = mpsMakeCLUT(luminance,displayOnOff)

if ~exist('displayOnOff','var')
    displayOnOff = 0;
end

data_size = size(luminance);
if data_size(2) ~= 3 && data_size(2) ~= 1
    error('Data should be in a matrix of #_steps x #_color channels (RGB = 3, or grayscale = 1)')
end

if displayOnOff
    figure
    set(gcf,'POS',[100 100 800 400],'color','w')
end

colors = {'r','g','b','k'};

if data_size(2) == 3
    for iC = 1:3
        L = luminance(:,iC);
        normL = (L - min(L));
        normL = normL./max(normL);
        
        fitGamma(iC) = mpsFitGamma(normL);
        
        xSteps = 0:1/255:1;
        CLUT(:,iC) = xSteps.^(1/fitGamma(iC));
        
        if displayOnOff
            subplot(1,3,1)
            ylabel('cd / m^2');
            hold on
            plot(0:255/(data_size(1)-1):255,L,[colors{iC} 'o'])
            axis([0 255 0 max(luminance(:))*1.1])
            
            subplot(1,3,2)
            hold on
            plot(0:255/(data_size(1)-1):255,normL,[colors{iC} 'o'])
            plot(0:255,[0:1/255:1].^fitGamma(iC),[colors{iC} '-'])
            text(10,.8+.06*iC,num2str(fitGamma(iC)),'color',colors{iC});
            axis([0 255 0 1])
            
            subplot(1,3,3)
            hold on
            plot(0:255,[0:1/255:1].^(1/fitGamma(iC)),[colors{iC} '-'])
            %text(10,.8+.06*iC,num2str(fitGamma(iC)),'color',colors{iC});
            axis([0 255 0 1])
        end
    end
else
    L = luminance;
    normL = (L - min(L));
    normL = normL./max(normL);
    
    fitGamma = mpsFitGamma(normL);
    
    xSteps = 0:1/255:1;
    CLUT = repmat([xSteps.^(1/fitGamma)]',1,3);
    
    if displayOnOff
        subplot(1,3,1)
        ylabel('cd / m^2');
        hold on
        plot(0:255/(data_size(1)-1):255,L,[colors{4} 'o'])
        axis([0 255 0 max(luminance(:))*1.1])
        
        subplot(1,3,2)
        hold on
        plot(0:255/(data_size(1)-1):255,normL,[colors{4} 'o'])
        plot(0:255,[0:1/255:1].^fitGamma,[colors{4} '-'])
        text(10,.94,num2str(fitGamma),'color',colors{4});
        axis([0 255 0 1])
        
        subplot(1,3,3)
        hold on
        plot(0:255,[0:1/255:1].^(1/fitGamma),[colors{4} '-'])
        axis([0 255 0 1])
    end
end

end

function fitGamma = mpsFitGamma(L)
nSteps = size(L,1);
xdata = 0:1/(nSteps-1):1;
initParam = 1;

fitGamma = lsqcurvefit(@(gamma,xdata) xdata.^(gamma),initParam,xdata',L);
end