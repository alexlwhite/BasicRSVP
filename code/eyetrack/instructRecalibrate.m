%TELL THE SUBJECT THAT WE NEED TO RECALIBRATE
%ALSO, PRESSING "q" INSTEAD OF SPACE BAR WILL END THE EXPERIMENT

function userQuit = instructRecalibrate(scr,task)


c=task.textColor;

rubber(scr,[]);

recalibText='Let''s recalibrate.';
continueButtonText='the space bar';
continueText=sprintf('Press %s.', continueButtonText);

buttons = [KbName('space') KbName('q')];
quitButton = length(buttons);

ptbDrawText(scr, recalibText, dva2scrPx(scr, 0, 2),c);
ptbDrawText(scr, continueText, dva2scrPx(scr, 0, -1),c);

Screen(scr.main,'Flip');

keyPress = 0;
while keyPress==0
   [keyPress, ~] = checkTarPress(buttons);
end

rubber(scr,[]);
Screen(scr.main,'Flip');
userQuit = keyPress==quitButton;



