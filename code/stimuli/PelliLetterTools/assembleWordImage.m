%% function wordImg = assembleWordImage(word, alphabet, letterImgs, letterColrs, bgColor, kernParams)
% 
% Put together the image of a word from individual letter images 
% 
% by Alex L. White, 2017
% University of Washington
% 
% Inputs: 
% - word: character string to make, length L
% - alphabet: character string, length A,  of all letters in letterImgs
% - letterImgs: cell array, length A, of images of each letter
% - letterColrs: a Lx3 vector of RGB colors for each letter in word
% - bgColor: 1 value, of background color in range 0-255
% - kernParams: structure with parameters for whether and by how much to
% crop each letter image horizontally. 
%   tightWidth : whether to crop at all
%   minBlankOnLeftForCut: min number of blank pixels on left side to trigger a cut
%   blankOnLeftToCut:     number of blank pixels on left to cut (if any)
%   minBlankOnRightForCut: same for right 
%   blankOnRightToCut:    same for right


function wordImg = assembleWordImage(word, alphabet, letterImgs, letterColrs, bgColor, kernParams)

black=0;
white=255;

wordImg = [];
for li=1:length(word)
    ai = word(li)==alphabet;
    %set colors 
    letMask = letterImgs{ai};
    maskWid = size(letMask,2);
    
    if kernParams.tightWidth
        tightRect=ImageBounds(letMask,white);
        if tightRect(RectRight)<(maskWid-kernParams.minBlankOnRightForCut+1)
           letMask = letMask(:, 1:(maskWid-kernParams.blankOnRightToCut), :);
        end
        if tightRect(RectLeft)>(kernParams.minBlankOnLeftForCut)
           letMask = letMask(:, kernParams.blankOnLeftToCut:end, :);
        end
    end
    
    letImg = NaN(size(letMask));
    for gi=1:3
        gunImg = letMask(:,:,gi); 
        gunImg(gunImg==white) = bgColor; 
        gunImg(gunImg==black) = letterColrs(li,gi);
        letImg(:,:,gi) = gunImg;
    end
        
    wordImg = cat(2,wordImg,letImg);
end
