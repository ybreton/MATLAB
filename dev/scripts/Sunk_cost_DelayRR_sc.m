%%
cd('R210')
RR_SUM_V1P0.R210 = summarize_restaurant_row;
cd ..
cd('R222')
RR_SUM_V1P0.R222 = summarize_restaurant_row;
cd ..
cd('R231')
RR_SUM_V1P0.R231 = summarize_restaurant_row;
cd ..
cd('R234')
RR_SUM_V1P0.R234 = summarize_restaurant_row;
cd ..

%%
figure
plot_sunkCost_pWait_vs_LogD_Zone_each_cumskip(RR_SUM_V1P0.R210)
%%
figure
plot_sunkCost_pWait_vs_LogD_Zone_each_cumskip(RR_SUM_V1P0.R222)
%%
figure
plot_sunkCost_pWait_vs_LogD_Zone_each_cumskip(RR_SUM_V1P0.R231)
%%
figure
plot_sunkCost_pWait_vs_LogD_Zone_each_cumskip(RR_SUM_V1P0.R234)