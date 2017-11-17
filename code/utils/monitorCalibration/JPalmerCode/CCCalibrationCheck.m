function CCCalibrationCheck
% CCCalibrationCheck
% simple routine to display a alternating bar grating to test calibration
% This grating should have the same mean luminance as the surround
% requires correct calibration file and JP's CC and EX routines
% 3/16/15   JP created CCCalibrationCheck

% display parameters and calibration file
size = 100;											% size of display in pixels
calibrationfile = 'VS95_090214.cal';                % calibration file (can also use 'default.cal' or 'unit.cal')

% get calibration info amd make Gamma correction array (inverse gamma)
cal = CCGetCalibration(calibrationfile);            % returns a structure with a variety of calibration info
gammaInverse = CCMakeInverseGamma(cal);                      % returns the table needed to do gamma correction in hardware

% set values for OpenWindow call
pixelsize = 32;                                     % use "full" color (32 bit mode)
myscreen = 0;                                       % use 0 for single monitor systems
backgroundSRGB = [.5,.5,.5];                        % calculations about color used "standardized" RGB (0-1)
backroundRGB = round(255*backgroundSRGB);           % final calls to all display routines use integer RGB (0-255)

% create graphics "window" for entire screen with a given background color and do other intialization
window=Screen(myscreen,'OpenWindow',backroundRGB,[],pixelsize);	% [] arg causes default window size (entire screen)
BackupCluts(myscreen);                              % save cluts (to be restored by sca)
Screen('LoadNormalizedGammaTable', myscreen, gammaInverse);   % this loads the gamma correction into hardware
HideCursor;                                         % hide cursor during displays
ListenChar(2);                                      % flush char buffer; remember to use cntrl-C if program aborts

% make a alternating line horizontal grating to check the calibration (same mean lum as surround
myrect = EXDefineRectangle(window,size,size,0,0);	% define rect for given size relative to center of window
mytexture = MakeTestGrating(window,size);
Screen('DrawTexture',window,mytexture,[],myrect); 	% copies info to frame buffer
DrawMyText(window,'Press any key when done',0,200,[0 0 0]);	% draw text below display in black
Screen(window,'Flip');                              % flip between two framebuffers

% wait for a new keypress (use of -3 arg required for multiple keyboard systems)
while KbCheck(-3); end;                             % wait until all keys are released.
while KbCheck(-3) == 0; end;                        % wait until a key is pressed.

% restore screen and keyboard
sca;                                                % close windows, restor cluts, show cursor 
ListenChar(0);                                      % flush char buffer; remeber to use cntrl-C if program aborts

% -------------------------------------------------------------------------------------
function mytexture = MakeTestGrating(window,size)
% image = MakeHorzontalGrating(cl,size,period,mycontrast)
% make an grating array
% pass in window and size of grating
% returns a "texture" 
% 3/15/15   JP created MakeTestGrating 

for i = 1:2:size;
    a(i) = 1;
    a(i+1) = 0;
end;

image0 = meshgrid(a);                               % use meshgrid to create a 2D array of colors
image = 255* image0';                               % traspose to get horiz grating
rgbimage(:,:,1) = image;                           	% create three panels for RGB
rgbimage(:,:,2) = image;
rgbimage(:,:,3) = image;

mytexture = Screen(window,'MakeTexture',rgbimage); 	% move array into a "texture" stucture

% -------------------------------------------------------------------------------------
function DrawMyText(window,s,x,y,color)
% DrawMyText(window,s,x,y,color);
% draw text centered at position x,y relative to center in a given color
% pass in window, string, x,y position relative to center, and color

[xcenter,ycenter] = EXGetCenter(window);			% get center of screen to position text
rect = Screen(window,'TextBounds',s);               % TextBounds replaces TextWidth
width=rect(3);                                      % 3rd element is width of text rectangle
xx = xcenter-width/2+x;                             % figure x coordinate
yy = ycenter+y;                                     % figure y coordinate
Screen(window,'DrawText',s,xx,yy,color);            % psychtoolbox call

