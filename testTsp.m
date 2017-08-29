close all
clear all

% flight parameters
Rmin = 35;
vAir = 10;
vWind = [6.5,1.0];
%vWind = [-0.2,-0.4];
%vWind = [0.1,0.5];
%Rmin = 1.5;

% field polygon
P = 50*[0 6 6 0 0 3 3 0 ;
    0  0 6 6 4 4 2 2];

% strip width
stripWidth = 30;

% strip offset
cutOffset = -0.0;

% strip angle
cutAngle = 0.33*pi/2;

[scanTime,turnTime,totalTime,pp,strips] = tspSequence(P,cutAngle,stripWidth,cutOffset,Rmin,vAir,vWind);

plotFlight(pp,strips,P,vWind)
% results summary in title
title(sprintf('%.0f^o TSP : %.1f scanning and %.1f turning : %.1f total',cutAngle*180/pi,scanTime,turnTime,totalTime))

% save for simulink validation
save sim/testpath totalTime pp vWind vAir Rmin