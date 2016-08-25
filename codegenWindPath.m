% find fastest turn path in wind
% adopt method from McGee Spry and Hedrick
close all
clear all

% extra test case
% seems to break it

cInit =[         0
         0
   -2.7745];


cTerm = [    1.4990
    0.3618
    1.5179];

Rmin = 0.75;
vAir = 1;
vWind = [0.6,-0.1];

% find the shortest path in wind
tic
[px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vAir,vWind);
toc

figure
subplot 211
plot(px,py,'b-', ...
     pxa,pya,'r--', ...
     cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'m-',...
     cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-', ...
     cInit(1),cInit(2),'mo',...
     cTerm(1),cTerm(2),'go')
title(sprintf('Path length %5.2f of type %s',max(pt),clInc))
axis equal
grid on

%% code generation

% now codegen it
codegen shortestWindPath.m -args {coder.typeof(cInit),coder.typeof(cTerm),coder.typeof(Rmin),coder.typeof(vAir),coder.typeof(vWind)}

%% test mex

% find the shortest path in wind
tic
[px,py,pt,pxa,pya,clInc]=shortestWindPath_mex(cInit,cTerm,Rmin,vAir,vWind);
toc

subplot 212
plot(px,py,'b-', ...
     pxa,pya,'r--', ...
     cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'m-',...
     cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-', ...
     cInit(1),cInit(2),'mo',...
     cTerm(1),cTerm(2),'go')
title(sprintf('Path length %5.2f of type %s',max(pt),clInc))
axis equal
grid on