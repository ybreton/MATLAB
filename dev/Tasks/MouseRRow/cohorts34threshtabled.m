
for a=1:4
    for d=1:25
        for f=1:4
        
            if isempty(pertThresh{a,d})
                continue
            else
                
                tempEnE=pertThresh{a,d}(:,6);
                tempEQ=pertThresh{a,d}(:,6);
                tempEQ((pertThresh{a,d}(:,3))>0)=NaN;
                tempO=pertThresh{a,d}(:,2);
                tempF=pertThresh{a,d}(:,7);
                
                eval(['finalThresh.M0',num2str(a+8),'.earnQuit(',num2str(d),',',num2str(f),')=RRheaviside(tempO(tempF==',num2str(f),'),tempEQ(tempF==',num2str(f),'));']);
            end
        end
    end
end




for a=1:4
    for d=1:25
        for f=1:4
        
            if isempty(pertThresh{a,d})
                continue
            else
                
                tempEnE=pertThresh{a,d}(:,6);
                tempEQ=pertThresh{a,d}(:,6);
                tempEQ((pertThresh{a,d}(:,3))>0)=NaN;
                tempO=pertThresh{a,d}(:,2);
                tempF=pertThresh{a,d}(:,7);
                
                eval(['finalThresh.M0',num2str(a+8),'.earnNotEarn(',num2str(d),',',num2str(f),')=RRheaviside(tempO(tempF==',num2str(f),'),tempEnE(tempF==',num2str(f),'));']);
            end
        end
    end
end