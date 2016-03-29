close all
clear all

% flight parameters
Rmin = 0.75;
vAir = 1;
vWind = [0.0001,-0.7];

% field polygon
% simple square
P = [0 10 10 0;
    0  0 10 10];

% strip angle
ang = -1*pi/2;

% strip width
wid = 1;

% strip offset
ofs = -0.0;

% divide into strips
[strips,flights] = stripPoly(P,ang,wid,ofs);

% plot the original field
patch(P(1,:),P(2,:),'g')
axis equal
hold on

% sort flights towards wind
flights = sortFlights(flights,[sin(ang);-cos(ang)]);

% plot what we got back
numStrips = numel(strips);
for pp=1:numStrips,
    thisP = strips{pp};
    if numel(thisP)>0,
        col = [pp 0 numStrips-pp]/numStrips;
        patch(strips{pp}(1,:),strips{pp}(2,:),col)
        plot(flights{pp}(1,:),flights{pp}(2,:),'ko--')
    end
end

[pp,pt,scanTime,turnTime] = simpleOrderedSequence(flights,vAir,Rmin,vWind);
plot(pp(1,:),pp(2,:),'g-', ...
    pp(1,1),pp(2,1),'g^')
title(sprintf('%.0f^o : %.1f scanning and %.1f turning',ang*180/pi,scanTime,turnTime))
