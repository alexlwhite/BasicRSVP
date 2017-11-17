function [fullFileName, eyelinkFileName, task] = setupDataFile_RSVP(fileNum, task)


task.datadir = task.subjDataFolder;

% if task.practice %this is already done in runMain
%     task.datadir = fullfile(task.datadir,'practice');
% end

if ~isdir(task.datadir)
    mkdir(task.datadir);
    fprintf(1,'\nMaking a folder with subject initials in data directory!');
end

% Decide what this data file should be called
thedate = [datestr(now,'yy') datestr(now,'mm') datestr(now,'dd')];

if task.doStair
    filename = sprintf('%s_%s_Stair',task.subj,thedate);
else
    filename = sprintf('%s_%s',task.subj,thedate);
end
if task.practice
    filename = sprintf('%s_prac',filename);
end

% make sure we don't have an existing file in the directory
% that would get overwritten
bn = fileNum-1;
goodname = false;

while ~goodname
    bn = bn+1;
    fullFileName = fullfile(task.datadir, sprintf('%s_%02i',filename, bn));
    goodname = ~(isfile(sprintf('%s.mat',fullFileName)) || isfile(sprintf('%s.txt',fullFileName)) || isfile(sprintf('%s.edf',fullFileName)));
end

task.dataFileName=fullFileName;
    
fprintf(1,'\n\nSaving data file as %s\n\n',fullFileName);

%eyelink file name
if task.practice
    extraLet='p';
else
    if task.doStair
        extraLet='s';
    else
        extraLet='';
    end
end
eyelinkFileName = sprintf('%s%s_%i%s',task.subj,datestr(now,'dd'),bn,extraLet);
task.eyelinkFileName=eyelinkFileName;

