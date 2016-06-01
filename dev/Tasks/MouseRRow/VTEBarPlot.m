function bar_handle = VTEBarPlot(allVTE,startday,endday,Title)

figure()
a=startday;b=endday;
bar_handle=bar([mean(allVTE.zIdPhi.skip(allVTE.condition.skip==1 & (allVTE.day.skip>a & allVTE.day.skip<b)))       mean(allVTE.zIdPhi.enter(allVTE.condition.enter==1 & (allVTE.day.enter>a & allVTE.day.enter<b)))     mean(allVTE.zIdPhi.enterToQuit(allVTE.condition.enterToQuit==1 & (allVTE.day.enterToQuit>a & allVTE.day.enterToQuit<b)))      mean(allVTE.zIdPhi.enterToEarn(allVTE.condition.enterToEarn==1 & (allVTE.day.enterToEarn>a & allVTE.day.enterToEarn<b)))
mean(allVTE.zIdPhi.skip(allVTE.condition.skip==2 & (allVTE.day.skip>a & allVTE.day.skip<b))) mean(allVTE.zIdPhi.enter(allVTE.condition.enter==2 & (allVTE.day.enter>a & allVTE.day.enter<b)))     mean(allVTE.zIdPhi.enterToQuit(allVTE.condition.enterToQuit==2 & (allVTE.day.enterToQuit>a & allVTE.day.enterToQuit<b)))      mean(allVTE.zIdPhi.enterToEarn(allVTE.condition.enterToEarn==2 & (allVTE.day.enterToEarn>a & allVTE.day.enterToEarn<b)))]);
title (Title)
xlabel ('treatment')
ylabel ('decision zone zIdPhi (sec)')
set(gca, 'XTickLabel',{'saline','cocaine'})
set(bar_handle(1),'FaceColor','r')
set(bar_handle(2),'FaceColor','g')
set(bar_handle(3),'FaceColor','y')
set(bar_handle(4),'FaceColor','c')
axis([0.5 2.5 -.3 0.31])
legend('skip', 'enter', 'enterToQuit', 'enterToEarn')



