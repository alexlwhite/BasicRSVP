% function task = initializeData_RSVP(task)
% This function initialies vectors in the structure task.data where each
% trial's data will be stored. The function of this is basically just to
% pre-initialize the memory space to save time later. 

function task = initializeData_RSVP(task)

tds = fieldnames(task.design.trials);
numTrials = task.numTrials;

%empty matrix 
%one row, for all trials 
emptyMat = NaN(1,numTrials);
task.emptyMat = emptyMat;


for tdi = 1:numel(tds)
    eval(sprintf('task.data.%s = emptyMat;',tds{tdi}));
end

%add segment onset times 
for segI = 1:task.trialStruct.nSegments
    eval(sprintf('task.data.t%sOns = emptyMat;',task.trialStruct.segmentNames{segI}));
end

%other data fields generated during each trials
trialVars =  {'tTrialStart','tResTone','tRes','tFeedback','fixBreak','nFixBreakSegs'...
    'tFixBreak','userQuit','chosenRes','respPres','respCorrect','trialDone',...
    'responseTimeout', 'targTimeCatg','targTimeToken'};

          
          
for tdi = 1:numel(trialVars)
    eval(sprintf('task.data.%s = emptyMat;',trialVars{tdi}));
end