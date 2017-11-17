
function task = setupSIAMStaircase(task, bounds)

for cvi=1:task.stair.nTypes
    for ssi=1:task.stair.nPerType
        startlev = task.stair.startC;
        %set bounds, [min max]
        if task.stair.inLog10
            theStart = log10(startlev);
            theBounds  = log10(bounds);
        else
            theStart = startLev;
            theBounds = bounds;
        end
        
        task.stair.ss{cvi,ssi} = initSIAM(task.stair.t, task.stair.startStep, theStart(cvi,ssi), theBounds, task.stair.revsToHalfContr, task.stair.revsToReset, task.stair.nStuckToReset);
    end
end
