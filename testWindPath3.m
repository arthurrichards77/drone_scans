% find fastest turn path in wind
% adopt method from McGee Spry and Hedrick
close all
clear all

% extra test case
% seems to break it

cInit = [   5.604995403862970
  16.027058452307706
   0.720464702672919]

cTerm = [    -0.104995403862968
   2.422594429285895
   0.720464702672919]

% flight parameters
Rmin = 0.75;
vAir = 1;
vWind = [-0.00001,-0.5];

% find the shortest path in wind
[px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vAir,vWind);

figure
plot(px,py,'b-', ...
     pxa,pya,'r--', ...
     cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'m-',...
     cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-', ...
     cInit(1),cInit(2),'mo',...
     cTerm(1),cTerm(2),'go')
title(sprintf('Path length %5.2f of type %s',max(pt),clInc))
axis equal
grid on
