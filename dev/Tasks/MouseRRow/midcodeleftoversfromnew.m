


if length(taskEvents.EnterTimeStamp)> length(taskEvents.OfferTimeStamp)
    
        for cutter=1:(length(taskEvents.EnterTimeStamp)-length(taskEvents.OfferTimeStamp))
    
                remove=find(taskEvents.EnterTimeStamp(1:length(taskEvents.OfferTimeStamp))<taskEvents.OfferTimeStamp(1:length(taskEvents.OfferTimeStamp)));
                if isempty(remove)
                    remove=length(taskEvents.EnterTimeStamp);
                    removeL=find(taskEvents.EnterTimeStampLog==taskEvents.EnterTimeStamp(remove));
                    taskEvents.EnterTimeStampLog(removeL)=[];
                    taskEvents.EnterTimeStampLog = vertcat(taskEvents.EnterTimeStampLog,NaN);
                    taskEvents.EnterTimeStamp = taskEvents.EnterTimeStamp( [1:remove-1,remove+1:end] , : );
                    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStampLog;
                    taskEvents.SkipTimeStamp(isfinite(taskEvents.EnterTimeStampLog))=0;
                    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStamp (isfinite(taskEvents.SkipTimeStamp (:, 1)), :);
                    taskEvents.SkipTimeStamp(taskEvents.SkipTimeStamp==0)=NaN;
                     if isnan(taskEvents.QuitTimeStamp(remove))==1
                            removeL=find(taskEvents.EarnTimeStampLog==taskEvents.EarnTimeStamp(remove));
                            taskEvents.EarnTimeStampLog(removeL)=[];
                            taskEvents.EarnTimeStampLog = vertcat(taskEvents.EarnTimeStampLog,NaN);
                            taskEvents.EarnTimeStamp = taskEvents.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
                            taskEvents.QuitTimeStamp=taskEvents.QuitTimeStampLog;
                            taskEvents.QuitTimeStamp(isfinite(taskEvents.EarnTimeStampLog))=0;
                            taskEvents.QuitTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
                            taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp (isfinite(taskEvents.QuitTimeStamp (:, 1)), :);
                            taskEvents.QuitTimeStamp(taskEvents.QuitTimeStamp==0)=NaN;
                        elseif isnan(taskEvents.QuitTimeStamp(remove))==0
                            removeL=find(taskEvents.QuitTimeStampLog==taskEvents.QuitTimeStamp(remove));
                            taskEvents.QuitTimeStampLog(removeL)=[];
                            taskEvents.QuitTimeStampLog = vertcat(taskEvents.QuitTimeStampLog,NaN);
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
                    taskEvents.EnterTimeStampLog(removeL)=[]
                    taskEvents.EnterTimeStampLog = vertcat(taskEvents.EnterTimeStampLog,NaN);
                    taskEvents.EnterTimeStamp = taskEvents.EnterTimeStamp( [1:remove-1,remove+1:end] , : );
                    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStampLog;
                    taskEvents.SkipTimeStamp(isfinite(taskEvents.EnterTimeStampLog))=0;
                    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStamp (isfinite(taskEvents.SkipTimeStamp (:, 1)), :);
                    taskEvents.SkipTimeStamp(taskEvents.SkipTimeStamp==0)=NaN;
                            if isnan(taskEvents.QuitTimeStamp(remove))==1
                                removeL=find(taskEvents.EarnTimeStampLog==taskEvents.EarnTimeStamp(remove));
                                taskEvents.EarnTimeStampLog(removeL)=[];
                                taskEvents.EarnTimeStampLog = vertcat(taskEvents.EarnTimeStampLog,NaN);
                                taskEvents.EarnTimeStamp = taskEvents.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
                                taskEvents.QuitTimeStamp=taskEvents.QuitTimeStampLog;
                                taskEvents.QuitTimeStamp(isfinite(taskEvents.EarnTimeStampLog))=0;
                                taskEvents.QuitTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
                                taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp (isfinite(taskEvents.QuitTimeStamp (:, 1)), :);
                                taskEvents.QuitTimeStamp(taskEvents.QuitTimeStamp==0)=NaN;
                            elseif isnan(taskEvents.QuitTimeStamp(remove))==0
                                removeL=find(taskEvents.QuitTimeStampLog==taskEvents.QuitTimeStamp(remove));
                                taskEvents.QuitTimeStampLog(removeL)=[];
                                taskEvents.QuitTimeStampLog = vertcat(taskEvents.QuitTimeStampLog,NaN);
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
                taskEvents.EarnTimeStampLog(removeL)=[];
                taskEvents.EarnTimeStampLog = vertcat(taskEvents.EarnTimeStampLog,NaN);
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
                taskEvents.EarnTimeStampLog = vertcat(taskEvents.EarnTimeStampLog,NaN);
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



if length(taskEvents.OfferTimeStamp) > length(taskEvents.EnterTimeStamp)
    remove=(length(taskEvents.OfferTimeStamp)-length(taskEvents.EnterTimeStamp));
    taskEvents.OfferTimeStamp=taskEvents.OfferTimeStamp(1:end-(remove),:);
    taskEvents.Flavor=taskEvents.Flavor(1:end-(remove),:);
    taskEvents.Offer=taskEvents.Offer(1:end-(remove),:);
end





while length(find(taskEvents.EnterTimeStamp<taskEvents.OfferTimeStamp))>0
    remove=find(taskEvents.EnterTimeStamp<taskEvents.OfferTimeStamp);
    remove=remove(1);
    removeL=find(taskEvents.EnterTimeStampLog==taskEvents.EnterTimeStamp(remove));
    taskEvents.EnterTimeStampLog(removeL)=[];
    taskEvents.EnterTimeStampLog = vertcat(taskEvents.EnterTimeStampLog,NaN);
    taskEvents.EnterTimeStamp = taskEvents.EnterTimeStamp( [1:remove-1,remove+1:end] , : );
    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStampLog;
    taskEvents.SkipTimeStamp(isfinite(taskEvents.EnterTimeStampLog))=0;
    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStamp (isfinite(taskEvents.SkipTimeStamp (:, 1)), :);
    taskEvents.SkipTimeStamp(taskEvents.SkipTimeStamp==0)=NaN;
    taskEvents.EnterTimeStamp=vertcat(taskEvents.EnterTimeStamp,NaN);
    taskEvents.SkipTimeStamp=vertcat(taskEvents.SkipTimeStamp,NaN);
    if isnan(taskEvents.QuitTimeStamp(remove))==1
        removeL=find(taskEvents.EarnTimeStampLog==taskEvents.EarnTimeStamp(remove));
        taskEvents.EarnTimeStampLog(removeL)=NaN;
        taskEvents.EarnTimeStampLog = vertcat(taskEvents.EarnTimeStampLog,NaN);
        taskEvents.EarnTimeStamp = taskEvents.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
        taskEvents.QuitTimeStamp=taskEvents.QuitTimeStampLog;
        taskEvents.QuitTimeStamp(isfinite(taskEvents.EarnTimeStampLog))=0;
        taskEvents.QuitTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
        taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp (isfinite(taskEvents.QuitTimeStamp (:, 1)), :);
        taskEvents.QuitTimeStamp(taskEvents.QuitTimeStamp==0)=NaN;
        taskEvents.QuitTimeStamp=vertcat(taskEvents.QuitTimeStamp,NaN);
    taskEvents.EarnTimeStamp=vertcat(taskEvents.EarnTimeStamp,NaN);
    elseif isnan(taskEvents.QuitTimeStamp(remove))==0
        removeL=find(taskEvents.QuitTimeStampLog==taskEvents.QuitTimeStamp(remove));
        taskEvents.QuitTimeStampLog(removeL)=NaN;
        taskEvents.QuitTimeStampLog = vertcat(taskEvents.QuitTimeStampLog,NaN);
        taskEvents.QuitTimeStamp = taskEvents.QuitTimeStamp( [1:remove-1,remove+1:end] , : );
        taskEvents.EarnTimeStamp=taskEvents.EarnTimeStampLog;
        taskEvents.EarnTimeStamp(isfinite(taskEvents.QuitTimeStampLog))=0;
        taskEvents.EarnTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
        taskEvents.EarnTimeStamp=taskEvents.EarnTimeStamp (isfinite(taskEvents.EarnTimeStamp (:, 1)), :);
        taskEvents.EarnTimeStamp(taskEvents.EarnTimeStamp==0)=NaN;
        taskEvents.QuitTimeStamp=vertcat(taskEvents.QuitTimeStamp,NaN);
        taskEvents.EarnTimeStamp=vertcat(taskEvents.EarnTimeStamp,NaN);
    else
    end
    
    
    
end













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





%remove less obvious enters that come before offers in the event of a
%dangling offer or countdown at the end of the session ( to be cleaned up below below)




while length(find(taskEvents.EnterTimeStamp<taskEvents.OfferTimeStamp))>1
    remove=find(taskEvents.EnterTimeStamp<taskEvents.OfferTimeStamp);
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
    else
    end


    taskEvents.EnterTimeStamp=vertcat(taskEvents.EnterTimeStamp,NaN);
    taskEvents.SkipTimeStamp=vertcat(taskEvents.SkipTimeStamp,NaN);
    taskEvents.QuitTimeStamp=vertcat(taskEvents.QuitTimeStamp,NaN);
    taskEvents.EarnTimeStamp=vertcat(taskEvents.EarnTimeStamp,NaN);
    if length(taskEvents.OfferTimeStamp)==length(taskEvents.SkipTimeStamp)
    else
        taskEvents.SkipTimeStamp=vertcat(taskEvents.SkipTimeStamp,NaN);
    end
end







%save as above but for extra earn that is more subtle
while length(find(taskEvents.EarnTimeStamp<taskEvents.OfferTimeStamp))>1
    remove=find(taskEvents.EarnTimeStamp<taskEvents.OfferTimeStamp);
    remove=remove(1);
    removeL=find(taskEvents.EarnTimeStampLog==taskEvents.EarnTimeStamp(remove));
    taskEvents.EarnTimeStampLog(removeL)=NaN;
    taskEvents.EarnTimeStamp = taskEvents.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
    taskEvents.QuitTimeStamp=taskEvents.QuitTimeStampLog;
    taskEvents.QuitTimeStamp(isfinite(taskEvents.EarnTimeStampLog))=0;
    taskEvents.QuitTimeStamp(isfinite(taskEvents.SkipTimeStampLog))=0;
    taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp (isfinite(taskEvents.QuitTimeStamp (:, 1)), :);
    taskEvents.QuitTimeStamp(taskEvents.QuitTimeStamp==0)=NaN;

    
    taskEvents.QuitTimeStamp=vertcat(taskEvents.QuitTimeStamp,NaN);
    taskEvents.EarnTimeStamp=vertcat(taskEvents.EarnTimeStamp,NaN);
end





                         


if ~isnan(taskEvents.OfferTimeStamp(end)) && isnan(taskEvents.SkipTimeStamp(end)) && isnan(taskEvents.EnterTimeStamp(end)) && isnan(taskEvents.QuitTimeStamp(end)) && isnan(taskEvents.EarnTimeStamp(end))
    taskEvents.OfferTimeStamp=taskEvents.OfferTimeStamp(1:end-1);
    taskEvents.Flavor=taskEvents.Flavor(1:end-1);
    taskEvents.Offer=taskEvents.Offer(1:end-1);
    taskEvents.EnterTimeStamp=taskEvents.EnterTimeStamp(1:end-1);
    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStamp(1:end-1);
    taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp(1:end-1);
    taskEvents.EarnTimeStamp=taskEvents.EarnTimeStamp(1:end-1);
else
end

if ~isnan(taskEvents.OfferTimeStamp(end)) && isnan(taskEvents.SkipTimeStamp(end)) && ~isnan(taskEvents.EnterTimeStamp(end)) && isnan(taskEvents.QuitTimeStamp(end)) && isnan(taskEvents.EarnTimeStamp(end))
    taskEvents.OfferTimeStamp=taskEvents.OfferTimeStamp(1:end-1);
    taskEvents.Flavor=taskEvents.OfferTimeStamp(1:end-1);
    taskEvents.Offer=taskEvents.Offer(1:end-1);
    taskEvents.EnterTimeStamp=taskEvents.EnterTimeStamp(1:end-1);
    taskEvents.SkipTimeStamp=taskEvents.SkipTimeStamp(1:end-1);
    taskEvents.QuitTimeStamp=taskEvents.QuitTimeStamp(1:end-1);
    taskEvents.EarnTimeStamp=taskEvents.EarnTimeStamp(1:end-1);
else
end



if length(taskEvents.OfferTimeStamp) > length(taskEvents.EnterTimeStamp)
    remove=(length(taskEvents.OfferTimeStamp)-length(taskEvents.EnterTimeStamp));
    taskEvents.OfferTimeStamp=taskEvents.OfferTimeStamp(1:end-(remove),:);
    taskEvents.Flavor=taskEvents.Flavor(1:end-(remove),:);
    taskEvents.Offer=taskEvents.Offer(1:end-(remove),:);
    taskEvents.EnterTime=taskEvents.EnterTimeStamp -taskEvents.OfferTimeStamp;
    taskEvents.SkipTime=taskEvents.SkipTimeStamp -taskEvents.OfferTimeStamp;
else
    taskEvents.EnterTime=taskEvents.EnterTimeStamp -taskEvents.OfferTimeStamp;
    taskEvents.SkipTime=taskEvents.SkipTimeStamp-taskEvents.OfferTimeStamp;
end




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



taskEvents.WorkTime=taskEvents.EarnTimeStamp -taskEvents.OfferTimeStamp;





