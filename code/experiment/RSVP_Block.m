%% [task, data] = RSVP_Block(params, scr)
% Runs 1 main block of trials and saves data.
%
%
% Inputs:
% - params: structure with various fields about what ought to happen this block.
%  This later gets merged with the params returned by RSVP_Params, and
%  renamed "task".
% - scr: screen structure, which could allow you to run this from a PTB screen
%   that's already opened. If no screen is open yet, set scr to []. 
%
% Outputs:
% - task: big structure about stimuli, task & responses
% - scr: structure about screen
%
% by Alex L. White, November 2017, at the University of Washington

function [task, scr] = RSVP_Block(params, scr)

%% Load parameters
task = catstruct(params, RSVP_Params);
task.openSecondWindow = false; %wheher to open a second PTB window and leave it blank, if there are two screens not mirrored


%% RESET RANDOM NUMBER GENERATOR
task.initialSeed = ClockRandSeed;
task.startTime=clock;


%% Initialize Screen and response buttons
if task.reinitScreen
    [scr, task] = prepScreen_RSVP(task);
else %set this bgColor variable
    if scr.normalizedLums
        task.bgColor = task.bgLum;
    else
        task.bgColor = floor(task.bgLum*(2^scr.nBits));
    end
end

if task.EYE == 0 %dummy mode
    ShowCursor;
else
    HideCursor(scr.main);
end

% get response keys
buttons = getKeyAssignment_RSVP(task);
task.respButtons = buttons.resp;
task.buttons = buttons;

% disable keyboard
ListenChar(2);

% keyboard set up
KbName('UnifyKeyNames');

%% Set paths and data storage:
task.codePath = RSVP_base();
task.projPath = fileparts(task.codePath);
task.dataPath = fullfile(task.projPath,'data');

thedate=date;
folderdate=[task.subj thedate(4:6) thedate(1:2)];
task.subjDataFolder = fullfile(task.dataPath,task.subj,folderdate);
if task.practice
    task.subjDataFolder = fullfile(task.subjDataFolder,'practice');
end
if ~isdir(task.subjDataFolder)
    mkdir(task.subjDataFolder);
end

% Set where to call this block's data file data
[fullFileName, eyelinkFileName, task] = setupDataFile_RSVP(task.blockNum, task);
task.dataFileName = fullFileName;
%Extract the name of this m file
[st,i] = dbstack;
scr.codeFilename = st(min(i,length(st))).file;
task.codeFilename = scr.codeFilename;


%% get word images
%make sure we have some stimuli for this display. If not, see the scripts
%in code/stimuli/
imageFolder = sprintf('images_%s',task.displayName);
task.imagePath = fullfile(task.projPath,fullfile('images',imageFolder));
imageParamFile = fullfile(task.imagePath,'wordImageParams.mat');
if ~exist(imageParamFile,'file')
    error('(RSVP_Runblock) No images made for this display (%s)!',imageFolder);
end
%load word image params
load(imageParamFile,'imageParams');
task.imageParams = imageParams;

letterFile = fullfile(task.imagePath,'letters.mat');
if ~exist(letterFile,'file')
    error('\n(RSVP_Runblock) Warning: no letters made for this display\n');
end
load(letterFile);
task.letterParams = letterParams;
task.letterFile = letterFile;

%% make stimuli (colors, positions, etc)
task = makeMainStim_RSVP(task, scr);

%% setup staircase
if task.doStair
    %load staircase parameters depending on the type:
    if ~task.useOldStair
        task.stair.maxIntensity = task.maxPeriod;
        
        %make sure that the minimum RSVP period is at least 1 frame:
        if task.minPeriod < scr.fd
            task.minPeriod = scr.fd+0.001; 
        end
        task.stair.minIntensity = task.minPeriod;
        
        task.stair.threshStartGuess = task.periodThreshGuess*[0.75 1.25];
        
        task.stair.threshStartGuess(task.stair.threshStartGuess>task.stair.maxIntensity) = task.stair.maxIntensity;
        task.stair.threshStartGuess(task.stair.threshStartGuess<task.stair.minIntensity) = task.stair.minIntensity;
        task = setupStairs(task);
    else
        task.stair = task.oldStair;
    end
end

%% set what to do in practice
if task.practice
    task.rsvpPeriod = task.practiceRSVPPeriod;
    task.numTrials = task.practiceNTrials;
    task.doStair = false; %don't run staircase in practice
end

%% Timing Parameters
fps = scr.fps;
task.fps = fps;

%You can input more than 1 value of rsvpPeriod, in which case this is the
%method of constant stimuli, and there will be an equal number of trials
%with each period duration
task.constantStimuli_RSVPPeriods = ~task.doStair && length(task.rsvpPeriod)>1;
%For now, if that is true, we'll just initialize everything with the first value

%Add duration of RSVP frames (and intervening blanks):
task.time.rsvpPeriod = task.rsvpPeriod;

if task.RSVP.blanks
    %if there are multiple rsvpPeriod values, for not just take the first
    %one. Later it's reset for each trial
    task.time.RSVPBlank = task.time.rsvpPeriod(1)/(1+task.RSVP.stimToBlankDurRatio);
    task.time.RSVPFrame = task.time.rsvpPeriod(1) - task.time.RSVPBlank;
else
    task.time.RSVPFrame = task.time.rsvpPeriod(1);
end

%SET EACH TIMING PARAM TO MULTIPLE OF FRAME DURATION
%...and add them to structure task.durations:
tps = fullFieldnames(task.time);
for ti = 1:numel(tps)
    tv = tps{ti};
    eval(sprintf('task.durations.%s = durtnMultipleOfRefresh(task.time.%s, fps, task.durationRoundTolerance);', tv, tv));
end


%% Parameters for each trial
% parameters: variables to be counterblanced
design.parameters.targPres = [0 1];
design.parameters.RSVPPeriod = task.durations.rsvpPeriod;
design.parameters.RSVPFrameDur = task.durations.RSVPFrame;
if task.RSVP.blanks
    design.parameters.RSVPBlankDur = task.durations.RSVPBlank;
end

%uniformRandvars: variables that don't need to be counterbalanced
design.uniformRandVars.targTime = 1:task.RSVP.length;
if task.doStair
   design.uniformRandVars.stairNumber = 1:task.stair.nTypes;
   design.uniformRandVars.subStaircaseNum  = 1:task.stair.nPerType;
end

% Make pseudo-random trial order:
task = makeTrialOrder(design, task);

%% setup trial structure (things that don't change across trials, like segment durations)
task.trialStruct = setupTrialStructure_RSVP(task);

%% initialize data structure
task = initializeData_RSVP(task);

%% set up stimuli for each trial's RSVP stream
task = chooseBlockStim_RSVP(task,scr);

%% %%%%%%%%%%%%%%%%
% Initialize eyelink and calibrate tracker
%%%%%%%%%%%%%%%%%%
if task.EYE >= 0
    [el, elStatus] = initializeEyelink(eyelinkFileName, task, scr);
    
    if task.EYE > 0
        if elStatus == 1
            fprintf(1,'\nEyelink initialized with edf file: %s.edf\n\n',eyelinkFileName);
        else
            fprintf(1,'\nError in connecting to eyelink!\n');
        end
    end
    
    if task.EYE > 0
        calibrateEyelink(el, task, scr);
    end
    WaitSecs(0.3);
else
    el = [];
end

task.eyelinkIsRecording = false;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Instructions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if task.EYE == 0 %dummy mode
    ShowCursor;
else
    HideCursor(scr.main);
end


blockStartInstructions_RSVP(task,scr);
task.tBlockStart = GetSecs;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trial loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ti = 0; %counter of trials
nTrials = task.numTrials;
doRunTrials = true;
while doRunTrials
    ti = ti +1;
    
    %% Determine what will happen on this trial
    %extract trial structure from design: 
    td = task.design.trials(ti);
    
    %set stimulus level if doing staircase
    if task.doStair
        newPeriod = pickStaircaseStimLevel(task,td);
        [task, td] = resetRSVPTiming(newPeriod,task,td,scr);
    %or if doing method of constant stimuli with many possible intensity
    %values: 
    elseif task.constantStimuli_RSVPPeriods
        [task, td] = resetRSVPTiming(td.RSVPPeriod,task,td,scr);
    end
        
    %% Prepare fixation
    %draw fixation if 1st trial (b/c preTrialEyetrackerSetup no longer does)
    if ti==1
        %Draw fixation 
        fixPos = 1;
        crossColorI = 1; dotColorI  = 1;
        drawFixation_RSVP(task,scr,fixPos,crossColorI,dotColorI);
        Screen('Flip',scr.main)
    end
    
    %start eyelink recording and establish fixation
    if task.EYE>-1
        [el, task, quitDuringRecalib, didRecalib] = preTrialEyetrackerSetup(el,task,scr,ti,nTrials);
    else
        quitDuringRecalib = false; didRecalib = false; task.eyelinkIsRecording = false;
    end
    
    %% RUN TRIAL
    [trialRes, task] = RSVP_Trial(scr,task,td);
    
    
    %% Extract data
    data = catstruct(td,trialRes);
    data.didRecalib = didRecalib;
    data.quitDuringRecalib = quitDuringRecalib;
    data.overallTrialNum = ti;
    ds = fieldnames(data);
    for di = 1:numel(ds)
        %check if this one was not initialized in initializeData function
        if ti==1 && ~isfield(task.data,ds{di})
            eval(sprintf('task.data.%s = task.emptyMat;',ds{di}));
        end
        eval(sprintf('task.data.%s(ti) = data.%s;',ds{di},ds{di}));
    end
    
    %if fixbreak, and this is behavioral testing, add that trial back at the end
    if ~trialRes.trialDone && ~task.MRI && ti<=(nTrials-task.nTrialsLeftRepeatAbort)
        nTrials = nTrials + 1;
        task.design.trials(nTrials) = td;
    end
    
    %update staircase
    if task.doStair && trialRes.trialDone && ti>task.stair.trialsStairIgnores
        [task] = updateStaircase(task, td, trialRes);
        terminateByStair = all(task.stair.done(:));
      
    else
        terminateByStair = false;
    end
    
    doRunTrials = (ti < nTrials) && ~trialRes.userQuit && ~quitDuringRecalib && ~terminateByStair;
end



if terminateByStair, task.shutDownScreen = true; end
task.endOfTrials = GetSecs;

%Close textures (all at once)
alltex = task.tex(:);
Screen('Close',alltex(~isnan(alltex)));



%% collect remaining data
task.tBlockEnd = GetSecs;
task.trialsCompleted = ti;
task.blockDuration =  task.tBlockEnd - task.tBlockStart;
task.userQuit = trialRes.userQuit;
task.teriminatedByStair = terminateByStair;

%analyze overall accuracy
task.res.pc = nanmeanAW(task.data.respCorrect(:));


%% End eye-movement recording
if task.eyelinkIsRecording
    Screen(el.window,'FillRect',el.backgroundcolour);   % hide display
    WaitSecs(0.1);Eyelink('stoprecording');             % record additional 100 msec of data end
    Eyelink('command','clear_screen');
    Eyelink('command', 'record_status_message ''ENDE''');
end

rubber(scr,[]);
Screen(scr.main,'Flip');

task.endTime = clock;
task.el      = el;


%% Shut down screen

% shut down everything, get EDF file
reddUp(task.shutDownScreen, task, scr);

%move edf file to data folder
if task.EYE>0
    [success message] = movefile(sprintf('%s.edf',task.eyelinkFileName),sprintf('%s.edf',task.dataFileName));
end
fprintf(1,'\nThis part of the experiment took %.3f min.\n\n',task.blockDuration/60);

%% if staircase, analyze
if task.doStair
    task = extractStaircaseData(task);
end

%% print p(correct):
fprintf(1,'\nBlock %i: p(correct) = %.2f',task.blockNum, task.res.pc);


%% save files
save(sprintf('%s.mat',fullFileName),'task','scr');
fprintf(1,'\n\nSaving data mat files to: %s.mat\n',fullFileName);


