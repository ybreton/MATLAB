for iD = 1:length(fd);

sd = mouseRROWTaskInit(fd{iD});
name=sd.keys.SSN(1:4);

if any(ismember(animalname,name))
    if sd.keys.DayOfStudy<21  || sd.keys.DayOfStudy>74
        continue
    else
    end 
    
    for a=1:8
        finalThresh.(animalname{a}).HYBRIDearnNotEarn=NaN(74,4);
        finalThresh.(animalname{a}).HYBRIDearnQuit=NaN(74,4);
        
        for d=21:74
            for f=1:4
                finalThresh.(animalname{a}).HYBRIDearnNotEarn(d,f)=fitHeavisideSigmoidHybrid(sd.taskEvents.Offer(sd.taskEvents.Flavor==f),~isnan(sd.taskEvents.EarnTimeStamp(sd.taskEvents.Flavor==f)));
                
                
                hEQ=sd.taskEvents.EarnTimeStamp;
                hEQ(~isnan(sd.taskEvents.SkipTimeStamp))=NaN;
                hEQOffer=sd.taskEvents.Offer;
                hEQOffer(isnan(hEQ))=[];
                hEQFlavor=sd.taskEvents.Flavor;
                hEQFlavor(isnan(hEQ))=[];
                hEQ(isnan(hEQ))=[];
                
                
                finalThresh.(animalname{a}).HYBRIDearnQuit(d,f)=fitHeavisideSigmoidHybrid(hEQOffer(hEQFlavor==f),hEQ(hEQFlavor==f));

                
                
            end
        end
    end
else
    continue
end
end

           