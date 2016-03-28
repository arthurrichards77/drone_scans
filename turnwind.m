% find fastest turn path in wind
% adopt method from McGee Spry and Hedrick
close all
clear all

% min turn radius
Rmin = 1.0;

% air speed
vAir = 1;

% initconfig
% [x;y;hdg]

% example 1 from paper
cInit = [0;0;pi/2];
cTerm = [-1.5;-2;0];
vWind = [-0.5 0];

% example 2 from paper
cInit = [0;0;pi/4];
cTerm = [5;1;pi];
vWind = [0.5 0];

% example 3 from paper
cInit = [0;0;0];
cTerm = [-6;2;0];
vWind = [-0.9 0];

% another one from paper
cInit = [0;0;0];
cTerm = [-0.0;0.56;0];
vWind = [-0.9 0];

[px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vAir,vWind);

plot(px,py,'b-', ...
     pxa,pya,'r--', ...
     cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'g-',...
     cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-')
title(sprintf('Path length %5.2f of type %s',max(pt),clInc))
axis equal
grid on