function [task, td] = resetRSVPTiming(RSVPPeriod, task, td, scr)

%Add in the new duration of RSVP frames (and intervening blanks):
if task.RSVP.blanks
    RSVPBlank = RSVPPeriod/(1+task.RSVP.stimToBlankDurRatio);
    RSVPFrame = RSVPPeriod - RSVPBlank;
    
    task.trialStruct.durations(task.trialStruct.RSVPBlankSegmentIs) = durtnMultipleOfRefresh(RSVPBlank,scr.fps,task.durationRoundTolerance);
    td.RSVPBlankDur = task.durations.RSVPBlank;
else
    RSVPFrame = RSVPPeriod;
end
task.trialStruct.durations(task.trialStruct.RSVPFrameSegmentIs) = RSVPFrame;
td.RSVPFrameDur = task.durations.RSVPFrame;
td.RSVPPeriod = durtnMultipleOfRefresh(RSVPPeriod,scr.fps,task.durationRoundTolerance);