a=39;b=45;c=44;d=50;

RT(2,2)= mean(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)));
RT(1,2) = mean(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)));
RT(1,1)= mean(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)));
RT(2,1)= mean(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)));
RT(4,2)= mean(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)));
RT(3,2)= mean(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)));
RT(3,1)= mean(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)));
RT(4,1)= mean(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)));



RT(6,2)= std(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)))/sqrt(length((allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)))));
RT(5,2) = std(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)))/sqrt(length((allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)))));
RT(5,1)= std(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)))/sqrt(length((allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)))));
RT(6,1)= std(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)))/sqrt(length((allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)))));
RT(8,2)= std(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)))/sqrt(length((allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)))));
RT(7,2)= std(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)))/sqrt(length((allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)))));
RT(7,1)= std(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)))/sqrt(length((allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)))));
RT(8,1)= std(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)))/sqrt(length((allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)))));



a=49;b=55;c=58;d=64;
RT(2,2)= mean(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)));
RT(1,2) = mean(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)));
RT(1,1)= mean(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)));
RT(2,1)= mean(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)));
RT(4,2)= mean(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)));
RT(3,2)= mean(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)));
RT(3,1)= mean(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)));
RT(4,1)= mean(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)));



RT(6,2)= std(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)))/sqrt(length((allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)))));
RT(5,2) = std(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)))/sqrt(length((allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)))));
RT(5,1)= std(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)))/sqrt(length((allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)))));
RT(6,1)= std(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)))/sqrt(length((allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)))));
RT(8,2)= std(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)))/sqrt(length((allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)))));
RT(7,2)= std(allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)))/sqrt(length((allTimes.time.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)))));
RT(7,1)= std(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)))/sqrt(length((allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)))));
RT(8,1)= std(allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)))/sqrt(length((allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)))));








t4= (allTimes.day.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)));
t2= (allTimes.day.enterToEarn((allTimes.mouse.enterToEarn==1 | allTimes.mouse.enterToEarn==3 | allTimes.mouse.enterToEarn==5 | allTimes.mouse.enterToEarn==7) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)));
t1= (allTimes.day.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)));
t3= (allTimes.day.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)));
t8= (allTimes.day.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>c & allTimes.day.enterToEarn<d)));
t6= (allTimes.day.enterToEarn((allTimes.mouse.enterToEarn==2 | allTimes.mouse.enterToEarn==4 | allTimes.mouse.enterToEarn==6 | allTimes.mouse.enterToEarn==8) & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)));
t5= (allTimes.day.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)));
t7= (allTimes.day.enterToQuit((allTimes.mouse.enterToQuit==2 | allTimes.mouse.enterToQuit==4 | allTimes.mouse.enterToQuit==6 | allTimes.mouse.enterToQuit==8) & (allTimes.day.enterToQuit>c & allTimes.day.enterToQuit<d)));

vertcat((allTimes.time.enterToQuit((allTimes.mouse.enterToQuit==1 | allTimes.mouse.enterToQuit==3 | allTimes.mouse.enterToQuit==5 | allTimes.mouse.enterToQuit==7) & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b))),








VTEBarPlot(allVTE,39,45,'5 Days Baseline');
VTEBarPlot(allVTE,44,50,'5 Days Injections');
VTEBarPlot(allVTE,49,55,'First 5 Days Abstinence');
VTEBarPlot(allVTE,58,64,'Last 5 Days Abstinence');
VTEBarPlot(allVTE,63,69,'5 Days Post Challenge');
