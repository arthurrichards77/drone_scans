close all
clear all

vWind = [0.1,-0.9];

Va = 1.2;

trk = -1*pi/4;

[hdg,Vg] = hdgSpdForTrkInWind(Va,trk,vWind)

% debug - plot the vectors
figure
plot([0 Vg*cos(trk)],[0 Vg*sin(trk)],'g-', ...
    [0 Va*cos(hdg)],[0 Va*sin(hdg)],'b-', ...
    Va*cos(hdg)+[0 vWind(1)],Va*sin(hdg)+[0 vWind(2)],'r-',...
    0,0,'ko')
legend('Ground','Air','Wind')
axis equal
title(sprintf('Fly heading %.1f^o : ground speed %.1f',hdg*180/pi,Vg))