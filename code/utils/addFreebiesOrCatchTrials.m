function task = addFreebiesOrCatchTrials(task,trialtype)

if trialtype==1
    addnts=task.nFreebieTrials;
    addvar='freebie';
else
    addnts=task.nCatchTrials;
    addvar='catch';
end
randParamNames=fieldnames(task.design.uniformRandVars);

for p=1:length(randParamNames)
    pname=randParamNames{p};
    eval(sprintf('doRandSamp=length(task.design.uniformRandVars.%s)>1;',pname));
    if doRandSamp
        eval(sprintf('all%s = randsample(task.design.uniformRandVars.%s, addnts, true);', pname, pname));
    else
        eval(sprintf('all%s = ones(1, addnts)*task.design.uniformRandVars.%s;', pname, pname));
    end
    for t=1:addnts
        eval(sprintf('task.design.trials(task.numTrials+t).%s=all%s(t);',pname, pname));
    end
end

randParamNames=fieldnames(task.design.parameters);

for p=1:length(randParamNames)
    pname=randParamNames{p};
    eval(sprintf('doRandSamp=length(task.design.parameters.%s)>1;',pname));
    
    if strcmp(pname,'cueValidity') %make roughly balanced numbers of trials with valid and invalid catch/freebie
        allcueValidity=ones(1,addnts);
        ninvalid=floor(addnts*sum(task.cueValidityMix==-1)/length(task.cueValidityMix));
        nneutral=floor(addnts*sum(task.cueValidityMix==0)/length(task.cueValidityMix));
        allcueValidity(1:ninvalid)=-1;
        allcueValidity((ninvalid+1):(ninvalid+nneutral))=0;
    else
        
        if doRandSamp
            eval(sprintf('all%s = randsample(task.design.parameters.%s, addnts, true);', pname, pname));
        else
            eval(sprintf('all%s = ones(1, addnts)*task.design.parameters.%s;', pname, pname));
        end
    end
    for t=1:addnts
        eval(sprintf('task.design.trials(task.numTrials+t).%s=all%s(t);',pname, pname));
        eval(sprintf('task.design.trials(task.numTrials+t).%s = true;',addvar));
    end
end
task.numTrials = task.numTrials+addnts;
shuff=randperm(task.numTrials);
task.design.trials=task.design.trials(shuff);