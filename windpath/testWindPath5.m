close all
clear all

% bigger numbers

cInit =[10.361630810247345
   0.507459514884370
  -0.391625547665286];
cTerm =[-0.017624245834763
   8.229932559204578
  -0.391625547665286];
Rmin =0.7500;
vAir =1;
vWind =   [-0.4000    0.4000]
   
% find the shortest path in wind
[px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vAir,vWind);

figure
plot(px,py,'b-', ...
     pxa,pya,'r--', ...
     cInit(1)+10*[0 cos(cInit(3))],cInit(2)+10*[0 sin(cInit(3))],'m-',...
     cTerm(1)+10*[0 cos(cTerm(3))],cTerm(2)+10*[0 sin(cTerm(3))],'g-', ...
     cInit(1),cInit(2),'mo',...
     cTerm(1),cTerm(2),'go',...
     [0 vWind(1)],[0 vWind(2)],'r')
title(sprintf('Path time %5.2f of type %s',max(pt),clInc))
axis equal
grid on
