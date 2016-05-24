function [logIdPhi,fh] = plot_cp_pass(lap,sd2)

x0 = sd2.x.restrict(sd2.EnteringCPTime(lap),sd2.ExitingCPTime(lap));
y0 = sd2.y.restrict(sd2.EnteringCPTime(lap),sd2.ExitingCPTime(lap));
clf
hold on
try
    vObj = VideoReader('VT1_mpeg1.mpg'); 
    cdata = read(vObj,1); 
    imagesc(cdata); 
end
plot(x0.data,y0.data,'r-','linewidth',3)
axis image
set(gca,'xlim',[0 720])
set(gca,'ylim',[0 480])
set(gca,'xtick',[])
set(gca,'ytick',[])
logIdPhi = log10(sd2.IdPhi(lap));
hold off
fh = gcf;