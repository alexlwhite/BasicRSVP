% simple code to display different luminance values for monitor calibration.
% Instructions for editing .txt file, extracting linear
% look-up table, and making displayInfo structure for use with Psychtoolbox
% code are at bottom of script.
 clear; close all; clear mex; clear global
calDataFile = 'CHDD_LG_26Jan2016';
calFile = 'CHDD_LG';
displayProfile = 'CHDD_LG';

finishedCalFile = 'CHDD_LG_BDEComputer_Rm370_26Jan2016.mat';

measure = 0; % 1 for measuring, 0 for checking
seperateColor = 0; % 1 for RGB, 0 for grayscale
stepDuration = 0; % seconds at each luminance level ... set to 0 if you're doing a manual cal and want key press to advance
blankDuration = 2; % seconds for screen between levels
blankColor = [0 0 255]; % blue, copying Huseyin
nSteps = 9; % to cover 0:255 
stepSize = 256/(nSteps-1);
screenLevels = [0  stepSize:stepSize:255 255];
screenLevels = unique(screenLevels);
bitsPlusPlus = 0;

try %% this try/catch/end stuff is in here for OS X in case something crashes ...

    Screen('Preference', 'SkipSyncTests', 1);
    % DEFINE BLANK SCREEN AND fixation point
    backgroundColor = 127; fontSize = 32; fontColor = [0 0 0];
    screenNumber = max(Screen('Screens')); 
    if bitsPlusPlus
        [window,screenRect] = BitsPlusPlus('OpenWindowBits++',screenNumber);
    else
        [window,screenRect] = Screen('OpenWindow',screenNumber,backgroundColor); 
    end

    if measure
        % make sure we're working with default linear clut
        if bitsPlusPlus
            BitsPlusPlus('LoadIdentityClut',window);
        else
            Screen ('LoadNormalizedGammaTable', window, (0:255)'*ones(1,3)./255,2);
        end
    else % we're checking to see if hte measurement was OK
        load(finishedCalFile) 
        linearClut = displayInfo.linearClut;
        Screen('LoadNormalizedGammaTable', window, linearClut,0); %2);
    end
    HideCursor(window);
    Screen('TextFont',window, 'Arial');
    Screen('TextSize',window, fontSize);
    Screen('DrawText',window,'Press any key when ready.', ...
        screenRect(3)/2 - 6*fontSize,screenRect(4)/2 - fontSize/2,fontColor,backgroundColor);
    Screen('Flip',window)

    keyIsDown = 0;
    disp('Waiting for key press ...')
    while ~keyIsDown
        [keyIsDown keyTime keyCode] = KbCheck;
    end
    Screen('FillRect',window,blankColor)
    Screen('Flip',window)
    WaitSecs(blankDuration)
    
    if seperateColor
        for iColor = 1:3
            for step = 1 :length(screenLevels)
                disp(['Working on step ' num2str(step) ' of ' num2str(nSteps) ' ...'])
                color = [0 0 0]; color(iColor) = screenLevels(step);
                Screen('FillRect',window,color)
                Screen('Flip',window);
                if stepDuration
                    WaitSecs(stepDuration)
                else
                    %luminance(step) = input('Enter luminance:  ');
                    pause
                end
                Screen('FillRect',window,blankColor)
                Screen('Flip',window)
                WaitSecs(blankDuration)
            end % trial loop
        end
    else
        for step = 1 :length(screenLevels)
            disp(['Working on step ' num2str(step) ' of ' num2str(nSteps) ' ...'])
            Screen('FillRect',window,screenLevels(step))
            Screen('Flip',window);
            if stepDuration
                WaitSecs(stepDuration)
            else
                %luminance(step) = input('Enter luminance:  ');
                    pause
            end
            Screen('FillRect',window,blankColor)
            Screen('Flip',window)
            WaitSecs(blankDuration)
        end % trial loop
    end

    Screen('CloseAll');
catch
    Screen('CloseAll');
    rethrow(lasterror);
end

%%
% nSteps = length(screenLevels);
% if bitsPlusPlus; nBits = 14; else nBits = 8; end
% %screenLevels = [ 0 16 32 48 64 80 96 112 128 143 159 175 191 207 223 239 255];
% %luminance = [.3847 .812 2.983 6.963 13.25 21.51 32.13 44.53 59.37 75.49 94 114.9 137.6 162.5 189.9 220.5 225.9];
% 
% % save raw data
% save(fullfile('C:\Users\mpschallmo\OneDrive - UW Office 365\MurrayLab\monitorCal'...
%     ,calDataFile),'nBits','nSteps','screenLevels','luminance')
% 
% % need to fit function but for today ...
% 
% lumRange = max(luminance) - min(luminance);
% lumSteps = min(luminance):lumRange/(2^nBits):max(luminance);
% 
% linearClut = interp1(luminance,screenLevels,lumSteps);
% 
% linearClut = repmat(linearClut',[1 3])/max(linearClut(:));
% 
% displayInfo.comments = ['SystemPreferences --> Display --> Color --> Display profile: ' displayProfile];
% displayInfo.cal = calFile;
% displayInfo.nBits = nBits;
% displayInfo.size = [43.1 32.4];
% displayInfo.linearClut = linearClut;
% plot(displayInfo.linearClut)
% outFileName = fullfile('C:\Users\mpschallmo\OneDrive - UW Office 365\MurrayLab\monitorCal'...
%     ,calFile)
% save(outFileName,'displayInfo')
