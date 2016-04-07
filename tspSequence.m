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
ang = -0.75*pi/2;

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
        col = 'g'; %[pp 0 numStrips-pp]/numStrips;
        patch(strips{pp}(1,:),strips{pp}(2,:),col)
        plot(flights{pp}(1,:),flights{pp}(2,:),'ko--')
    end
end

% find flight times and headings for each strip
for ii=1:numStrips,
    % in both directions    
    for dd=[1,2],        
        % the start and end points, in that order
        nextFlt = flights{ii}(:,[3-dd dd]);        
        % track of flight strip
        nextTrk = atan2((nextFlt(2,2)-nextFlt(2,1)), ...
            (nextFlt(1,2)-nextFlt(1,1)));        
        % heading to fly it
        [nextHdg,nextVg] = hdgSpdForTrkInWind(vAir,nextTrk,vWind);
        % store
        stripHdgs(ii,dd)=nextHdg;
        stripVgs(ii,dd)=nextVg;
        % and the flight time
        stripTimes(ii,dd) = norm(nextFlt(:,2)-nextFlt(:,1))/nextVg;    
    end
end

% find all possible transit times
for ii=2:numStrips,
    for di=[1 2],
        % get the next strip
        currFlt = flights{ii}(:,[3-di di]);
        currHdg = stripHdgs(ii,di);
        for jj=1:(ii-1),
            for dj=[1 2],
                % get the next strip
                nextFlt = flights{jj}(:,[3-dj dj]);        
                nextHdg = stripHdgs(jj,dj);
                % curr to next
                cInit = [currFlt(:,2);currHdg];
                cTerm = [nextFlt(:,1);nextHdg];
                [px,py,ptt,pxa,pya,clInc]=shortestWindPathDB(cInit,cTerm,Rmin,vAir,vWind);
                % plot the things
                plot(px,py,'k-')
                % store the distances - from end of ii in direction di
                % to start of strip jj in direction dj
                d(1+2*ii-di,1+2*jj-dj) = ptt(end);
                % next to curr
                cInit = [nextFlt(:,2);nextHdg];
                cTerm = [currFlt(:,1);currHdg];
                [px,py,ptt,pxa,pya,clInc]=shortestWindPathDB(cInit,cTerm,Rmin,vAir,vWind);
                % plot the things
                plot(px,py,'b-')
                % store the distances
                d(1+2*jj-dj,1+2*ii-di) = ptt(end);
            end
        end
    end
end


[pp,pt,scanTime,turnTime] = simpleOrderedSequence(flights,vAir,Rmin,vWind);
plot(pp(1,:),pp(2,:),'m-', ...
    pp(1,1),pp(2,1),'m^')
title(sprintf('%.0f^o : %.1f scanning and %.1f turning',ang*180/pi,scanTime,turnTime))
