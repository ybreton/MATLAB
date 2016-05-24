for iF = 1:100;
f = v.frames(iF).cdata; 
f = f*5;
imagesc(f); 
colormap(gray)
drawnow;
end