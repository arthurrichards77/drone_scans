close all
clear all

%% flight parameters
Rmin = 35;
vAir = 10;
vWind = [0.0,-2.0];

% strip width
stripWidth = 30;

% rectangular field
Pell = [0 400 400 110 110 0;
    0 0 80 80 200 200];

% rotation angle
rotAngle = -45*pi/180;

% rotate the field
P = [cos(rotAngle) sin(rotAngle);
    -sin(rotAngle) cos(rotAngle)]*Pell;

% strip offset
cutOffset = -0.0;

% strip angle
cutAngle = 225*pi/180;

[scanTime,turnTime,totalTime,pp,strips] = simpleSequence(P,cutAngle,stripWidth,cutOffset,Rmin,vAir,vWind);

plotFlight(pp,strips,P,vWind,vAir)
% results summary in title
title(sprintf('%.0f^o UPW : %.1f scanning and %.1f turning : %.1f total',cutAngle*180/pi,scanTime,turnTime,totalTime))

save sim/testpath totalTime pp vWind vAir Rmin

print -dpng best/ell2rlw_seq.png