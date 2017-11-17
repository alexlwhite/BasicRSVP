innnerOuter = {'inner','outer'};
sideLabs = {'left','right'};

for wordLen = 4:6
    nInner = floor(wordLen/2); nOuter = wordLen-nInner;
    
    for colorOuterLetters = 0:1
        for targSide = 1:2
            if colorOuterLetters == 1
                if targSide==1 %left, outer letters are 1st ones
                    coloredLetters = 1:nOuter;
                else %right, outer letters are the last ones
                    coloredLetters = (nInner+1):wordLen;
                end
            else
                if targSide==1 %left, inner letters are last ones
                    coloredLetters = (nOuter+1):wordLen;
                else %right, inner letters are the first ones
                    coloredLetters = 1:nInner;
                end
                
            end
            fprintf(1,'\n\nlength %i\t %s side\t %s letters:\t\t', wordLen,sideLabs{targSide}, innnerOuter{colorOuterLetters+1})
            fprintf(1,'%i\t',coloredLetters);
        end
    end
end