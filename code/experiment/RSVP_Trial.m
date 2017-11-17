function [trialRes, task] = RSVP_Trial(scr,task,td)
% Runs a single trial of the RSVP experiment.
% Alex L. White, 2017

%% prep
% clear keyboard buffer
FlushEvents('KeyDown');

if task.EYE>-1
    % predefine gaze position boundary information
    cxm = task.fixation.newX(1); %Desired fixation position, defined on each trial
    cym = task.fixation.newY(1);
    chk = task.fixCkRad;
    
    circleCheck = length(chk)==1; %if fixation check is a circle or rectangle
    
    ctrx = scr.centerX; ctry = scr.centerY;  ctrpx = 3;
    
    % draw trial information on EyeLink operator screen
    Eyelink('command','clear_screen 0');
    
    Eyelink('command','draw_filled_box %d %d %d %d 15', round(ctrx-ctrpx), round(ctry-ctrpx), round(ctrx+ctrpx), round(ctry+ctrpx));    % fixation
    if circleCheck
        Eyelink('command','draw_filled_box %d %d %d %d 15', round(cxm-chk/8), round(cym-chk/8), round(cxm+chk/8), round(cym+chk/8));    % fixation
        Eyelink('command','draw_box %d %d %d %d 15', cxm-chk, cym-chk, cxm+chk, cym+chk);                   % fix check boundary
    else
        Eyelink('command','draw_filled_box %d %d %d %d 15', round(cxm-chk(1)/8), round(cym-chk(2)/8), round(cxm+chk(1)/8), round(cym+chk(2)/8));    % fixation
        Eyelink('command','draw_box %d %d %d %d 15', cxm-chk(1), cym-chk(2), cxm+chk(1), cym+chk(2));                   % fix check boundary
    end
end

%pull out trialStruct, which has some useful info
ts = task.trialStruct;

%% Run the trial: continuous loop that advances through each section

tTrialStart      = GetSecs;

%Initialize counters for trial events:
segment          = 0; %start counter of segments
fri              = 0; %counter of movie frames
segStartTs       = NaN(size(ts.durations));
keyPressed       = NaN;
respCorrect      = NaN;
respPres         = NaN;
pressedWrongSide = false;
tResTone         = NaN;
tRes             = NaN;
tFeedback        = NaN; 
fixBreak         = 0;
nFixBreaks       = 0;
tFixBreak        = NaN;
nPressedQuit     = 0; %number of times subject presssed quit. 2 to abort

if any(ts.doMovie)
    frameTimes = NaN(1,ts.framesPerMovie);
end


if task.EYE>=0
    Eyelink('message', 'Trial_START %d', td.trialNum);
    Eyelink('message', 'SYNCTIME');		% zero-plot time for EDFVIEW
end

t = tTrialStart;

goalStartTime = tTrialStart;

updateSegment = true; %start 1st segment immediately

doStimLoop = true;

while doStimLoop
    % Time counter
    if segment > 0
        t = GetSecs-segStartTs(segment);
        %update segment if this segment's duration is over, and it's not the last one
        updateSegment = t>(ts.durations(segment)-scr.flipTriggerTime) && segment < ts.nSegments;
    end
    
    if updateSegment
        lastSeg = segment;
        doIncrement = segment < ts.nSegments;
        while doIncrement
            segment = segment + 1;
            %stop at the last segment, and skip segments with duration 0:
            doIncrement = segment < ts.nSegments && ts.durations(segment) == 0;
        end
        
        segmentName = ts.segmentNames{segment};
        thisSegKeyPressed = false;
        thisSegFixBreak   =  false;
    end
    
    %update screen at switch of segment or if we're drawing the movie
    updateScreen = updateSegment || (ts.doMovie(segment) && fri < task.framesPerMovie);
    
    if updateScreen
        if ~ts.doMovie(segment)
            if segment == 1 %immediately start first segment
                goalFlipTime = goalStartTime;
            else
                goalFlipTime = segStartTs(lastSeg) + ts.durations(lastSeg) - scr.flipLeadTime;
            end
        else
            fri = fri+1; %update movie frame counter
            if fri==1
                goalFlipTime = segStartTs(lastSeg) + ts.durations(lastSeg) - scr.flipLeadTime;
            else
                goalFlipTime = frameTimes(fri-1)+ts.movieFrameDur - scr.flipLeadTime;
            end
        end
                
           
        %WHAT TO DO IN EACH SEGMENT: 
        %RSVP frames
        if any(segment == ts.RSVPFrameSegmentIs)
            %draw images!
            RSVPFrameNum = ts.RSVPFrameNumsBySegment(segment);
            Screen('DrawTexture', scr.main, task.tex(td.trialNum,RSVPFrameNum), [], squeeze(task.texRects(td.trialNum,RSVPFrameNum,:)));
        
            %RSVP Blanks
        elseif any(segment == ts.RSVPBlankSegmentIs)
            %draw nothing during blanks
        
        %Other segments: 
        else
            %Draw fixation:
            fixPos = 1; crossColorI = 1; dotColorI  = 1;
            drawFixation_RSVP(task,scr,fixPos,crossColorI,dotColorI);
            
            switch segmentName
                case 'response'
                    %play a click to tell the subject that they can now respond
                    if isnan(tResTone) 
                        tResTone = playPTB_DataPixxSound(1,task);
                    end
                    
              %Could put other useful things in different segments here too
            end
        end
        
        %FLIP THE SCREEN::
        Screen(scr.main,'DrawingFinished');
        tFlip = Screen('Flip', scr.main, goalFlipTime);
        
        if ts.doMovie(segment)
            frameTimes(fri) = tFlip;
        end
        if updateSegment
            segStartTs(segment) = tFlip;
            %send some eyelink messages
            if task.EYE==1 
                if ts.RSVPFrameNumsBySegment(segment) == 1
                    Eyelink('message', 'EVENT_RSVPFrame1Onset');
                elseif ts.responseDelaySegmentI(segment)==1
                    Eyelink('message', 'EVENT_RSVPEnd');
                elseif task.trialStruct.responseSegmentI(segment)
                    Eyelink('message', 'EVENT_ResponseIntervalOnset');
                end
            end
           
        end
    end
    
    %Check for keypress
    if ts.checkResp(segment)
        [keyPressed, tKey] = checkTarPress(task.buttons.resp);
        
        %determine whether this was the correct response given task events (and
        %this was the first time keypress detected
        if keyPressed>0 && ~thisSegKeyPressed
            if keyPressed ~= task.buttons.quit
                tRes = tKey;
                
                if td.targPres
                    respCorrect = any(keyPressed == task.buttons.pres);
                    respPres = respCorrect;
                else
                    respCorrect = any(keyPressed == task.buttons.abst);
                    respPres = ~respCorrect;
                end
               
                thisSegKeyPressed = true;
                %feedback beep
                if task.feedback
                    tFeedback = playPTB_DataPixxSound(2+~respCorrect,task);
                end
                
            else %subject pressed quit key
                nPressedQuit = nPressedQuit + 1;
                WaitSecs(0.3); %wait a bit
            end
            
            %SELF-PACED BLOCK:
            %if one of the correct keys was pressed, set duration of this segment so that it ends immediately
            if keyPressed ~= task.buttons.quit || (nPressedQuit>1) %end if they press quite twice
                ts.durations(segment) = t;
            end
            
        end
    end
    
    %Check eye position
    if task.EYE >= 0 && ts.checkEye(segment)
        [x,y] = getCoord(scr, task);
        %if either eye is outside of fixation region, count as fixation break
        if circleCheck
            badeye = any(sqrt((x-cxm).^2+(y-cym).^2)>chk);
        else
            if task.horizOnlyFixCheck
                %fixation break only if horizontal position is a valid number but deviates too
                %much, and vertical position does NOT deviate. In other words, only if observer looks horizontally at the words.
                %The goal here is to allow blinks.
                badeye = any(abs(x-cxm)>chk(1)) && ~isnan(x) && x>0 && x<scr.xres && any(abs(y-cym)<chk(2)) && ~isnan(y) && y>0 && y<scr.yres;
                %this doesn't quite work because around the time of a blink, the eye position seems to deviate horizontally as well
            else
                badeye = any(abs(x-cxm)>chk(1)) || any(abs(y-cym)>chk(2));
            end
        end
        
        if badeye
            fixBreak = true;
            if ~thisSegFixBreak
                nFixBreaks = nFixBreaks+1;
                thisSegFixBreak = true;
            end
            tFixBreak = GetSecs;
            if task.EYE==1, Eyelink('message', 'EVENT_fixationBreak'); end
            
            %If this is behavioral training, abort trial
            if ~task.MRI
                doStimLoop = false;
            end
        end
    end
    
    %Check if it's time to  break out of this stimulus presentation loop
    %if in the last segment, and its duration is within 1 frame of being over
    if segment == ts.nSegments
        doStimLoop = (GetSecs-segStartTs(segment)) < (ts.durations(segment)-scr.fd);
        doStimLoop = doStimLoop && nPressedQuit < 2; %allow to abort if user pressed q button twice
    end
end

if fixBreak  %feeback about fixation break
    
    Eyelink('command','draw_text 100 100 15 Fixation break');
    
    playPTB_DataPixxSound(5, task);
    
    Screen('TextSize',scr.main,task.instructTextSize);
    ptbDrawText(scr,'Fixation break', dva2scrPx(scr, 0, 1),task.textColor);
    ptbDrawText(scr,'Press a key to continue', dva2scrPx(scr, 0, -1),task.textColor);
    
    Screen(scr.main,'DrawingFinished'); Screen('Flip', scr.main);
    
    %Wait to get a key
    keyPressed = false;
    while ~keyPressed
        [keyPressed, tRes] = checkTarPress([task.respButtons KbName('space')]);
    end
    
    %then draw fixation and wait a bit
    crossColorI = 1;    dotColorI  = 1;
    fixPos = 1;
    drawFixation_RSVP(task,scr,fixPos,crossColorI,dotColorI);
    Screen(scr.main,'DrawingFinished'); Screen('Flip', scr.main);
    
    WaitSecs(2/3);
    trialDone = false;
else
    trialDone = true;
end

%% Save data
trialRes.tTrialStart = tTrialStart;

%save onset times of each segment
for segI = 1:ts.nSegments
    eval(sprintf('trialRes.t%sOns = segStartTs(%i) - tTrialStart;',ts.segmentNames{segI},segI));
end

trialRes.tResTone       = tResTone - tTrialStart;
trialRes.tRes           = tRes - tTrialStart;
trialRes.tFeedback      = tFeedback  - tTrialStart;
trialRes.fixBreak       = 1*fixBreak; %convert from logical to to double
trialRes.nFixBreakSegs  = nFixBreaks;
trialRes.tFixBreak      = tFixBreak;
trialRes.userQuit       = 1*(nPressedQuit>1);
trialRes.chosenRes      = keyPressed;
trialRes.respPres       = 1*respPres;
trialRes.respCorrect    = 1*respCorrect;
trialRes.trialDone      = trialDone;

%did the subject not respond in time?
trialRes.responseTimeout = trialDone & isnan(respCorrect);

%store word info:
trialRes.targTimeCatg = task.wordIndices(td.trialNum,td.targTime,2);
trialRes.targTimeToken = task.wordIndices(td.trialNum,td.targTime,1);



