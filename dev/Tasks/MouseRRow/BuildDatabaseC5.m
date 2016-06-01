function BuildDatabaseC5(RawData,setmouse,setday,setpreweight,setpostweight,a,d)
%BUILDDATABASE Summary of this function goes here
%   Detailed explanation goes here

for animal=a 
    for day=d
x=tsd(RawData{animal,day}(:,1),RawData{animal,day}(:,2));
y=tsd(RawData{animal,day}(:,1),RawData{animal,day}(:,3));

taskEvents.SSN=['M',num2str(setmouse+animal,'%03d'),'-',datestr(setday+day,'yyyy-mm-dd')];

T=RawData{animal,day}(:,5);

                imid=strfind(T', ([1 0 1 1 0 1]));
               
                if imid>0
                    for iimid=1:length(imid)
                        T = T( [1:(imid(iimid)-(iimid-1))+2,(imid(iimid)-(iimid-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                 
                ibeg=strfind(T', ([0 0 1 1 0 1]));
                
                if ibeg>0
                    for iibeg=1:length(ibeg)
                        T = T( [1:(ibeg(iibeg)-(iibeg-1))+2,(ibeg(iibeg)-(iibeg-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                
                iend=strfind(T', ([1 0 1 1 0 0]));
   
                if iend>0
                    for iiend=1:length(iend)
                        T = T( [1:(iend(iiend)-(iiend-1))+2,(iend(iiend)-(iiend-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end

                ialone=strfind(T', ([0 0 1 1 0 0]));
                if ialone>0
                    for iialone=1:length(ialone)
                        T = T( [1:(ialone(iialone)-(iialone-1))+2,(ialone(iialone)-(iialone-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                
                idoubleo=strfind(T',([1 0 0 1]));

                if idoubleo>0
                    for iidoubleo=1:length(idoubleo)
                        T = T( [1:(idoubleo(iidoubleo)-(iidoubleo-1))+1,(idoubleo(iidoubleo)-(iidoubleo-1))+3:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end


        taskEvents.ChocolateOfferCountedLog=T;
        for t=1:(length(T)-61)
            if T(t)==0 && T(t+2)==1
                taskEvents.ChocolateOfferCountedLog(t+2)=sum(T(t+2:t+61));
                taskEvents.ChocolateOfferCountedLog(t+3:t+61)=0;
            else
            end
        end


T=RawData{animal,day}(:,10);

        	imid=strfind(T', ([1 0 1 1 0 1]));
               
                if imid>0
                    for iimid=1:length(imid)
                        T = T( [1:(imid(iimid)-(iimid-1))+2,(imid(iimid)-(iimid-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                 
                ibeg=strfind(T', ([0 0 1 1 0 1]));
                
                if ibeg>0
                    for iibeg=1:length(ibeg)
                        T = T( [1:(ibeg(iibeg)-(iibeg-1))+2,(ibeg(iibeg)-(iibeg-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                
                iend=strfind(T', ([1 0 1 1 0 0]));
   
                if iend>0
                    for iiend=1:length(iend)
                        T = T( [1:(iend(iiend)-(iiend-1))+2,(iend(iiend)-(iiend-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end

                ialone=strfind(T', ([0 0 1 1 0 0]));
                if ialone>0
                    for iialone=1:length(ialone)
                        T = T( [1:(ialone(iialone)-(iialone-1))+2,(ialone(iialone)-(iialone-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                
                idoubleo=strfind(T',([1 0 0 1]));

                if idoubleo>0
                    for iidoubleo=1:length(idoubleo)
                        T = T( [1:(idoubleo(iidoubleo)-(iidoubleo-1))+1,(idoubleo(iidoubleo)-(iidoubleo-1))+3:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end



        taskEvents.BananaOfferCountedLog=T;
        for t=1:(length(T)-61)
            if T(t)==0 && T(t+2)==1
                taskEvents.BananaOfferCountedLog(t+2)=sum(T(t+2:t+61));
                taskEvents.BananaOfferCountedLog(t+3:t+61)=0;
            else
            end
        end




T=RawData{animal,day}(:,15);
      
              
              imid=strfind(T', ([1 0 1 1 0 1]));
               
                if imid>0
                    for iimid=1:length(imid)
                        T = T( [1:(imid(iimid)-(iimid-1))+2,(imid(iimid)-(iimid-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                 
                ibeg=strfind(T', ([0 0 1 1 0 1]));
                
                if ibeg>0
                    for iibeg=1:length(ibeg)
                        T = T( [1:(ibeg(iibeg)-(iibeg-1))+2,(ibeg(iibeg)-(iibeg-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                
                iend=strfind(T', ([1 0 1 1 0 0]));
   
                if iend>0
                    for iiend=1:length(iend)
                        T = T( [1:(iend(iiend)-(iiend-1))+2,(iend(iiend)-(iiend-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end

                ialone=strfind(T', ([0 0 1 1 0 0]));
                if ialone>0
                    for iialone=1:length(ialone)
                        T = T( [1:(ialone(iialone)-(iialone-1))+2,(ialone(iialone)-(iialone-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                
                idoubleo=strfind(T',([1 0 0 1]));

                if idoubleo>0
                    for iidoubleo=1:length(idoubleo)
                        T = T( [1:(idoubleo(iidoubleo)-(iidoubleo-1))+1,(idoubleo(iidoubleo)-(iidoubleo-1))+3:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end


        taskEvents.GrapeOfferCountedLog=T;
        for t=1:(length(T)-61)
            if T(t)==0 && T(t+2)==1
                taskEvents.GrapeOfferCountedLog(t+2)=sum(T(t+2:t+61));
                taskEvents.GrapeOfferCountedLog(t+3:t+61)=0;
            else
            end
        end


T=RawData{animal,day}(:,20);

               imid=strfind(T', ([1 0 1 1 0 1]));
               
                if imid>0
                    for iimid=1:length(imid)
                        T = T( [1:(imid(iimid)-(iimid-1))+2,(imid(iimid)-(iimid-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                 
                ibeg=strfind(T', ([0 0 1 1 0 1]));
                
                if ibeg>0
                    for iibeg=1:length(ibeg)
                        T = T( [1:(ibeg(iibeg)-(iibeg-1))+2,(ibeg(iibeg)-(iibeg-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                
                iend=strfind(T', ([1 0 1 1 0 0]));
   
                if iend>0
                    for iiend=1:length(iend)
                        T = T( [1:(iend(iiend)-(iiend-1))+2,(iend(iiend)-(iiend-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end

                ialone=strfind(T', ([0 0 1 1 0 0]));
                if ialone>0
                    for iialone=1:length(ialone)
                        T = T( [1:(ialone(iialone)-(iialone-1))+2,(ialone(iialone)-(iialone-1))+4:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end
                
                idoubleo=strfind(T',([1 0 0 1]));

                if idoubleo>0
                    for iidoubleo=1:length(idoubleo)
                        T = T( [1:(idoubleo(iidoubleo)-(iidoubleo-1))+1,(idoubleo(iidoubleo)-(iidoubleo-1))+3:end] , : );
                        T = vertcat(T,0);
                    end
                else
                end



        taskEvents.PlainOfferCountedLog=T;
        for t=1:(length(T)-61)
            if T(t)==0 && T(t+2)==1
                taskEvents.PlainOfferCountedLog(t+2)=sum(T(t+2:t+61));
                taskEvents.PlainOfferCountedLog(t+3:t+61)=0;
            else
            end
        end


taskEvents.Flavor=RawData{animal,day}(:,1);
taskEvents.Flavor(:,end)=NaN;
taskEvents.Flavor(taskEvents.ChocolateOfferCountedLog~=0)=1;
taskEvents.Flavor(taskEvents.BananaOfferCountedLog~=0)=2;
taskEvents.Flavor(taskEvents.GrapeOfferCountedLog~=0)=3;
taskEvents.Flavor(taskEvents.PlainOfferCountedLog~=0)=4;
taskEvents.Flavor=taskEvents.Flavor (isfinite(taskEvents.Flavor (:, 1)), :);







taskEvents.OfferTimeStampLog=RawData{animal,day}(:,1);
taskEvents.OfferTimeStampLog (taskEvents.ChocolateOfferCountedLog==0 & taskEvents.BananaOfferCountedLog==0 & taskEvents.GrapeOfferCountedLog==0 & taskEvents.PlainOfferCountedLog==0) = NaN;



taskEvents.Offer=RawData{animal,day}(:,1);
taskEvents.Offer(:,end)=NaN;

for t=1:(length(taskEvents.Offer))
    if taskEvents.ChocolateOfferCountedLog(t)~=0
        taskEvents.Offer(t)=taskEvents.ChocolateOfferCountedLog(t);
    elseif taskEvents.BananaOfferCountedLog(t)~=0
        taskEvents.Offer(t)=taskEvents.BananaOfferCountedLog(t);
    elseif taskEvents.GrapeOfferCountedLog(t)~=0
        taskEvents.Offer(t)=taskEvents.GrapeOfferCountedLog(t);
    elseif taskEvents.PlainOfferCountedLog(t)~=0
        taskEvents.Offer(t)=taskEvents.PlainOfferCountedLog(t);
    end
end
        

taskEvents.Offer=taskEvents.Offer (isfinite(taskEvents.Offer (:, 1)), :);


taskEvents.OfferTimeStamp=taskEvents.OfferTimeStampLog (isfinite(taskEvents.OfferTimeStampLog (:, 1)), :);


taskEvents.EnterTimeStampLog=RawData{animal,day}(:,1);
taskEvents.EnterTimeStampLog (RawData{animal,day}(:,7)==0 & RawData{animal,day}(:,12)==0 & RawData{animal,day}(:,17)==0 & RawData{animal,day}(:,22)==0) = NaN;
taskEvents.EnterTimeStampShort=taskEvents.EnterTimeStampLog (isfinite(taskEvents.EnterTimeStampLog (:, 1)), :);




taskEvents.SkipTimeStampLog=RawData{animal,day}(:,1);
taskEvents.SkipTimeStampLog (RawData{animal,day}(:,6)==0 & RawData{animal,day}(:,11)==0 & RawData{animal,day}(:,16)==0 & RawData{animal,day}(:,21)==0) = NaN;
taskEvents.SkipTimeStampShort=taskEvents.SkipTimeStampLog (isfinite(taskEvents.SkipTimeStampLog (:, 1)), :);


taskEvents.EnterTimeStamp=taskEvents.EnterTimeStampLog;
taskEvents.EnterTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
taskEvents.EnterTimeStamp=taskEvents.EnterTimeStamp (isfinite(taskEvents.EnterTimeStamp (:, 1)), :);
taskEvents.EnterTimeStamp(taskEvents.EnterTimeStamp==0)=NaN;


taskEvents.SkipTimeStamp=taskEvents.SkipTimeStampLog;
taskEvents.SkipTimeStamp(isfinite(taskEvents.EnterTimeStampLog))=0;
taskEvents.SkipTimeStamp=taskEvents.SkipTimeStamp (isfinite(taskEvents.SkipTimeStamp (:, 1)), :);
taskEvents.SkipTimeStamp(taskEvents.SkipTimeStamp==0)=NaN;





taskEvents.QuitTimeStampLog=RawData{animal,day}(:,1);
taskEvents.QuitTimeStampLog (RawData{animal,day}(:,8)==0 & RawData{animal,day}(:,13)==0 & RawData{animal,day}(:,18)==0 & RawData{animal,day}(:,23)==0) = NaN;
taskEvents.QuitTimeStampShort=taskEvents.QuitTimeStampLog (isfinite(taskEvents.QuitTimeStampLog (:, 1)), :);

taskEvents.QuitTimeStamp=taskEvents.QuitTimeStampLog;





taskEvents.EarnTimeStampLog=RawData{animal,day}(:,1);
taskEvents.EarnTimeStampLog (RawData{animal,day}(:,9)==0 & RawData{animal,day}(:,14)==0 & RawData{animal,day}(:,19)==0 & RawData{animal,day}(:,24)==0) = NaN;
taskEvents.EarnTimeStampShort=taskEvents.EarnTimeStampLog (isfinite(taskEvents.EarnTimeStampLog (:, 1)), :);





taskEvents.QuitTimeStamp(isfinite(taskEvents.EarnTimeStampLog))=0;
taskEvents.QuitTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp (isfinite(taskEvents.QuitTimeStamp (:, 1)), :);
taskEvents.QuitTimeStamp(taskEvents.QuitTimeStamp==0)=NaN;





taskEvents.EarnTimeStamp=taskEvents.EarnTimeStampLog;
taskEvents.EarnTimeStamp(isfinite(taskEvents.QuitTimeStampLog))=0;
taskEvents.EarnTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
taskEvents.EarnTimeStamp=taskEvents.EarnTimeStamp (isfinite(taskEvents.EarnTimeStamp (:, 1)), :);
taskEvents.EarnTimeStamp(taskEvents.EarnTimeStamp==0)=NaN;

















if length(taskEvents.EnterTimeStamp)> length(taskEvents.OfferTimeStamp)
    
        for cutter=1:(length(taskEvents.EnterTimeStamp)-length(taskEvents.OfferTimeStamp))
    
                remove=find(taskEvents.EnterTimeStamp(1:length(taskEvents.OfferTimeStamp))<taskEvents.OfferTimeStamp(1:length(taskEvents.OfferTimeStamp)));
                if isempty(remove)
                    remove=length(taskEvents.EnterTimeStamp);
                    removeL=find(taskEvents.EnterTimeStampLog==taskEvents.EnterTimeStamp(remove));
                    taskEvents.EnterTimeStampLog(removeL)=NaN;
                    taskEvents.EnterTimeStamp = taskEvents.EnterTimeStamp( [1:remove-1,remove+1:end] , : );
                    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStampLog;
                    taskEvents.SkipTimeStamp(isfinite(taskEvents.EnterTimeStampLog))=0;
                    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStamp (isfinite(taskEvents.SkipTimeStamp (:, 1)), :);
                    taskEvents.SkipTimeStamp(taskEvents.SkipTimeStamp==0)=NaN;
                     if isnan(taskEvents.QuitTimeStamp(remove))==1
                            removeL=find(taskEvents.EarnTimeStampLog==taskEvents.EarnTimeStamp(remove));
                            taskEvents.EarnTimeStampLog(removeL)=NaN;
                            taskEvents.EarnTimeStamp = taskEvents.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
                            taskEvents.QuitTimeStamp=taskEvents.QuitTimeStampLog;
                            taskEvents.QuitTimeStamp(isfinite(taskEvents.EarnTimeStampLog))=0;
                            taskEvents.QuitTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
                            taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp (isfinite(taskEvents.QuitTimeStamp (:, 1)), :);
                            taskEvents.QuitTimeStamp(taskEvents.QuitTimeStamp==0)=NaN;
                        elseif isnan(taskEvents.QuitTimeStamp(remove))==0
                            removeL=find(taskEvents.QuitTimeStampLog==taskEvents.QuitTimeStamp(remove));
                            taskEvents.QuitTimeStampLog(removeL)=NaN;
                            taskEvents.QuitTimeStamp = taskEvents.QuitTimeStamp( [1:remove-1,remove+1:end] , : );
                            taskEvents.EarnTimeStamp=taskEvents.EarnTimeStampLog;
                            taskEvents.EarnTimeStamp(isfinite(taskEvents.QuitTimeStampLog))=0;
                            taskEvents.EarnTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
                            taskEvents.EarnTimeStamp=taskEvents.EarnTimeStamp (isfinite(taskEvents.EarnTimeStamp (:, 1)), :);
                            taskEvents.EarnTimeStamp(taskEvents.EarnTimeStamp==0)=NaN; 
                        end
                else
                    remove=remove(1);
                    removeL=find(taskEvents.EnterTimeStampLog==taskEvents.EnterTimeStamp(remove));
                    taskEvents.EnterTimeStampLog(removeL)=NaN;
                    taskEvents.EnterTimeStamp = taskEvents.EnterTimeStamp( [1:remove-1,remove+1:end] , : );
                    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStampLog;
                    taskEvents.SkipTimeStamp(isfinite(taskEvents.EnterTimeStampLog))=0;
                    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStamp (isfinite(taskEvents.SkipTimeStamp (:, 1)), :);
                    taskEvents.SkipTimeStamp(taskEvents.SkipTimeStamp==0)=NaN;
                            if isnan(taskEvents.QuitTimeStamp(remove))==1
                                removeL=find(taskEvents.EarnTimeStampLog==taskEvents.EarnTimeStamp(remove));
                                taskEvents.EarnTimeStampLog(removeL)=NaN;
                                taskEvents.EarnTimeStamp = taskEvents.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
                                taskEvents.QuitTimeStamp=taskEvents.QuitTimeStampLog;
                                taskEvents.QuitTimeStamp(isfinite(taskEvents.EarnTimeStampLog))=0;
                                taskEvents.QuitTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
                                taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp (isfinite(taskEvents.QuitTimeStamp (:, 1)), :);
                                taskEvents.QuitTimeStamp(taskEvents.QuitTimeStamp==0)=NaN;
                            elseif isnan(taskEvents.QuitTimeStamp(remove))==0
                                removeL=find(taskEvents.QuitTimeStampLog==taskEvents.QuitTimeStamp(remove));
                                taskEvents.QuitTimeStampLog(removeL)=NaN;
                                taskEvents.QuitTimeStamp = taskEvents.QuitTimeStamp( [1:remove-1,remove+1:end] , : );
                                taskEvents.EarnTimeStamp=taskEvents.EarnTimeStampLog;
                                taskEvents.EarnTimeStamp(isfinite(taskEvents.QuitTimeStampLog))=0;
                                taskEvents.EarnTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
                                taskEvents.EarnTimeStamp=taskEvents.EarnTimeStamp (isfinite(taskEvents.EarnTimeStamp (:, 1)), :);
                                taskEvents.EarnTimeStamp(taskEvents.EarnTimeStamp==0)=NaN; 
                            end
                end
        end


    
else
end


if length(taskEvents.EarnTimeStamp)> length(taskEvents.OfferTimeStamp)
    for cutter2=1:(length(taskEvents.EarnTimeStamp)-length(taskEvents.OfferTimeStamp))
            remove=find(taskEvents.EarnTimeStamp(1:length(taskEvents.OfferTimeStamp))<taskEvents.OfferTimeStamp(1:length(taskEvents.OfferTimeStamp)));
            if isempty(remove)
                remove=length(taskEvents.EarnTimeStamp);
                removeL=find(taskEvents.EarnTimeStampLog==taskEvents.EarnTimeStamp(remove));
                taskEvents.EarnTimeStampLog(removeL)=NaN;
                taskEvents.EarnTimeStamp = taskEvents.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
                taskEvents.QuitTimeStamp=taskEvents.QuitTimeStampLog;
                taskEvents.QuitTimeStamp(isfinite(taskEvents.EarnTimeStampLog))=0;
                taskEvents.QuitTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
                taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp (isfinite(taskEvents.QuitTimeStamp (:, 1)), :);
                taskEvents.QuitTimeStamp(taskEvents.QuitTimeStamp==0)=NaN;
            else
                remove=remove(1);
                removeL=find(taskEvents.EarnTimeStampLog==taskEvents.EarnTimeStamp(remove));
                taskEvents.EarnTimeStampLog(removeL)=NaN;
                taskEvents.EarnTimeStamp = taskEvents.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
                taskEvents.QuitTimeStamp=taskEvents.QuitTimeStampLog;
                taskEvents.QuitTimeStamp(isfinite(taskEvents.EarnTimeStampLog))=0;
                taskEvents.QuitTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
                taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp (isfinite(taskEvents.QuitTimeStamp (:, 1)), :);
                taskEvents.QuitTimeStamp(taskEvents.QuitTimeStamp==0)=NaN;
            end
    end
else
end

buffer=1;

while isempty(find(buffer>0))==0 || isempty(find(taskEvents.OfferTimeStamp>taskEvents.EnterTimeStamp))==0 || isempty(find(taskEvents.OfferTimeStamp>taskEvents.EarnTimeStamp))==0
    
    %add skip if skip is faster
    for b=1:length(taskEvents.SkipTimeStamp)
        bufferoffer=vertcat(taskEvents.OfferTimeStamp(1:length(taskEvents.SkipTimeStamp)),NaN);
        buffer(b,1)=taskEvents.SkipTimeStamp(b)-bufferoffer(b+1);
    end
    
    if isempty(find(buffer>0))==0
        addskip=find(buffer>0);
        addskip=addskip(1);
        replace=(.2*(taskEvents.OfferTimeStamp(addskip))+.8*(taskEvents.OfferTimeStamp(addskip+1)));
        minarr=(abs(x.T - replace));
        mindetect=min(abs(x.T - replace));
        replace=find(minarr==mindetect);
        T=RawData{animal,day}(:,1);
        replace=T(replace);
        taskEvents.SkipTimeStamp=vertcat(taskEvents.SkipTimeStamp(1:addskip-1),replace,taskEvents.SkipTimeStamp(addskip:end));
        taskEvents.EnterTimeStamp=vertcat(taskEvents.EnterTimeStamp(1:addskip-1),NaN,taskEvents.EnterTimeStamp(addskip:end));
        taskEvents.QuitTimeStamp=vertcat(taskEvents.QuitTimeStamp(1:addskip-1),NaN,taskEvents.QuitTimeStamp(addskip:end));
        taskEvents.EarnTimeStamp=vertcat(taskEvents.EarnTimeStamp(1:addskip-1),NaN,taskEvents.EarnTimeStamp(addskip:end));
        taskEvents.Offer=vertcat(taskEvents.Offer,NaN);
        taskEvents.OfferTimeStamp=vertcat(taskEvents.OfferTimeStamp,NaN);
        taskEvents.Flavor=vertcat(taskEvents.Flavor,NaN);
    end
    
    
    
    %clean up extra offer slots and company based on enter length if manipulations above pull things to the left
    
    if length(taskEvents.OfferTimeStamp) > length(taskEvents.EnterTimeStamp)
        remove=(length(taskEvents.OfferTimeStamp)-length(taskEvents.EnterTimeStamp));
        taskEvents.OfferTimeStamp=taskEvents.OfferTimeStamp(1:end-(remove),:);
        taskEvents.Flavor=taskEvents.Flavor(1:end-(remove),:);
        taskEvents.Offer=taskEvents.Offer(1:end-(remove),:);
        taskEvents.EnterTime=taskEvents.EnterTimeStamp -taskEvents.OfferTimeStamp;
        taskEvents.SkipTime=taskEvents.SkipTimeStamp -taskEvents.OfferTimeStamp;
    else
        taskEvents.EnterTime=taskEvents.EnterTimeStamp -taskEvents.OfferTimeStamp;
        taskEvents.SkipTime=taskEvents.SkipTimeStamp -taskEvents.OfferTimeStamp;
    end
    
    
    
    %clean up extra offer slots and company based on earn length if manipulations above pull things to the left
    if length(taskEvents.OfferTimeStamp) > length(taskEvents.EarnTimeStamp)
        remove=(length(taskEvents.OfferTimeStamp)-length(taskEvents.QuitTimeStamp));
        taskEvents.OfferTimeStamp=taskEvents.OfferTimeStamp(1:end-(remove),:);
        taskEvents.EnterTimeStamp=taskEvents.EnterTimeStamp(1:end-(remove),:);
        taskEvents.SkipTimeStamp=taskEvents.SkipTimeStamp(1:end-(remove),:);
        taskEvents.Flavor=taskEvents.Flavor(1:end-(remove),:);
        taskEvents.Offer=taskEvents.Offer(1:end-(remove),:);
        taskEvents.EnterTime=taskEvents.EnterTime(1:end-(remove),:);
        taskEvents.SkipTime=taskEvents.SkipTime(1:end-(remove),:);
        taskEvents.QuitTime=taskEvents.QuitTimeStamp -taskEvents.EnterTimeStamp;
        taskEvents.EarnTime=taskEvents.EarnTimeStamp -taskEvents.EnterTimeStamp;
    else
        taskEvents.QuitTime=taskEvents.QuitTimeStamp -taskEvents.EnterTimeStamp;
        taskEvents.EarnTime=taskEvents.EarnTimeStamp -taskEvents.EnterTimeStamp;
    end
    
    
    
    
     
    
    %repeating tone REENTRY
    
    if isempty(find(taskEvents.OfferTimeStamp>taskEvents.EnterTimeStamp))==0
        remove=find(taskEvents.OfferTimeStamp>taskEvents.EnterTimeStamp);
        remove=remove(1);
        taskEvents.EnterTimeStamp(remove)=[];
        taskEvents.EnterTimeStamp=vertcat(taskEvents.EnterTimeStamp,NaN);
        taskEvents.SkipTimeStamp(remove)=[];
        taskEvents.SkipTimeStamp=vertcat(taskEvents.SkipTimeStamp,NaN);
        taskEvents.EarnTimeStamp(remove)=[];
        taskEvents.EarnTimeStamp=vertcat(taskEvents.EarnTimeStamp,NaN);
        taskEvents.QuitTimeStamp(remove)=[];
        taskEvents.QuitTimeStamp=vertcat(taskEvents.QuitTimeStamp,NaN);
        taskEvents.EnterTime=taskEvents.EnterTimeStamp -taskEvents.OfferTimeStamp;
        taskEvents.SkipTime=taskEvents.SkipTimeStamp -taskEvents.OfferTimeStamp;
        taskEvents.EarnTime=taskEvents.EarnTimeStamp -taskEvents.EnterTimeStamp;
        taskEvents.QuitTime=taskEvents.QuitTimeStamp -taskEvents.EnterTimeStamp;
    else
    end
    
    
    %countdown REENTRY
    
    if isempty(find(taskEvents.OfferTimeStamp>taskEvents.EarnTimeStamp))==0
        remove=find(taskEvents.OfferTimeStamp>taskEvents.EarnTimeStamp);
        remove=remove(1);
        taskEvents.EarnTimeStamp(remove)=[];
        taskEvents.EarnTimeStamp=vertcat(taskEvents.EarnTimeStamp,NaN);
        taskEvents.QuitTimeStamp(remove)=[];
        taskEvents.QuitTimeStamp=vertcat(taskEvents.QuitTimeStamp,NaN);
        taskEvents.EarnTime=taskEvents.EarnTimeStamp -taskEvents.EnterTimeStamp;
        taskEvents.QuitTime=taskEvents.QuitTimeStamp -taskEvents.EnterTimeStamp;
    else
    end
    
    
    
    
    
    taskEvents.WorkTime=taskEvents.EarnTimeStamp -taskEvents.OfferTimeStamp;
    
    
    
    
    %hanging offer at end
    
    if ~isnan(taskEvents.OfferTimeStamp(end)) && isnan(taskEvents.SkipTimeStamp(end)) && isnan(taskEvents.EnterTimeStamp(end)) && isnan(taskEvents.QuitTimeStamp(end)) && isnan(taskEvents.EarnTimeStamp(end))
        taskEvents.OfferTimeStamp=taskEvents.OfferTimeStamp(1:end-1);
        taskEvents.Flavor=taskEvents.Flavor(1:end-1);
        taskEvents.Offer=taskEvents.Offer(1:end-1);
        taskEvents.EnterTimeStamp=taskEvents.EnterTimeStamp(1:end-1);
        taskEvents.SkipTimeStamp=taskEvents.SkipTimeStamp(1:end-1);
        taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp(1:end-1);
        taskEvents.EarnTimeStamp=taskEvents.EarnTimeStamp(1:end-1);
        taskEvents.EnterTime=taskEvents.EnterTimeStamp -taskEvents.OfferTimeStamp;
        taskEvents.SkipTime=taskEvents.SkipTimeStamp -taskEvents.OfferTimeStamp;
        taskEvents.EarnTime=taskEvents.EarnTimeStamp -taskEvents.EnterTimeStamp;
        taskEvents.QuitTime=taskEvents.QuitTimeStamp -taskEvents.EnterTimeStamp;
        taskEvents.WorkTime=taskEvents.EarnTimeStamp -taskEvents.OfferTimeStamp;
    else
    end
    
    
    %hanging countdown at end
    
    if ~isnan(taskEvents.OfferTimeStamp(end)) && isnan(taskEvents.SkipTimeStamp(end)) && ~isnan(taskEvents.EnterTimeStamp(end)) && isnan(taskEvents.QuitTimeStamp(end)) && isnan(taskEvents.EarnTimeStamp(end))
        taskEvents.OfferTimeStamp=taskEvents.OfferTimeStamp(1:end-1);
        taskEvents.Flavor=taskEvents.OfferTimeStamp(1:end-1);
        taskEvents.Offer=taskEvents.Offer(1:end-1);
        taskEvents.EnterTimeStamp=taskEvents.EnterTimeStamp(1:end-1);
        taskEvents.SkipTimeStamp=taskEvents.SkipTimeStamp(1:end-1);
        taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp(1:end-1);
        taskEvents.EarnTimeStamp=taskEvents.EarnTimeStamp(1:end-1);
        taskEvents.EnterTime=taskEvents.EnterTimeStamp -taskEvents.OfferTimeStamp;
        taskEvents.SkipTime=taskEvents.SkipTimeStamp -taskEvents.OfferTimeStamp;
        taskEvents.EarnTime=taskEvents.EarnTimeStamp -taskEvents.EnterTimeStamp;
        taskEvents.QuitTime=taskEvents.QuitTimeStamp -taskEvents.EnterTimeStamp;
        taskEvents.WorkTime=taskEvents.EarnTimeStamp -taskEvents.OfferTimeStamp;
    else
    end
    
    
    
    for b=1:length(taskEvents.SkipTimeStamp)
        bufferoffer=vertcat(taskEvents.OfferTimeStamp(1:length(taskEvents.SkipTimeStamp)),NaN);
        buffer(b,1)=taskEvents.SkipTimeStamp(b)-bufferoffer(b+1);
    end

    
end









taskEvents.nOffers=length(taskEvents.OfferTimeStamp);
taskEvents.nEnters=sum(~isnan(taskEvents.EnterTimeStamp));
taskEvents.nSkips=sum(~isnan(taskEvents.SkipTimeStamp));
taskEvents.nQuits=sum(~isnan(taskEvents.QuitTimeStamp));
taskEvents.nEarns=sum(~isnan(taskEvents.EarnTimeStamp));


taskEvents=rmfield(taskEvents,'OfferTimeStampLog');
taskEvents=rmfield(taskEvents,'EarnTimeStampLog');
taskEvents=rmfield(taskEvents,'EarnTimeStampShort');
taskEvents=rmfield(taskEvents,'SkipTimeStampLog');
taskEvents=rmfield(taskEvents,'SkipTimeStampShort');
taskEvents=rmfield(taskEvents,'QuitTimeStampLog');
taskEvents=rmfield(taskEvents,'QuitTimeStampShort');
taskEvents=rmfield(taskEvents,'EnterTimeStampLog');
taskEvents=rmfield(taskEvents,'EnterTimeStampShort');
taskEvents=rmfield(taskEvents,'ChocolateOfferCountedLog');
taskEvents=rmfield(taskEvents,'BananaOfferCountedLog');
taskEvents=rmfield(taskEvents,'GrapeOfferCountedLog');
taskEvents=rmfield(taskEvents,'PlainOfferCountedLog');
clear('t');
clear('T');
clear('tt');
clear('ttt');
clear('ans');
clear('ialone');
clear('ibeg');
clear('imid');
clear('iend');
clear('idoubleo');
clear('iialone');
clear('iibeg');
clear('iimid');
clear('iiend');
clear('iidoubleo');
clear('remove');
clear('removeL');
clear('cutter');
clear('cutter2');
clear('b');
clear('buffer');
clear('bufferoffer');
clear('addskip');
clear('minarr');
clear('mindetect');
clear('replace');
clear('s');


      
keys.SSN=['M',num2str(setmouse+animal,'%03d'),'-',datestr(setday+day,'yyyy-mm-dd')];
keys.Protocol='behavior';
keys.Behavior='RROW';

if animal==1 || animal == 2 || animal == 3 || animal == 4
keys.RunningRoom='3';
elseif animal==5 || animal == 6 || animal == 7 || animal == 8
keys.RunningRoom='4';
else
end

keys.TaskType='DTvsWT';
keys.Study='cocaine off-board PM';
keys.DayOfStudy=day;
         

                if day<6
                    keys.FeederDelayList=(1);
                    keys.PhaseOfStudy=['1 sec training ',num2str(day)];
                elseif day>5 && day<11
                    keys.FeederDelayList=(1:5);
                    keys.PhaseOfStudy=['5 sec training ',num2str(day-5)];
                elseif day>10 && day<16
                    keys.FeederDelayList=(1:15);
                    keys.PhaseOfStudy=['15 sec training ',num2str(day-10)];
                elseif day>15 && day<21
                    keys.FeederDelayList=(1:30);
                    keys.PhaseOfStudy=['30 sec training ',num2str(day-16)];
                elseif day>20 && day<42
                    keys.FeederDelayList=(1:30);
                    keys.PhaseOfStudy=['baseline RRow ',num2str(day-20)];
                elseif day>41 && day<44
                    keys.FeederDelayList=(1:30);
                    keys.PhaseOfStudy=['baseline saline injection ',num2str(day-41)];
                elseif day>43 && day<49
                    keys.FeederDelayList=(1:30);
                    keys.PhaseOfStudy=['treatment injection ',num2str(day-43)];
                elseif day>48 && day<63
                    keys.FeederDelayList=(1:30);
                    keys.PhaseOfStudy=['withdrawal ',num2str(day-48)];
                elseif day>62 && day<64
                    keys.FeederDelayList=(1:30);
                    keys.PhaseOfStudy=('challenge');
                elseif day>63 && day<78
                    keys.FeederDelayList=(1:30);
                    keys.PhaseOfStudy=['post-challenge ',num2str(day-63)];
                elseif day>77
                    keys.FeederDelayList=(1:30);
                    keys.PhaseOfStudy=['extra pilot ',num2str(day-77)];
            end
            
            
keys.Flavors={'chocolate', 'banana', 'grape', 'plain'};            
keys.PelletNumber=[1,1,1,1];
keys.FeederProbability=[1,1,1,1];
           
                if animal==1 || animal == 3 || animal == 5 || animal == 7
                keys.Condition='saline';
                keys.Dose='n/a';
                keys.SolutionConc='n/a';
                elseif animal==2 || animal == 4 || animal == 6 || animal == 8
                keys.Condition='cocaine';
                keys.Dose='15mg/kg';
                keys.SolutionConc='3mg/mL';
                else
                end


keys.PreWeight=setpreweight(day,animal);
keys.PostWeight=setpostweight(day,animal);
keys.Note='';






mkdir('C:\Users\TLWS-11\Documents\MATLAB\BrianDatabase\',taskEvents.SSN(1:4)); warning('off')
mkdir(['C:\Users\TLWS-11\Documents\MATLAB\BrianDatabase\',taskEvents.SSN(1:4)],taskEvents.SSN);
save(['C:\Users\TLWS-11\Documents\MATLAB\BrianDatabase\',taskEvents.SSN(1:4),'\',taskEvents.SSN,'\',taskEvents.SSN,'-vt.mat'],'x','y');
save(['C:\Users\TLWS-11\Documents\MATLAB\BrianDatabase\',taskEvents.SSN(1:4),'\',taskEvents.SSN,'\',taskEvents.SSN,'-taskEvents.mat'],'taskEvents');
save(['C:\Users\TLWS-11\Documents\MATLAB\BrianDatabase\',taskEvents.SSN(1:4),'\',taskEvents.SSN,'\',taskEvents.SSN,'-keys.mat'],'keys');







    end
end
end

