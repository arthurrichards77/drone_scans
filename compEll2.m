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
Pell = [0 400 400 110 110 0;
    0 0 80 80 200 200];

% rotation angle
rotAngle = 45*pi/180;

% rotate the field
P = [cos(rotAngle) sin(rotAngle);
    -sin(rotAngle) cos(rotAngle)]*Pell;

%% data saving options
plotFlag = true;
saveFlag = true;
fStub = 'results/ell2';

[bestTime,bestIndx,scanTimeList,turnTimeList]=tspSweepAngs(P,Rmin,vAir,vWind,stripWidth,plotFlag,saveFlag,fStub);

