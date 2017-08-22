% test Dubins path finder
close all
clear all

% min turn radius
Rmin = 1.0;

% initconfig
% [x;y;hdg]

% example 1 from paper
cInit = [0;0;pi/2];
cTerm = [-1.5;2.0;-pi/4];

subplot 331

[px,py,pt,clInc]=shortestDubinsPath(cInit,cTerm,Rmin,[]);

plot(px,py,'b-', ...
    cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'g-',...
    cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-', ...
        cInit(1),cInit(2),'go', ...
        cTerm(1),cTerm(2),'go')
title(sprintf('Shortest length %.2f of type %s',max(pt),clInc))
axis equal
grid on

for cc=1:8,
    
    % choose just single mask
    clMask = ((1:8)==cc);
    [px,py,pt,clInc]=shortestDubinsPath(cInit,cTerm,Rmin,clMask);
    
    subplot(3,3,cc+1)
    plot(px,py,'b-', ...
        cInit(1)+[0 cos(cInit(3))],cInit(2)+[0 sin(cInit(3))],'g-', ...
        cTerm(1)+[0 cos(cTerm(3))],cTerm(2)+[0 sin(cTerm(3))],'g-', ...
        cInit(1),cInit(2),'go', ...
        cTerm(1),cTerm(2),'go')
    title(sprintf('Path length %.2f of type %s',max(pt),clInc))
    axis equal
    grid on
    
end