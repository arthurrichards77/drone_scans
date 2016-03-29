close all
clear all

% field polygon
% each column is a vertex
P = [0 0;
     0 1;
     1 1;
     1 0;
     0.75 0;
     0.75 0.5;
     0.3 0.5;
     0.3 0]';

% strip angle
ang = -1*pi/12;

% strip width
wid = 0.1;

% strip offset
ofs = -0.0;

% divide into strips
[strips,flights] = stripPoly(P,ang,wid,ofs);

% plot the original field
patch(P(1,:),P(2,:),'g')
axis equal
hold on

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