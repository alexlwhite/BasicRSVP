%save simple file to check overall PC
function printPCRes(task,data) 

overallPC = 100*mean(data.respCorrect(data.trialDone==1 & ~isnan(data.respCorrect)));

home;

%for this experiment, we're trying to keep single-task accuracy near 80
%percent correct. So just tell the observer single-task performance. 
fprintf(1,'\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
fprintf(1,'\nYOUR OVERALL ACCURACY: %i percent correct\n',round(overallPC));
fprintf(1,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');


%pick a name for this results text file
goodName = false; bn = 0;

while ~goodName
    bn = bn+1;
    txtFName = sprintf('%s_%s_PC%i_%i.txt',task.subj,date,round(overallPC),bn);
    fullFileName = fullfile(task.subjDataFolder,txtFName);
    goodName = ~isfile(fullFileName);
end

fid = fopen(fullFileName,'w');

fprintf(fid,'Overall PC res for subject %s on date %s\n\n',task.subj,date);

fprintf(fid,'\nRSVP Periods tested:\n');
for ri=1:length(task.durations.rsvpPeriod)
    fprintf(fid,'\t%.3f\t(rate = %.3f Hz)\n',task.durations.rsvpPeriod(ri),1./task.durations.rsvpPeriod(ri));
end
fprintf(fid,'\n%i blocks run.', task.blockNum);    
fprintf(fid,'\n\nOverall percent correct:\t %.2f\n', overallPC);

