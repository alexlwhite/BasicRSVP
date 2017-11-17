%% function params = RSVP_Params
% Creates a structure containing parameters for RSVP experiment, which
% should be held constant in all blocks. 

function params = RSVP_Params

%% Background luminance 
params.bgLum                    = 1; 

%% WORDS/LETTERS
params.words.fontName           = 'Courier';

params.words.sizeByFont          = true;
params.words.fontSize            = 28; %in case sizeByFont is true
params.words.goalLetterHeightDeg = 1.1; %in case sizeByFont is false, we try to set size according to degrees visual angle

params.words.contrast            = -1;
if params.bgLum>0
    params.words.lum            = params.bgLum+params.words.contrast*params.bgLum;
else
    params.words.lum            = 1*params.words.contrast;
end
params.words.color              = ones(1,3)*round(params.words.lum*255);
params.words.antiAlias          = 0;
params.words.ecc                = 0; %eccentricity of words
params.words.posPolarAngles     = 0; %polar angle of word center positions. Can be a vector. 

%Load stimulus set
params.words.listFile = 'LivingNonlivingWordSet4c.xlsx';
[w,c,n,l] = readWordList(params.words.listFile);
ncat = numel(c);
params.words.nCatgr = ncat;
params.words.nTokens = n(1);
params.words.lexicon = w; 
params.words.categories = c;
params.words.lengths = l;
params.words.meanLengths = mean(l,1);

%% RSVP stream 
params.RSVP.length = 6; 
params.RSVP.blanks = false; %whether there are any blanks betweeen the RSVP frames 
params.RSVP.stimToBlankDurRatio = 1; %if equal to 1, then stimuli and intervening blanks are equal in duration


%% FIXATION MARK 
%  Dot on top of a cross on top of a disc (Gegenfurtner style ABC) 
params.fixation.ecc              = 0;
params.fixation.posPolarAngles   = 0;

%Disc
params.fixation.discDiameter     = 0.35;
params.fixation.discColor        = [255 255 255]; 

%Cross
params.fixation.crossWidth      = 2;   %pix 
params.fixation.crossLength     = params.fixation.discDiameter; %dva 
%cross colors: 2 rows: 1=base; 2=decrement;
params.fixation.baseColor   = [0 0 0];
params.fixation.crossColors = [params.fixation.baseColor; 200 200 200];

%Dot
params.fixation.dotDiameter      = 0.1;  
params.fixation.dotType          = 2; % 0 (default) squares, 1 circles (with anti-aliasing), 2 circles (with high-quality anti-aliasing, if supported by your hardware). If you use dot_type = 1 you'll also need to set a proper blending mode with the Screen('BlendFunction') command!
%dot colors for feedback: 1=base; 2=miss, 3=hit; 4=false alarm, 
params.fixation.dotColors = [params.fixation.discColor; 255 90 90; 100 255 100; 225 225 0];


%% Timing parameters
params.time.startRecordingTime  = 0.100; % time to wait after initializing eyelink recording before continuing 
params.time.timeAfterKey        = 0.300; % recording time after keypress [s]

params.time.responseDelay       = 0.500; 
params.time.response            = inf; 
params.time.ITI                 = 1; 

%Tolerance in rounding off durations to be in multiples of monitor frame
%duration. If rounding up would make an error less than this tolerance,
%then round up. Otherwise, round down. 
params.durationRoundTolerance = 0.0026; 

%To precisely control timing, determine when frame flips are asked for 
params.flipperTriggerFrames = 1.25;  %How many video frames before desired stimulus time should the screen Flip command be executed 
params.flipLeadFrames = 0.5;        %Within the screen Flip command, how many video frames before desired time should flip be asked for 

%If period adjusted by staircase, set limits: 
params.maxPeriod = 2; %seconds
params.minPeriod = 0.009; %seconds


%% Staircases 
stair.nTypes             = 1; %number of conditions with separate staircases
stair.nPerType           = 2; %number of interlevaed staicases per type
stair.stairType          = 2;

if stair.stairType == 1
    
    %Quest staircase
    stair.threshLevel        = 0.75; 
    stair.trialsIgnored      = 5;
    stair.inLog10            = true; 
    stair.gamma              = 0.5;
    stair.beta               = 3;
    stair.delta              = 0.03; 
    stair.threshSDStartGuess = .12; %in units of dSat
    stair.minNTrials         = 40;

elseif stair.stairType == 2
    
    %transformed, weighted up-down staircase    

    stair.nUp                = 1;
    stair.nDn                = 1;
    stair.inLog10            = true;
    stair.dnUpStepRatio      = 1/3; %0.2845; %following Garcia-Perez, 1998; this is one of the few settings that works
    stair.stepUp             = log10(0.052)-log10(0.00833); %in log units
    stair.stepDn             = stair.stepUp*stair.dnUpStepRatio;
    stair.threshLevel        = (stair.stepUp/(stair.stepUp+stair.stepDn))^(1/stair.nDn);
    stair.stopCriterion      = 'reversals';
    stair.stopRule           = 8;
    stair.truncate           = 'yes';
    stair.revsToReduceStep   = [1];
    stair.minRevsForThresh   = 3; 
    stair.revsToIgnore       = max(stair.revsToReduceStep);
    stair.trialsIgnoredThresh= 5; 
    stair.reduceStepSize     = true;
    stair.minNTrials         = 40;
    stair.trialsIgnored      = 4;
    
else
    %SIAM staircase
    stair.t                   = 0.5;  %desired maximum reduced hit rate (HR-FAR)
    stair.startStep           = log10(0.09)-log10(0.05);
    stair.nRevToStop          = 6;     %number of "good" reversals with stable step size before terminating 
    stair.revsToHalfContr     = [1]; %on which reversals to halve step size, starting from first trial or starting just after step size reset 
    stair.revsToReset         = 100;   %on which reversals to reset, in case staircase continues
    stair.nStuckToReset       = 5;     %the number of sequential hits all at the same intensity at which step size is reset  
    stair.threshType          = 1;     % 1 (for reversal values) or 2 (for all intensity values)
    stair.inLog10             = true;
    stair.trialsIgnored       = 2; 
    
    stair.terminateByReversalCount   = true;
end

stair.trialsStairIgnores = 2;

params.stair = stair;
%% Eyetracking 
% initlFixCheckRad: 
% if just 1 number, it's the radius of circle in which gaze position must land to start trial. 
% if its a 1x2 vector, then it defines a rectangular region of acceptable
% gaze potiion. 
% Then new fixation position is defined as mean gaze position in small time window at trial start 

params.initlFixCheckRad         = [0.75 3];  
params.fixCheckRad              = [1 2]; % radius of circle (or dims of rectangle) in which gaze position must remain to avoid fixation breaks. [deg]
params.horizOnlyFixCheck        = false; %whether to abort only if horizontal position of eye exceeds fixCheckRad(1)
params.maxFixCheckTime          = 0.500; % maximum fixation check time before recalibration attempted 
params.minFixTime               = 0.200; % minimum correct fixation time
params.nMeanEyeSamples          = 10;    %number of eyelink samples over which to average gaze position to determine new fixation point 
params.calibShrink              = 0.6;   %shrinkage of calibration area in vertical dimension (horizontal is adjusted further by aspect ratio to make square
params.squareCalib              = false;  %whether calibration area should be square 


%% TEXT
params.fontName                 = params.words.fontName;
params.textColor                = [0 0 0]; %round([1 1 1]*params.words.lum*255); %for instructions etc
params.textSize                 = 32;
params.instructTextSize         = 20; 
params.textAntialias            = 1;

%% Feedback
params.feedback                 = true;
params.blockEndFeedback         = false;

%Feedback Sounds
params.sounds(1).name             = 'responseTone'; 
params.sounds(2).name             = 'correctTone'; 
params.sounds(3).name             = 'incorrectTone';
params.sounds(4).name             = 'targetTone'; %to be played simultaneous with target 
params.sounds(5).name             = 'fixBreakTone'; 

params.sounds(1).toneDur         = 0.050; 
params.sounds(2).toneDur         = 0.075; 
params.sounds(3).toneDur         = 0.075; 
params.sounds(4).toneDur         = 0.033;
params.sounds(5).toneDur         = 0.150; %this is actually 2 incorrect tones concatenated 

params.sounds(1).toneFreq        = 400; 
params.sounds(2).toneFreq        = 600; 
params.sounds(3).toneFreq        = 180; 
params.sounds(4).toneFreq        = 675; 
params.sounds(5).toneFreq        = 180; %this is actually 2 incorrect tones concatenated 

params.soundsOutFreq             = 48000; %output sampling frequency 
params.soundsBlankDur            = 0;  %amount of blank time before sound signal starts 

params.doDataPixx               = false;


%% Trials 

params.numTrials        = 60; %trials per block
params.practiceNTrials  = 12; %trials per practice block
params.nTrialsLeftRepeatAbort      = 2; %number of trials that must be left in a block to add an aborted trial to the end

params.MRI = false;


