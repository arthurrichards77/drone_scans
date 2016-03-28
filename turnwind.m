% find fastest turn path in wind
% adopt method from McGee Spry and Hedrick
close all
clear all

% min turn radius
Rmin = 2;

% initconfig
% [x;y;hdg]
cInit = [0;0;0];
cTerm = [5;-5;pi/2];

[px,py,pt]=shortestWindPath(cInit,cTerm,Rmin);

plot(px,py,'b', ...
     cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'g-',...
     cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-')
axis equal