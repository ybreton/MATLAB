function BuildDatabase(RawData,setmouse,setday,setpreweight,setpostweight,a,d)
%BUILDDATABASE Summary of this function goes here
%   Detailed explanation goes here

for animal=a 
    for day=d
x=tsd(RawData{animal,day}(:,1),RawData{animal,day}(:,2));
y=tsd(RawData{animal,day}(:,1),RawData{animal,day}(:,3));

taskEvents.SSN=['M',num2str(setmouse+animal,'%03d'),'-',datestr(setday+day,'yyyy-mm-dd')];

T=RawData{animal,day}(:,9);

                imid=strfind(T', ([1 0 1 1 0 1]));
                ibeg=strfind(T', ([0 0 1 1 0 1]));
                iend=strfind(T', ([1 0 1 1 0 0]));
                ialone=strfind(T', ([0 0 1 1 0 0]));

                if imid>0
                    T = T( [1:imid+2,imid+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if ibeg>0
                    T = T( [1:ibeg+2,ibeg+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if iend>0
                    T = T( [1:iend+2,iend+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if ialone>0
                    T = T( [1:ialone+2,ialone+4:end] , : );
                    T = vertcat(T,0);
                else
                end


        sd.ChocolateOfferCountedLog=T;
        for t=1:(length(T)-61)
            if T(t)==0 && T(t+2)==1
                sd.ChocolateOfferCountedLog(t+2)=sum(T(t+2:t+61));
                sd.ChocolateOfferCountedLog(t+3:t+61)=0;
            else
            end
        end


T=RawData{animal,day}(:,14);

        	    imid=strfind(T', ([1 0 1 1 0 1]));
                ibeg=strfind(T', ([0 0 1 1 0 1]));
                iend=strfind(T', ([1 0 1 1 0 0]));
                ialone=strfind(T', ([0 0 1 1 0 0]));

                if imid>0
                    T = T( [1:imid+2,imid+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if ibeg>0
                    T = T( [1:ibeg+2,ibeg+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if iend>0
                    T = T( [1:iend+2,iend+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if ialone>0
                    T = T( [1:ialone+2,ialone+4:end] , : );
                    T = vertcat(T,0);
                else
                end


        sd.BananaOfferCountedLog=T;
        for t=1:(length(T)-61)
            if T(t)==0 && T(t+2)==1
                sd.BananaOfferCountedLog(t+2)=sum(T(t+2:t+61));
                sd.BananaOfferCountedLog(t+3:t+61)=0;
            else
            end
        end




T=RawData{animal,day}(:,19);
      
              
                 imid=strfind(T', ([1 0 1 1 0 1]));
                ibeg=strfind(T', ([0 0 1 1 0 1]));
                iend=strfind(T', ([1 0 1 1 0 0]));
                ialone=strfind(T', ([0 0 1 1 0 0]));

                if imid>0
                    T = T( [1:imid+2,imid+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if ibeg>0
                    T = T( [1:ibeg+2,ibeg+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if iend>0
                    T = T( [1:iend+2,iend+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if ialone>0
                    T = T( [1:ialone+2,ialone+4:end] , : );
                    T = vertcat(T,0);
                else
                end


        sd.GrapeOfferCountedLog=T;
        for t=1:(length(T)-61)
            if T(t)==0 && T(t+2)==1
                sd.GrapeOfferCountedLog(t+2)=sum(T(t+2:t+61));
                sd.GrapeOfferCountedLog(t+3:t+61)=0;
            else
            end
        end


T=RawData{animal,day}(:,24);

                imid=strfind(T', ([1 0 1 1 0 1]));
                ibeg=strfind(T', ([0 0 1 1 0 1]));
                iend=strfind(T', ([1 0 1 1 0 0]));
                ialone=strfind(T', ([0 0 1 1 0 0]));

                if imid>0
                    T = T( [1:imid+2,imid+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if ibeg>0
                    T = T( [1:ibeg+2,ibeg+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if iend>0
                    T = T( [1:iend+2,iend+4:end] , : );
                    T = vertcat(T,0);
                else
                end

                if ialone>0
                    T = T( [1:ialone+2,ialone+4:end] , : );
                    T = vertcat(T,0);
                else
                end


        sd.PlainOfferCountedLog=T;
        for t=1:(length(T)-61)
            if T(t)==0 && T(t+2)==1
                sd.PlainOfferCountedLog(t+2)=sum(T(t+2:t+61));
                sd.PlainOfferCountedLog(t+3:t+61)=0;
            else
            end
        end


sd.Flavor=y.T;
sd.Flavor(:,end)=NaN;
sd.Flavor(sd.ChocolateOfferCountedLog~=0)=1;
sd.Flavor(sd.BananaOfferCountedLog~=0)=2;
sd.Flavor(sd.GrapeOfferCountedLog~=0)=3;
sd.Flavor(sd.PlainOfferCountedLog~=0)=4;
sd.Flavor=sd.Flavor (isfinite(sd.Flavor (:, 1)), :);







sd.OfferTimeStampLog=x.T;
sd.OfferTimeStampLog (sd.ChocolateOfferCountedLog==0 & sd.BananaOfferCountedLog==0 & sd.GrapeOfferCountedLog==0 & sd.PlainOfferCountedLog==0) = NaN;



sd.Offer=x.T;
sd.Offer(:,end)=NaN;

for t=1:(length(sd.Offer))
    if sd.ChocolateOfferCountedLog(t)~=0
        sd.Offer(t)=sd.ChocolateOfferCountedLog(t);
    elseif sd.BananaOfferCountedLog(t)~=0
        sd.Offer(t)=sd.BananaOfferCountedLog(t);
    elseif sd.GrapeOfferCountedLog(t)~=0
        sd.Offer(t)=sd.GrapeOfferCountedLog(t);
    elseif sd.PlainOfferCountedLog(t)~=0
        sd.Offer(t)=sd.PlainOfferCountedLog(t);
    end
end
        

sd.Offer=sd.Offer (isfinite(sd.Offer (:, 1)), :);


sd.OfferTimeStamp=sd.OfferTimeStampLog (isfinite(sd.OfferTimeStampLog (:, 1)), :);


sd.EnterTimeStampLog=x.T;
sd.EnterTimeStampLog (RawData{animal,day}(:,11)==0 & RawData{animal,day}(:,16)==0 & RawData{animal,day}(:,21)==0 & RawData{animal,day}(:,26)==0) = NaN;
sd.EnterTimeStampShort=sd.EnterTimeStampLog (isfinite(sd.EnterTimeStampLog (:, 1)), :);




sd.SkipTimeStampLog=x.T;
sd.SkipTimeStampLog (RawData{animal,day}(:,10)==0 & RawData{animal,day}(:,15)==0 & RawData{animal,day}(:,20)==0 & RawData{animal,day}(:,25)==0) = NaN;
sd.SkipTimeStampShort=sd.SkipTimeStampLog (isfinite(sd.SkipTimeStampLog (:, 1)), :);


sd.EnterTimeStamp=sd.EnterTimeStampLog;
sd.EnterTimeStamp(isfinite(sd.SkipTimeStampLog))=0;
sd.EnterTimeStamp=sd.EnterTimeStamp (isfinite(sd.EnterTimeStamp (:, 1)), :);
sd.EnterTimeStamp(sd.EnterTimeStamp==0)=NaN;


sd.SkipTimeStamp=sd.SkipTimeStampLog;
sd.SkipTimeStamp(isfinite(sd.EnterTimeStampLog))=0;
sd.SkipTimeStamp=sd.SkipTimeStamp (isfinite(sd.SkipTimeStamp (:, 1)), :);
sd.SkipTimeStamp(sd.SkipTimeStamp==0)=NaN;





sd.QuitTimeStampLog=x.T;
sd.QuitTimeStampLog (RawData{animal,day}(:,12)==0 & RawData{animal,day}(:,17)==0 & RawData{animal,day}(:,22)==0 & RawData{animal,day}(:,27)==0) = NaN;
sd.QuitTimeStampShort=sd.QuitTimeStampLog (isfinite(sd.QuitTimeStampLog (:, 1)), :);

sd.QuitTimeStamp=sd.QuitTimeStampLog;





sd.EarnTimeStampLog=x.T;
sd.EarnTimeStampLog (RawData{animal,day}(:,13)==0 & RawData{animal,day}(:,18)==0 & RawData{animal,day}(:,23)==0 & RawData{animal,day}(:,28)==0) = NaN;
sd.EarnTimeStampShort=sd.EarnTimeStampLog (isfinite(sd.EarnTimeStampLog (:, 1)), :);





sd.QuitTimeStamp(isfinite(sd.EarnTimeStampLog))=0;
sd.QuitTimeStamp(isfinite(sd.SkipTimeStampLog))=0;
sd.QuitTimeStamp=sd.QuitTimeStamp (isfinite(sd.QuitTimeStamp (:, 1)), :);
sd.QuitTimeStamp(sd.QuitTimeStamp==0)=NaN;





sd.EarnTimeStamp=sd.EarnTimeStampLog;
sd.EarnTimeStamp(isfinite(sd.QuitTimeStampLog))=0;
sd.EarnTimeStamp(isfinite(sd.SkipTimeStampLog))=0;
sd.EarnTimeStamp=sd.EarnTimeStamp (isfinite(sd.EarnTimeStamp (:, 1)), :);
sd.EarnTimeStamp(sd.EarnTimeStamp==0)=NaN;


if length(sd.EnterTimeStamp)> length(sd.OfferTimeStamp)
    
        for cutter=1:(length(sd.EnterTimeStamp)-length(sd.OfferTimeStamp))
    
                remove=find(sd.EnterTimeStamp(1:length(sd.OfferTimeStamp))<sd.OfferTimeStamp(1:length(sd.OfferTimeStamp)));
                if isempty(remove)
                    remove=length(sd.EnterTimeStamp);
                    removeL=find(sd.EnterTimeStampLog==sd.EnterTimeStamp(remove));
                    sd.EnterTimeStampLog(removeL)=NaN;
                    sd.EnterTimeStamp = sd.EnterTimeStamp( [1:remove-1,remove+1:end] , : );
                    sd.SkipTimeStamp=sd.SkipTimeStampLog;
                    sd.SkipTimeStamp(isfinite(sd.EnterTimeStampLog))=0;
                    sd.SkipTimeStamp=sd.SkipTimeStamp (isfinite(sd.SkipTimeStamp (:, 1)), :);
                    sd.SkipTimeStamp(sd.SkipTimeStamp==0)=NaN;
                     if isnan(sd.QuitTimeStamp(remove))==1
                            removeL=find(sd.EarnTimeStampLog==sd.EarnTimeStamp(remove));
                            sd.EarnTimeStampLog(removeL)=NaN;
                            sd.EarnTimeStamp = sd.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
                            sd.QuitTimeStamp=sd.QuitTimeStampLog;
                            sd.QuitTimeStamp(isfinite(sd.EarnTimeStampLog))=0;
                            sd.QuitTimeStamp(isfinite(sd.SkipTimeStampLog))=0;
                            sd.QuitTimeStamp=sd.QuitTimeStamp (isfinite(sd.QuitTimeStamp (:, 1)), :);
                            sd.QuitTimeStamp(sd.QuitTimeStamp==0)=NaN;
                        elseif isnan(sd.QuitTimeStamp(remove))==0
                            removeL=find(sd.QuitTimeStampLog==sd.QuitTimeStamp(remove));
                            sd.QuitTimeStampLog(removeL)=NaN;
                            sd.QuitTimeStamp = sd.QuitTimeStamp( [1:remove-1,remove+1:end] , : );
                            sd.EarnTimeStamp=sd.EarnTimeStampLog;
                            sd.EarnTimeStamp(isfinite(sd.QuitTimeStampLog))=0;
                            sd.EarnTimeStamp(isfinite(sd.SkipTimeStampLog))=0;
                            sd.EarnTimeStamp=sd.EarnTimeStamp (isfinite(sd.EarnTimeStamp (:, 1)), :);
                            sd.EarnTimeStamp(sd.EarnTimeStamp==0)=NaN; 
                        end
                else
                    remove=remove(1);
                    removeL=find(sd.EnterTimeStampLog==sd.EnterTimeStamp(remove));
                    sd.EnterTimeStampLog(removeL)=NaN;
                    sd.EnterTimeStamp = sd.EnterTimeStamp( [1:remove-1,remove+1:end] , : );
                    sd.SkipTimeStamp=sd.SkipTimeStampLog;
                    sd.SkipTimeStamp(isfinite(sd.EnterTimeStampLog))=0;
                    sd.SkipTimeStamp=sd.SkipTimeStamp (isfinite(sd.SkipTimeStamp (:, 1)), :);
                    sd.SkipTimeStamp(sd.SkipTimeStamp==0)=NaN;
                            if isnan(sd.QuitTimeStamp(remove))==1
                                removeL=find(sd.EarnTimeStampLog==sd.EarnTimeStamp(remove));
                                sd.EarnTimeStampLog(removeL)=NaN;
                                sd.EarnTimeStamp = sd.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
                                sd.QuitTimeStamp=sd.QuitTimeStampLog;
                                sd.QuitTimeStamp(isfinite(sd.EarnTimeStampLog))=0;
                                sd.QuitTimeStamp(isfinite(sd.SkipTimeStampLog))=0;
                                sd.QuitTimeStamp=sd.QuitTimeStamp (isfinite(sd.QuitTimeStamp (:, 1)), :);
                                sd.QuitTimeStamp(sd.QuitTimeStamp==0)=NaN;
                            elseif isnan(sd.QuitTimeStamp(remove))==0
                                removeL=find(sd.QuitTimeStampLog==sd.QuitTimeStamp(remove));
                                sd.QuitTimeStampLog(removeL)=NaN;
                                sd.QuitTimeStamp = sd.QuitTimeStamp( [1:remove-1,remove+1:end] , : );
                                sd.EarnTimeStamp=sd.EarnTimeStampLog;
                                sd.EarnTimeStamp(isfinite(sd.QuitTimeStampLog))=0;
                                sd.EarnTimeStamp(isfinite(sd.SkipTimeStampLog))=0;
                                sd.EarnTimeStamp=sd.EarnTimeStamp (isfinite(sd.EarnTimeStamp (:, 1)), :);
                                sd.EarnTimeStamp(sd.EarnTimeStamp==0)=NaN; 
                            end
                end
        end


    
else
end


if length(sd.EarnTimeStamp)> length(sd.OfferTimeStamp)
    for cutter2=1:(length(sd.EarnTimeStamp)-length(sd.OfferTimeStamp))
            remove=find(sd.EarnTimeStamp(1:length(sd.OfferTimeStamp))<sd.OfferTimeStamp(1:length(sd.OfferTimeStamp)));
            if isempty(remove)
                remove=length(sd.EarnTimeStamp);
                removeL=find(sd.EarnTimeStampLog==sd.EarnTimeStamp(remove));
                sd.EarnTimeStampLog(removeL)=NaN;
                sd.EarnTimeStamp = sd.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
                sd.QuitTimeStamp=sd.QuitTimeStampLog;
                sd.QuitTimeStamp(isfinite(sd.EarnTimeStampLog))=0;
                sd.QuitTimeStamp(isfinite(sd.SkipTimeStampLog))=0;
                sd.QuitTimeStamp=sd.QuitTimeStamp (isfinite(sd.QuitTimeStamp (:, 1)), :);
                sd.QuitTimeStamp(sd.QuitTimeStamp==0)=NaN;
            else
                remove=remove(1);
                removeL=find(sd.EarnTimeStampLog==sd.EarnTimeStamp(remove));
                sd.EarnTimeStampLog(removeL)=NaN;
                sd.EarnTimeStamp = sd.EarnTimeStamp( [1:remove-1,remove+1:end] , : );
                sd.QuitTimeStamp=sd.QuitTimeStampLog;
                sd.QuitTimeStamp(isfinite(sd.EarnTimeStampLog))=0;
                sd.QuitTimeStamp(isfinite(sd.SkipTimeStampLog))=0;
                sd.QuitTimeStamp=sd.QuitTimeStamp (isfinite(sd.QuitTimeStamp (:, 1)), :);
                sd.QuitTimeStamp(sd.QuitTimeStamp==0)=NaN;
            end
    end
else
end



if length(sd.OfferTimeStamp) > length(sd.EnterTimeStamp)
    remove=(length(sd.OfferTimeStamp)-length(sd.EnterTimeStamp));
    sd.OfferTimeStamp=sd.OfferTimeStamp(1:end-(remove),:);
    sd.Flavor=sd.Flavor(1:end-(remove),:);
    sd.Offer=sd.Offer(1:end-(remove),:);
    sd.EnterTime=sd.EnterTimeStamp -sd.OfferTimeStamp;
    sd.SkipTime=sd.SkipTimeStamp -sd.EnterTimeStamp;
else
    sd.EnterTime=sd.EnterTimeStamp -sd.OfferTimeStamp;
    sd.SkipTime=sd.SkipTimeStamp -sd.EnterTimeStamp;
end




if length(sd.OfferTimeStamp) > length(sd.EarnTimeStamp)
    remove=(length(sd.OfferTimeStamp)-length(sd.QuitTimeStamp));
    sd.OfferTimeStamp=sd.OfferTimeStamp(1:end-(remove),:);
    sd.EnterTimeStamp=sd.EnterTimeStamp(1:end-(remove),:);
    sd.SkipTimeStamp=sd.SkipTimeStamp(1:end-(remove),:);
    sd.Flavor=sd.Flavor(1:end-(remove),:);
    sd.Offer=sd.Offer(1:end-(remove),:);
    sd.EnterTime=sd.EnterTime(1:end-(remove),:);
    sd.SkipTime=sd.SkipTime(1:end-(remove),:);
    sd.QuitTime=sd.QuitTimeStamp -sd.EnterTimeStamp;
    sd.EarnTime=sd.EarnTimeStamp -sd.EnterTimeStamp;
else
    sd.QuitTime=sd.QuitTimeStamp -sd.EnterTimeStamp;
    sd.EarnTime=sd.EarnTimeStamp -sd.EnterTimeStamp;
end



sd.WorkTime=sd.EarnTimeStamp -sd.OfferTimeStamp;



sd.nOffers=length(sd.OfferTimeStamp);
sd.nEnters=sum(~isnan(sd.EnterTimeStamp));
sd.nSkips=sum(~isnan(sd.SkipTimeStamp));
sd.nQuits=sum(~isnan(sd.QuitTimeStamp));
sd.nEarns=sum(~isnan(sd.EarnTimeStamp));


sd=rmfield(sd,'OfferTimeStampLog');
sd=rmfield(sd,'EarnTimeStampLog');
sd=rmfield(sd,'EarnTimeStampShort');
sd=rmfield(sd,'SkipTimeStampLog');
sd=rmfield(sd,'SkipTimeStampShort');
sd=rmfield(sd,'QuitTimeStampLog');
sd=rmfield(sd,'QuitTimeStampShort');
sd=rmfield(sd,'EnterTimeStampLog');
sd=rmfield(sd,'EnterTimeStampShort');
sd=rmfield(sd,'ChocolateOfferCountedLog');
sd=rmfield(sd,'BananaOfferCountedLog');
sd=rmfield(sd,'GrapeOfferCountedLog');
sd=rmfield(sd,'PlainOfferCountedLog');
clear('t');
clear('T');
clear('tt');
clear('ttt');
clear('ans');
clear('ialone');
clear('ibeg');
clear('imid');
clear('iend');
clear('remove');
clear('removeL');
clear('cutter');
clear('cutter2');



      
keys.SSN=['M',num2str(setmouse+animal,'%03d'),'-',datestr(setday+day,'yyyy-mm-dd')];
keys.Protocol='Behavior';
keys.Behavior='RRow';

if animal==1 || animal == 2 || animal == 3 || animal == 4
keys.RunningRoom='3';
elseif animal==5 || animal == 6 || animal == 7 || animal == 8
keys.RunningRoom='4';
else
end

keys.TaskType='DTvsWT';
keys.Study='Cocaine Off-Board PM';
keys.DayOfStudy=day;
            if day<6
                    keys.FeederDelayList=(1:5);
                    keys.PhaseOfStudy=['1 sec training ',num2str(day)];
                elseif day>5 && day<11
                    keys.FeederDelayList=(1:5);
                    keys.PhaseOfStudy=['5 sec training ',num2str(day-5)];
                elseif day>10 && day<16
                    keys.FeederDelayList=(1:15);
                    keys.PhaseOfStudy=['15 sec training ',num2str(day-10)];
                elseif day>16
                    keys.FeederDelayList=(1:30);
                elseif day>16 && day<21
                    keys.PhaseOfStudy=['30 sec training ',num2str(day-16)];
                elseif day>20 && day<42
                    keys.PhaseOfStudy=['baseline RRow ',num2str(day-20)];
                elseif day>41 && day<44
                    keys.PhaseOfStudy=['baseline saline injection ',num2str(day-41)];
                elseif day>43 && day<49
                    keys.PhaseOfStudy=['treatment injection ',num2str(day-43)];
                elseif day>48 && day<63
                    keys.PhaseOfStudy=['withdrawal ',num2str(day-48)];
                elseif day>62 && day<64
                    keys.PhaseOfStudy=('challenge');
                elseif day>63 && day<79
                    keys.PhaseOfStudy=['post-challenge ',num2str(day-63)];
            end
            
            
keys.Flavors={'chocolate', 'banana', 'grape', 'plain'};            
keys.PelletNumber=[1,1,1,1];
keys.FeederProbability=[1,1,1,1];
           
                if animal==1 || animal == 3 || animal == 5 || animal == 7
                keys.Condition='Saline';
                keys.Dose='n/a';
                keys.SolutionConc='n/a';
                elseif animal==2 || animal == 4 || animal == 6 || animal == 8
                keys.Condition='Cocaine';
                keys.Dose='15mg/kg';
                keys.SolutionConc='3mg/mL';
                else
                end


keys.PreWeight=setpreweight(animal,day);
keys.PostWeight=setpostweight(animal,day);
keys.Note='';






mkdir('C:\Users\TLWS-11\Desktop\Document/MATLAB\BrianDatabase\',sd.SSN(1:4)); warning('off')
mkdir(['C:\Users\TLWS-11\Desktop\Document/MATLAB\BrianDatabase\',sd.SSN(1:4)],sd.SSN);
save(['C:\Users\TLWS-11\Desktop\Document/MATLAB\BrianDatabase\',sd.SSN(1:4),'\',sd.SSN,'\',sd.SSN,'-vt.mat'],'x','y');
save(['C:\Users\TLWS-11\Desktop\Document/MATLAB\BrianDatabase\',sd.SSN(1:4),'\',sd.SSN,'\',sd.SSN,'-sd.mat'],'sd');
save(['C:\Users\TLWS-11\Desktop\Document/MATLAB\BrianDatabase\',sd.SSN(1:4),'\',sd.SSN,'\',sd.SSN,'-keys.mat'],'keys');







    end
end
end

