function drawFixation_RSVP(task,scr,posI,crossColorI,dotColorI)
% Draws a dot with a ring around it 
% 
% Inputs: 
% - task and scr: standard structures 
% - posI: index of fixation position, from which to pull out  coordinates 
%  from task.fixation.posX and task.fixation.posY
% - innerColorI: index of color for inner dot, to pull out a row from
%   task.fixation.colors
% - outerColorI: index of color for outer ring, to pull out a row from
%   task.fixation.ringColors

xy = [task.fixation.posX(posI); task.fixation.posY(posI)];

%1. Draw disc
discRect = task.fixation.discRect+[xy' xy'];
Screen('FillOval',scr.main, task.fixation.discColor, discRect);

%2. Draw cross
Screen('DrawLines',scr.main, task.fixation.crossXY, task.fixation.crossWidth, task.fixation.crossColors(crossColorI,:), xy',2);

%3. Draw dot
Screen('DrawDots', scr.main, xy, task.fixation.dotDiamPix, task.fixation.dotColors(dotColorI,:), [], task.fixation.dotType);
