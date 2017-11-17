%% function [letterParams, letterImgs, letterStruct] = VWFA_Attn4_MakeLetters(displayName)
%This function makes images of each letter in an alphabet. It uses Pelli's
%CriticalSpacing toolbox. 
% 
% By Alex L. White, 2017
% University of Washington
% 
% Inputs: 
% - displayName: name of display, used by prepScreen to determine
% properties of screen 
% 
% Outputs: 
% - letterParams: structure with lots of info about these letters
% - letterImgs: cell array of length L (number in alphabet) containing 2D
%    matrices of letter images 
% - letterStruct: texture returned by CreateLetterTextures with more info
% about each letter. 
% 
% All three outputs are also saved in the "images" folder for this display.
% 
%NOTES: Screen('DrawText') with courier does not actually space all the
%letters out evenly. They're more condensed than that. 
%My method of simply appending letter images together keeps
%center-to-center distance constant, because all of the letter images
%returned by Pelli's CreateLetterTextures function are equal in width.
%So when assembling these individual letters into words I apply some
%'kerning' by cropping some letters horizontally. 


function [letterParams, letterImgs, letterStruct] = MakeLetters(displayName)

drawEachLetter = true;


%% prepare screen and stimuli

codePath = RSVP_base();
projPath = fileparts(codePath);

task = RSVP_Params();
task.openSecondWindow = false; %no need to open second window for this
task.displayName = displayName;

imageFolder = sprintf('images_%s',task.displayName);
imageDir = fullfile(projPath,fullfile('images',imageFolder));
if ~isdir(imageDir)
    mkdir(imageDir);
end

[scr, task] = prepScreen_RSVP(task);

letterParams.displayName = task.displayName;
letterParams.imageDir = imageDir;
%% Text rendering:
 
doAntiAlias = task.words.antiAlias;

Screen('Preference', 'TextRenderer', 1); %0=fast but no anti-aliasing; 1=high-quality slower, 2=FTGL (whatever that is)
%Try again to get rid of text anti-aliasing
Screen('Preference','TextAntiAliasing',doAntiAlias);
Screen('Preference', 'TextAlphaBlending', 1)

Screen('TextFont',scr.main,task.words.fontName);
Screen('TextSize',scr.main,task.words.fontSize);
%ttext style: 0=normal,1=bold,2=italic,4=underline,8=outline,32=condense,64=extend.
Screen('TextStyle',scr.main,0);

%% Use Pelli's function to make letter textures 

%whether to just use goal font size (computed to match RSVP_R4). 
%If false, use all of Pelli's tools to adjust given differences across alphabet
useGoalFontSize = task.words.sizeByFont;

o.alphabet = ['abcdefghijklmnopqrstuvwxyz']; 
nLetters = length(o.alphabet);
o.borderLetter = '';
o.targetFont = task.words.fontName;
o.readAlphabetFromDisk=0;
o.targetSizeIsHeight = 1; %this doesn't matter if useGoalFontSize == true;
o.targetDeg = task.words.goalLetterHeightDeg;  
o.setTargetHeightOverWidth=0; % Stretch font to achieve a particular aspect ratio.

if useGoalFontSize %don't adjust size further 
    o.targetPix = task.words.fontSize;
    o.targetHeightOverWidth = 1;
    o.targetFontHeightOverNominalPtSize=1;
else %shoot for a given size in degrees
    o.targetPix = round(o.targetDeg*scr.ppd); 
    o.targetHeightOverWidth = nan;
    o.targetFontHeightOverNominalPtSize=nan;
end
   
o.targetFontNumber=[];
o.printSizeAndSpacing = true;
o.showLineOfLetters = true;
o.contrast = 1;


window=1;

% Measure targetHeightOverWidth
if ~useGoalFontSize
    o2 = o;
    o2.targetPix=200;
    o2.alphabet = 'x';
    
    % Get bounds.
    [letterStruct,alphabetBounds]=CreateLetterTextures_AW(1,o,window);
    DestroyLetterTextures(letterStruct);
    o.targetHeightOverWidth=RectHeight(alphabetBounds)/RectWidth(alphabetBounds);
    if ~o.readAlphabetFromDisk
        o.targetFontHeightOverNominalPtSize=RectHeight(alphabetBounds)/o.targetPix;
    end
    
    % Set o.targetHeightOverWidth
    if o.setTargetHeightOverWidth
        o.targetHeightOverWidth=o.setTargetHeightOverWidth;
    end
end


[letterStruct,alphabetBounds]=CreateLetterTextures_AW(1,o,scr.main);


%Pull out the images, which is really what we want 
letterImgs = cell(1,nLetters);
for li=1:nLetters
    letterImgs{li} = letterStruct(li).image;
end

% Draw each letter for testing:
if drawEachLetter
    for li=1:nLetters
        Screen('DrawTexture',scr.main,letterStruct(li).texture);
        Screen('DrawingFinished',scr.main); Screen('Flip',scr.main);
        WaitSecs(0.1);
    end
end


letterParams.displayName = task.displayName;
letterParams.imageDir = imageDir;
letterParams.goalFontSize = task.words.fontSize;
letterParams.usedFontSize = letterStruct(1).sizePix;
letterParams.alphabet = o.alphabet;
letterParams.singleLetterRect = letterStruct(1).rect;
letterParams.rectForAnyLetter = alphabetBounds;

%store size of 1 letter in pixels
rect = Screen(scr.main,'TextBounds','x');       	% calculate text size, rtns real!, assumes fixed size font
letterParams.letterWidthPx  = rect(3);                               % 3rd element is width of text rectangle
letterParams.letterHeightPx = rect(4);
letterParams.letterWidthDeg = rect(3)/scr.ppd;
letterParams.letterHeightDeg = rect(4)/scr.ppd;
letterParams.contrast = task.words.contrast;


save(fullfile(imageDir,'letters.mat'),'letterParams','letterStruct','letterImgs');

sca;
