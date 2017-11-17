%% function calibrateEyelink(el, task, scr)
% Runs EyelinkDoTrackerSetup, and takes care not to mess up screen
% calibraiton. That means re-setting some Screen parameters after Eyelink
% takes control of it. 

function calibrateEyelink(el, task, scr)

calibresult = EyelinkDoTrackerSetup(el);
if calibresult==el.TERMINATE_KEY
    return
end

%Re-set some aspects of screen in case eyelink calibration messed withit
Screen('Preference', 'TextAntiAliasing', task.textAntialias);    % need text in binary colors for my cluts
Screen('TextFont',scr.main,task.fontName);
Screen('TextSize',scr.main,task.textSize);
Screen('TextStyle',scr.main,0);

%also need to re-load normalized gamma table.
%eyelink calibration seems to screw with it
BackupCluts;
if isfield(scr.displayParams,'normlzdGammaTable')
    ngt = scr.displayParams.normlzdGammaTable;
else
    ngt = [];
end
if ~isempty(ngt)
    if size(ngt,2)==1
        ngt = repmat(ngt,1,3);
        fprintf(1,'\n(prepScreen) Calibration normalized gamma table has only 1 column. \n Assuming equal for all 3 guns\n.');
    end
    Screen('LoadNormalizedGammaTable',scr.main,ngt);
    fprintf(1,'\n(prepScreen) Loaded calibration file normalized gamma table for: %s\n',scr.displayParams.monName);
else %defaults if no calibration file
    fprintf(1,'\n\n(prepScreen) NO CALIBRATED NORMALIZED GAMMA TABLE FOR THIS DISPLAY\n\n');
end

Screen('Flip',scr.main);                       	% flip to erase