function task = makeMainStim_RSVP(task, scr)

% 
% Prepares stimuli for RSVP experiment
% Makes textures of word images 
% Calculates fixation mark positions
% Creates sounds
% 
% Inputs and oututs: usual task and scr structures 

task.words.fontSize = task.letterParams.usedFontSize; 

%words center positions
task.words.posX = round(scr.centerX+scr.ppd*task.words.ecc*cosd(task.words.posPolarAngles));
task.words.posY = round(scr.centerY-scr.ppd*task.words.ecc*sind(task.words.posPolarAngles));

%initialize variable for keeping track of word tokens
task.lastTrialTargTokens = [];



%% Fixation point:
scr.fixCkRad = round(task.fixCheckRad*scr.ppd);   % fixation check radius
scr.intlFixCkRad = round(task.initlFixCheckRad*scr.ppd);   % fixation check radius, for trial start

task.fixation.posX  = scr.centerX+scr.ppd*task.fixation.ecc.*cosd(task.fixation.posPolarAngles);
task.fixation.posY  = scr.centerY-scr.ppd*task.fixation.ecc.*sind(task.fixation.posPolarAngles);

%Fixation mark is a dot on top of a cross on top of a disc. The cross
%dimming is the target in the localizer fixation task. 
%1. Disc
discDiameterPix = round(scr.ppd*task.fixation.discDiameter);
rad = round(discDiameterPix/2); 
%rect: left top right bottom
task.fixation.discRect = [-1 -1 1 1]*rad;

%2. Cross 
angles = [0 90];
allxy = [];
for ai = 1:2
    startx = -scr.ppd*0.5*task.fixation.crossLength*cosd(angles(ai));
    endx = scr.ppd*0.5*task.fixation.crossLength*cosd(angles(ai));
    starty = -scr.ppd*0.5*task.fixation.crossLength*sind(angles(ai));
    endy =  scr.ppd*0.5*task.fixation.crossLength*sind(angles(ai));
    
    newxy = [startx endx; starty endy];
    
    allxy = [allxy newxy];
end
task.fixation.crossXY = allxy;

%3. Dot
task.fixation.dotDiamPix = round(scr.ppd*task.fixation.dotDiameter);



%% eyetracking 
task.fixCkRad = round(task.fixCheckRad*scr.ppd);   % fixation check radius
task.intlFixCkRad = round(task.initlFixCheckRad*scr.ppd);   % fixation check radius, for trial start


%% Text
Screen('TextFont',scr.main,task.fontName);
Screen('TextSize',scr.main,task.textSize);
Screen('TextStyle',scr.main,0);

%% %%%%%  Sounds
task = prepSounds(task);

%% unify keynames for different operating systems
KbName('UnifyKeyNames');
