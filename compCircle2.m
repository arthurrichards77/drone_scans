close all
clear all
Tstart = tic;

%% flight parameters
Rmin = 35;
vAir = 10;
vWind = [0.0,-2.0];

% strip width
stripWidth = 30;

% strip offset
cutOffset = -0.0;

% strip angle range to try
Nangs = 360;
angs = (1:Nangs)*2*pi/Nangs;

%% field

% circular, almost
ths = 2*pi*(1:90)/90;
Pcirc = 100*[cos(ths);sin(ths)];

% rotation angle
rotAngle = 0.1*pi;

% rotate the field
P = [cos(rotAngle) sin(rotAngle);
    -sin(rotAngle) cos(rotAngle)]*Pcirc;

%% data saving options
plotFlag = true;
saveFlag = true;
fStub = 'results/circ2lw';

[bestTime,bestIndx,scanTimeList,turnTimeList]=tspSweepAngs(P,Rmin,vAir,vWind,stripWidth,plotFlag,saveFlag,fStub);
