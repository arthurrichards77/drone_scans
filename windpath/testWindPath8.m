close all
clear all

% straight flight case

load testcase.mat
%cTerm = cTerm*(1-1e-3);

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
