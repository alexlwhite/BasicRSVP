%function task = chooseBlockStim_RSVP(task,scr)
% This function chooses words to present on each trial, and creates
% textures in advance. 
% It adds to task several useful fields: 
% - the matrix wordIndices, which are
% the indices of each word used, according to its position in the lexicon. 
% - task.tex is a matrix of handles to structures of the word images. 
% - task.texRects is a matrix with the rect to draw each texture into. 
% 
% Alex White, 2017

function task = chooseBlockStim_RSVP(task,scr)

nexmp = task.words.nTokens; %number of examplars/tokens in each stimulus category

ntrls = task.numTrials;
nrsvp = task.RSVP.length;

task.wordIndices = zeros(ntrls,nrsvp,2);
task.tex         = NaN(ntrls,nrsvp);
task.textRects   =  NaN(ntrls,nrsvp,4);
lastTrialTargTokens = [];

%loop through trials
for ti = 1:ntrls
    
    td = task.design.trials(ti);
    
    %% choose words
    %Avoid repetitions of any target-category words from previous trial:
    availableTargTokens = setdiff(1:nexmp,lastTrialTargTokens);
    
    thisTrialTokens = sampleWithoutReplacement(availableTargTokens,nrsvp);
    thisTrialCatgs = ones(1,nrsvp);
    
    if td.targPres
        thisTrialCatgs(td.targTime) = 2;
    end

    %Save indices:
    task.wordIndices(ti,:,:) = [thisTrialTokens' thisTrialCatgs'];
    
    %save token indices for words of target category from this trial, to avoid repeat on next trial
    lastTrialTargTokens = thisTrialTokens;

    %% Make image textures: 
    for r=1:nrsvp
        imgName = sprintf('word_%i_%i.mat',thisTrialTokens(r),thisTrialCatgs(r));
        load(fullfile(task.imagePath,imgName));
        
        wid = size(wordImage,2);
        hei = size(wordImage,1);
        
        task.tex(ti,r) = Screen('MakeTexture', scr.main, wordImage);
        
        %Save it's rect:
        wordPos = [task.words.posX task.words.posY];
        
        startX = wordPos(1) - floor(wid/2);
        endX = startX + wid - 1;
        
        startY = wordPos(2) + task.imageParams.vShifts(thisTrialTokens(r),thisTrialCatgs(r));
        endY = startY + hei -1;
        
        task.texRects(ti,r,:) = round([startX startY endX endY]);
    end    
end




