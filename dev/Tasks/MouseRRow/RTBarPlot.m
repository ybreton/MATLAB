function bar_handle = RTBarPlot(allTimes,startday,endday,Title)

figure()
a=startday;b=endday;
bar_handle=bar([mean(allTimes.time.skip(allTimes.condition.skip==1 & (allTimes.day.skip>a & allTimes.day.skip<b)))       mean(allTimes.time.enter(allTimes.condition.enter==1 & (allTimes.day.enter>a & allTimes.day.enter<b)))     mean(allTimes.time.enterToQuit(allTimes.condition.enterToQuit==1 & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)))      mean(allTimes.time.enterToEarn(allTimes.condition.enterToEarn==1 & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)))
mean(allTimes.time.skip(allTimes.condition.skip==2 & (allTimes.day.skip>a & allTimes.day.skip<b))) mean(allTimes.time.enter(allTimes.condition.enter==2 & (allTimes.day.enter>a & allTimes.day.enter<b)))     mean(allTimes.time.enterToQuit(allTimes.condition.enterToQuit==2 & (allTimes.day.enterToQuit>a & allTimes.day.enterToQuit<b)))      mean(allTimes.time.enterToEarn(allTimes.condition.enterToEarn==2 & (allTimes.day.enterToEarn>a & allTimes.day.enterToEarn<b)))]);
title (Title)
xlabel ('treatment')
ylabel ('decision time (sec)')
set(gca, 'XTickLabel',{'saline','cocaine'})
set(bar_handle(1),'FaceColor','r')
set(bar_handle(2),'FaceColor','g')
set(bar_handle(3),'FaceColor','y')
set(bar_handle(4),'FaceColor','c')
axis([0.5 2.5 .8 1.5])
legend('skip', 'enter', 'enterToQuit', 'enterToEarn')



