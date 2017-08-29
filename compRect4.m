close all
clear all
Tstart = tic;

%% flight parameters
Rmin = 35;
vAir = 10;
vWind = [0.0,-7.0];

% strip width
stripWidth = 30;

% rectangular field
Prect = [0 265 265  0;
    0  0 145 145];

% rotation angle
rotAngle = 112*pi/180;

% rotate the field
P = [cos(rotAngle) sin(rotAngle);
    -sin(rotAngle) cos(rotAngle)]*Prect;

%% data saving options
plotFlag = true;
saveFlag = true;
fStub = 'results/rect4';

[bestTime,bestIndx,scanTimeList,turnTimeList]=tspSweepAngs(P,Rmin,vAir,vWind,stripWidth,plotFlag,saveFlag,fStub);

