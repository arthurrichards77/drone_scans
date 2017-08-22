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

% option to treat third element as a ground track rather than a heading
%[cInit(3),Vg]=hdgSpdForTrkInWind(vAir,cInit(3),vWind);
%[cTerm(3),Vg]=hdgSpdForTrkInWind(vAir,cTerm(3),vWind);

% find the shortest path in wind
[px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vAir,vWind);

subplot 221
plot(px,py,'b-', ...
     pxa,pya,'r--', ...
     cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'g-',...
     cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-')
title(sprintf('Path time %5.2f of type %s',max(pt),clInc))
axis equal
grid on

% example 2 from paper
cInit = [0;0;pi/4];
cTerm = [5;1;pi];
vWind = [0.5 0];

% find the shortest path in wind
[px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vAir,vWind);

subplot 222
plot(px,py,'b-', ...
     pxa,pya,'r--', ...
     cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'g-',...
     cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-')
title(sprintf('Path time %5.2f of type %s',max(pt),clInc))
axis equal
grid on

% % example 3 from paper
cInit = [0;0;0];
cTerm = [-5.5;2;0];
vWind = [-0.9 0];

% find the shortest path in wind
[px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vAir,vWind);

subplot 223
plot(px,py,'b-', ...
     pxa,pya,'r--', ...
     cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'g-',...
     cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-')
title(sprintf('Path time %5.2f of type %s',max(pt),clInc))
axis equal
grid on

% % another one from paper
cInit = [0;0;0];
cTerm = [-0.43;0.56;0];
vWind = [-0.9 0];

% find the shortest path in wind
[px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vAir,vWind);

subplot 224
plot(px,py,'b-', ...
     pxa,pya,'r--', ...
     cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'g-',...
     cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-')
title(sprintf('Path time %5.2f of type %s',max(pt),clInc))
axis equal
grid on

%%
% extra test case
% seems to break it

cInit =[         0
         0
   -2.7745];


cTerm = [    1.4990
    0.3618
    1.5179];

Rmin = 0.75;
vAir = 2;
vWind = [0.6,-0.1];

% find the shortest path in wind
[px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vAir,vWind);

figure
plot(px,py,'b-', ...
     pxa,pya,'r--', ...
     cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'m-',...
     cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-', ...
     cInit(1),cInit(2),'mo',...
     cTerm(1),cTerm(2),'go')
title(sprintf('Path time %5.2f of type %s',max(pt),clInc))
axis equal
grid on
