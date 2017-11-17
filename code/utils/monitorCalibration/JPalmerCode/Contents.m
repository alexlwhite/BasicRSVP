% Table of Contents for the CCRoutines Directory (Calibrated Color)% These routines support experiments written for Palmer's lab% They differ from prior routines in using 32-bit color instead of cluts.% See CCDisplayColor for a simple example of using these routines.% 3/16/15   John Palmer created CCRoutines based on the CLRoutines% CCCalibrationCheck    program to do a simple check of a calbration% CCDisplayColor        simple program to display a single color% CCGetCalibration		get calibration info from file % CCMakeInverseGamma  	routine to construct an inverse Gamma function% default.cal           example calibration file used by test programs% unit.cal              calibration file with "linear" values%% HOW TO MAKE AN INVERSE GAMMA TABLE FROM JP's CALIBRATION FILES,%% FOR USE WTH loadPTBNormGammaTable and Screen('LoadNormalizedGammaTable'% JP's calibration files (eg VS95_070815.cal) have just some summary% information about max and min luminance and function fits for the three% guns. % His function CCGetCalibration reads that file. Give it the file name and% it returns a structure cl. Then pass cl to CCMakeInverseGamma, which% returns a 256x3 matrix. That can then be saved as calib.table in the% calibration file that AWs prepScreen function loads in, and passes to% loadPTBNormGammaTable. 