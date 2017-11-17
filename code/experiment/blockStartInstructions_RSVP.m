function blockStartInstructions_RSVP(task, scr)


blockNum=task.blockNum;
totalRuns=task.numBlocks;

% clear keyboard buffer
FlushEvents('KeyDown');

%clear screen to background color
rubber(scr,[]);

Screen('TextSize',scr.main,task.instructTextSize);

continueButton = [KbName('space') task.respButtons];

c=task.textColor;
textSep=2;

if task.practice
    blockText = 'PRACTICE';
else
    blockText=sprintf('Block number %i', blockNum);
end

continueText = 'Press any key to continue';


%%%%%
%% Now actually draw all the text
vertpos = 2;
Screen('TextStyle',scr.main,0); %normal
ptbDrawFormattedText(scr.main,blockText, dva2scrPx(scr, 0, vertpos),c,true,true,false,false);

vertpos=vertpos-textSep;
Screen('TextStyle',scr.main,2); %italic
ptbDrawFormattedText(scr.main, continueText, dva2scrPx(scr, 0, vertpos),c,true,true,false,false);
Screen('TextStyle',scr.main,0); %normal

vbl=Screen(scr.main,'Flip');

keyPress = 0;
while ~keyPress
    [keyPress, dummy] = checkTarPress(continueButton);   % accept all buttons
end

rubber(scr,[]);
Screen(scr.main,'Flip');
