%% function RSVP_MakeWordImages(displayName)
% 
% This function makes images of words for RSVP. It uses pre-made
% images of individual letters and concatenates them into words. Saves
% images in directory for this display. 
%
% Note: All words and word parametres are now indexed by (token, category), including in the file
% names. (July 2017). 
%
% Inputs: 
% - displayName: character string, should correspond to a file display_displayName.mat file with parameters for this display. 
 

function RSVP_MakeWordImages(displayName)

showWords = true; %whether to put up images of all words at end, to check 

%paramters for cropping letters in assembleWordImage 
% Whether to tighten image width by cropping some from left and right
kernParams.tightWidth            = true;
kernParams.minBlankOnLeftForCut  = 3; %min number of blank pixels on left side to trigger a cut
kernParams.blankOnLeftToCut      = 2; %number of blank pixels on left to cut (if any)
kernParams.minBlankOnRightForCut = 3; %same for right
kernParams.blankOnRightToCut     = 1;


%prepare screen and stimuli
codePath = RSVP_base();
projPath = fileparts(codePath);

task = RSVP_Params();
    
task.openSecondWindow = false; %no need to open second window for this

task.displayName = displayName;
scr.nBits = 8;
task.bgColor = floor(task.bgLum*((2^scr.nBits-1)));

imageFolder = sprintf('images_%s',task.displayName);
imageDir = fullfile(projPath,fullfile('images',imageFolder));
if ~isdir(imageDir)
    error('\n(RSVP_MakeWordImages) Warning: no images made for this display (%s)\n',imageFolder);
end

letterFile = fullfile(imageDir,'letters.mat');
if ~exist(letterFile,'file')
    error('\n(RSVP_MakeWordImages) Warning: no letters made for this display\n');
end
load(letterFile);

%% Make words

ncat = task.words.nCatgr;
ntok = task.words.nTokens;

origHeights = NaN(ntok,ncat);
vShifts = NaN(ntok,ncat);
wordHeights = NaN(ntok,ncat); 
wordWidths = NaN(ntok,ncat); 

for ci = 1:ncat
    wordColor = task.words.color;
    for ti = 1:ntok
        word = task.words.lexicon{ti,ci};

        %% make word from letter images
        letterColors = repmat(wordColor, length(word), 1);
        wholeImage = assembleWordImage(word, letterParams.alphabet, letterImgs, letterColors, task.bgColor, kernParams);
                
        origHeights(ti,ci) = size(wholeImage,1);
        
        tightRect=ImageBounds(wholeImage,task.bgColor);
        wordImage = wholeImage((tightRect(RectTop)+1):tightRect(RectBottom), (tightRect(RectLeft)+1):tightRect(RectRight), :);
        
        wordHeights(ti,ci) = size(wordImage,1);
        wordWidths(ti,ci) = size(wordImage,2);
        
        %top cut if how many blank pixels were shaved off the top
        topCut = tightRect(RectTop);
        
        vShifts(ti,ci) = topCut - floor(origHeights(ti,ci)/2); 
        save(fullfile(imageDir,sprintf('word_%i_%i.mat',ti,ci)),'wordImage');
       
    end
end

    
%find the tallest word and its vshift 
maxHeight = max(wordHeights(:));
tallestWord = find(wordHeights==maxHeight);
tallestWord = tallestWord(1); 
tallestWordVShift = vShifts(tallestWord);


if showWords
    [scr, task] = prepScreen_RSVP(task);
    
    
    %  words center positions
    posX = round(scr.centerX+scr.ppd*task.words.ecc*cosd(task.words.posPolarAngles));
    posY = round(scr.centerY-scr.ppd*task.words.ecc*sind(task.words.posPolarAngles));
    wordPos = [posX posY];

    for ci = 1:ncat
        for ti = 1:ntok
            load(fullfile(imageDir,sprintf('word_%i_%i.mat',ti,ci)),'wordImage');
                        
            %make texture
            wordTex=Screen('MakeTexture', scr.main, wordImage);
            
            wid = size(wordImage,2);
            hei = size(wordImage,1);
            
            
            startX = wordPos(1) - floor(wid/2);
            endX = startX + wid - 1;
            
            startY = wordPos(2) + vShifts(ti,ci);
            endY = startY + hei -1;
            
            wordRect = [startX startY endX endY];
            
            Screen('DrawTexture', scr.main, wordTex, [], wordRect);
            
            Screen(scr.main,'DrawingFinished');
            Screen('Flip',scr.main);
            
            WaitSecs(0.1);
        end
    end
    sca

end

imageParams.displayName = task.displayName;
imageParams.origHeights = origHeights;
imageParams.vShifts     = vShifts;
imageParams.wordHeights = wordHeights;
imageParams.wordWidths  = wordWidths;
imageParams.maxHeight   = maxHeight;
imageParams.tallestWordVShift = tallestWordVShift;
imageParams.ncat        = ncat;
imageParams.ntok        = ntok;
imageParams.kernParams  = kernParams;
imageParams.contrast = task.words.contrast;


save(fullfile(imageDir,'wordImageParams.mat'),'imageParams');

    

