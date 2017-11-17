%% [task, runData] = RSVP_Blocks(subj, staircase, EYE, displayName, numBlocks, rsvpPeriod, periodThreshGuess)
% Runs a block of trials of the RSVP experiment 
%
% Inputs: 
% - subj: Character string. Initials or ID of subject.  
% - staircase: Boolean.
% - EYE: -1 = no checking fixation; 0 = dummy mode (cursor as eye);  1=full eyelink mode, with online fixation checking  
% - displayName: character string. There should be a corresponding file
%   display_<displayName>.mat in code/displayInfo/. That file has info
%   about the screen dimensions, resolution, calibration file, etc. 
% - numBlocks: integer. How many blocks to fun.
% - rsvpPeriod: duration in seconds of each RSVP frame; that is, 1/rate.
%   This can be a vector for method of constant stimuli 
% - periodThreshGuess: if staircase, the threshold esimate of RSVP period. 
%
% Outputs: 
% - task: big structure with lots of info, including data, returned by the
% last block 
% - runData: structure with basic info about each trial, concatenated across blocks: respCorrect, and
%   trialDone. More could be added, 
% 
% by Alex L. White, 2017, at the University of Washington 


function [task, runData] = RSVP_RunBlocks(subj, staircase, EYE, displayName, numBlocks, rsvpPeriod, periodThreshGuess)

%% Set paths
codePath = RSVP_base();
cd(codePath);
addpath(genpath(pwd)); 

%% Add fields to params
params.subj = subj;
params.EYE = EYE;
params.doStair = staircase;
params.rsvpPeriod = rsvpPeriod;
params.periodThreshGuess = periodThreshGuess;
params.displayName = displayName;
params.reinitScreen   = true;
params.shutDownScreen = true;
params.numBlocks = numBlocks;

%blank scr to start
scr = []; task=[]; runData = [];

%% Practice
aquestion = 'Do you want to do any practice trials?\n Enter ''y'' or ''n''\n';
doPracticeResp='xxx';
while (~strcmp(doPracticeResp, 'n') && ~strcmp(doPracticeResp, 'y'))
    doPracticeResp = input(aquestion, 's');
end
doPractice = strcmp(doPracticeResp, 'y');
nPracBlocks = 0;
while doPractice
    params.practice = true;
    nPracBlocks = nPracBlocks+1;
    params.blockNum = nPracBlocks;
    params.useOldStair = false;
    
    keepAskingPeriod = true;
    if staircase
        fprintf(1,'\nNote: in practice, the staircase doesn''t run.');
    end
    while keepAskingPeriod
        practicePeriod = input('\nEnter the RSVP period (1/rate) for this practice:\n');
        keepAskingPeriod = all(isfloat(practicePeriod)) && (all(practicePeriod<0) || all(practicePeriod>2));
    end
    params.practiceRSVPPeriod = practicePeriod;
    
    try
        task = RSVP_Block(params, scr);
    catch me
        if EYE>0
            Eyelink('stoprecording');
            Eyelink('closefile');
            Eyelink('shutdown');
        end
        ListenChar(1);
        ShowCursor;
        sca;
        rethrow(me);
    end
    
    aquestion = 'Do you want to do another practice block?\n Enter ''y'' or ''n''\n';
    repeat='xxx';
    while (~strcmp(repeat, 'n') && ~strcmp(repeat, 'y'))
        repeat = input(aquestion, 's');
    end
    doPractice = strcmp(repeat, 'y');
end


%% Main blocks
params.practice = false;
blockNum = 0;

%structure to concatenate data across blocks:
runData.respCorrect = [];
runData.trialDone = [];

%don't shut down screen between blocks
params.shutDownScreen = false;
params.useOldStair = false;
doMainExpt = '';
while (~strcmp(doMainExpt, 'n') && ~strcmp(doMainExpt, 'y'))
    doMainExpt = input('\nDo you want to continue to the main task?\n (Press y or n)\n', 's');
end
if strcmp(doMainExpt, 'y')
    continueBlocks = true;
    while continueBlocks
        blockNum = blockNum + 1;
        params.blockNum = blockNum; 
        params.shutDownScreen = blockNum>=numBlocks;
        try
            %RUN A BLOCK:
            [task, scr] = RSVP_Block(params, scr);
            runData.respCorrect = [runData.respCorrect task.data.respCorrect];
            runData.trialDone   = [runData.trialDone task.data.trialDone];
        catch me
            if EYE>0
                Eyelink('stoprecording');
                Eyelink('closefile');
                Eyelink('shutdown');
            end
            ListenChar(1);
            ShowCursor;
            sca;
            rethrow(me);
        end
        
        if task.doStair
            params.oldStair = task.stair;
            params.useOldStair = true;
            continueBlocks = ~all(task.stair.done(:)) && ~task.userQuit;
            if ~continueBlocks, params.shutDownScreen = true;  end
        else
            continueBlocks = blockNum<numBlocks && ~task.userQuit;
        end
        params.reinitScreen   = params.shutDownScreen;
    end
    
    if ~params.shutDownScreen
        % re-enable keyboard
        ListenChar(1);
        ShowCursor;
        Screen('CloseAll');
        RestoreCluts; %to undo effect of loading normalized gamma table
        
        if task.doDataPixx
            PsychDataPixx('Close');
        end
        %switch screen back to the original resolution if necessary
        if scr.changeRes
            SetResolution(scr.expScreen,scr.oldRes);
        end
    end
end

sca;

if blockNum>0
    if task.doStair
        plotStaircaseRes(task);
    else
        printPCRes(task, runData);
    end
end

