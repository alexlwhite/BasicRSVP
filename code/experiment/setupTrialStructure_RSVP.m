%% function trialStruct = setupTrialStructure_RSVP(task)
% This function returns a structure called trialStruct to "task", which
% defines the segments of each trial. Each segment is given a name in the
% cell array trialStruct.segmentNames, and a duration in
% trialStruct.durations. There also vectors that define whether to check for fixation breaks (trialStruct.checkEye) 
% of keypresses (trialStruct.checkResp) during each segment. Another vector
% (doMovie) specifies any segments during which the screen needs to be
% continuously updated, as in a movie. 
% 
% task.trialStruct is used by the Trial function to determine what stimuli
% present and one. 
% 
% 
function trialStruct = setupTrialStructure_RSVP(task)

%% setup segments
%initial segments before RSVP stream starts:
preRSVPSegmentNames = {'ITI'}; 
%segments that come after the RSVP stream 
postRSVPSegmentNames = {'responseDelay','response'};

%count the segments: 
nRSVPSegs = task.RSVP.length + task.RSVP.blanks*(task.RSVP.length-1);
totalNSegs = numel(preRSVPSegmentNames) + numel(postRSVPSegmentNames) + nRSVPSegs;


%Add each RSVP frame (and intervening blanks, if therea are any)
%indices of segments with RSVP frames in them:
segmentsToDrawRSVP = zeros(1,task.RSVP.length);
%indices of segments with intervening blanks in them:
segmentsToDrawBlanks = NaN(1,task.RSVP.length-1);
%For each segment, this lists the RSVP frame to be drawn
RSVPFrameNumsBySegment = NaN(1,totalNSegs);

RSVPSegmentNames = {};
segmentCounter = numel(preRSVPSegmentNames);
for i=1:task.RSVP.length
    %add the RSVP frames: 
    segmentCounter = segmentCounter + 1;
    RSVPSegmentNames = cat(2,RSVPSegmentNames,sprintf('Frame%i',i)); 
    segmentsToDrawRSVP(i) = segmentCounter;
    RSVPFrameNumsBySegment(segmentCounter) = i;
    
    %Add any blanks between frames: 
    if task.RSVP.blanks && i<task.RSVP.length
        RSVPSegmentNames = cat(2,RSVPSegmentNames,sprintf('Blank%i',i));
        segmentCounter = segmentCounter + 1;
        segmentsToDrawBlanks(i) =segmentCounter;
    end
end

%Concatenate all the segments together: 
segmentNames = cat(2,preRSVPSegmentNames,RSVPSegmentNames,postRSVPSegmentNames);
nSegments = numel(segmentNames);

trialStruct.responseDelaySegmentI = strcmp(segmentNames,'responseDelay');
trialStruct.responseSegmentI = strcmp(segmentNames,'response');

%% Set durations of each segment 
durations = zeros(1,nSegments);
for segI = 1:nSegments
    if any(segI==segmentsToDrawRSVP)
        durations(segI) = task.durations.RSVPFrame;
    elseif any(segI == segmentsToDrawBlanks) && task.RSVP.blanks
        durations(segI) = task.durations.RSVPBlank;
    else
        eval(sprintf('durations(segI) = task.durations.%s;',segmentNames{segI}));
    end
end

%% Set whether to check eye, keypress, etc
checkEye = false(1,nSegments); %whether to check for fixation breaks; only during RSVP
checkEye(segmentsToDrawRSVP) = 1;
if task.RSVP.blanks
    checkEye(segmentsToDrawBlanks) = 1;
end

checkResp = false(1,nSegments); %whether to check for manual response; only during response interval
checkResp(trialStruct.responseSegmentI) = 1;


doMovie = false(1,nSegments); %in case some segments are 'movies' that need updating every frame

%% save
trialStruct.segmentNames            = segmentNames;
trialStruct.durations               = durations;
trialStruct.nSegments               = nSegments;

trialStruct.checkEye                = checkEye;
trialStruct.checkResp               = checkResp;
trialStruct.doMovie                 = doMovie;

trialStruct.RSVPFrameSegmentIs      = segmentsToDrawRSVP;
trialStruct.RSVPBlankSegmentIs      = segmentsToDrawBlanks;
trialStruct.RSVPFrameNumsBySegment  = RSVPFrameNumsBySegment;

