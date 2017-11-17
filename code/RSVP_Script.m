%RSVP Start Script
home; 

%% Subject details:  
subj = 'XY';

%% staircase?
staircase = true;

%% Task difficulty controlled by RSVP rate
rsvpPeriod = 0.200;  %this can be a vector of multiple values to test with method of constant stimuli (if ~staircase)

periodThreshGuess = 0.150; 

%% number of blocks
numBlocks = 4;

%% which display 
displayName = 'default'; 

%% Should we do eye-tracking?
%-1 = no checking fixation; 0 = dummy mode (cursor as eye);  1=full eyelink mode, with online fixation checking  
EYE = -1; 

%% Starting the run:
[task, runData] = RSVP_RunBlocks(subj, staircase, EYE, displayName, numBlocks, rsvpPeriod, periodThreshGuess);