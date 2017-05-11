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
ang = 1.75*pi/2;

% strip width
wid = 1;

% strip offset
ofs = -0.0;

% divide into strips
[strips,stripFlights] = stripPoly(P,ang,wid,ofs);

% plot the original field
patch(P(1,:),P(2,:),'g')
axis equal
hold on

% sort flights towards wind
stripFlights = sortFlights(stripFlights,[sin(ang);-cos(ang)]);

% plot what we got back
numStrips = numel(strips);
for pp=1:numStrips,
    thisP = strips{pp};
    if numel(thisP)>0,
        col = 'c'; %[pp 0 numStrips-pp]/numStrips;
        patch(strips{pp}(1,:),strips{pp}(2,:),col,'FaceAlpha',0.5)
        plot(stripFlights{pp}(1,:),stripFlights{pp}(2,:),'ko--')
    end
end

% find flight times and headings for each strip
for ii=1:numStrips,
    % in both directions
    for dd=[1,2],
        % the start and end points, in that order
        nextFlt = stripFlights{ii}(:,[3-dd dd]);
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

%optional plot highlighting
stripHighlight = 1;

% find all possible transit times
for ii=1:numStrips,
    for di=[1 2],
        % get the next strip
        currFlt = stripFlights{ii}(:,[3-di di]);
        currHdg = stripHdgs(ii,di);
        % store the "cost" - time to complete strip ii in direction
        % di and then stop (i.e. do task 2N+1)
        cost(1+2*ii-di,2*numStrips+1) = stripTimes(ii,di);
        for jj=1:(ii-1),
            for dj=[1 2],
                
                % get the next strip
                nextFlt = stripFlights{jj}(:,[3-dj dj]);
                nextHdg = stripHdgs(jj,dj);
                % curr to next
                cInit = [currFlt(:,2);currHdg];
                cTerm = [nextFlt(:,1);nextHdg];
                [px,py,ptt,pxa,pya,clInc]=shortestWindPathDB(cInit,cTerm,Rmin,vAir,vWind);
                % plot the things
                if (jj==stripHighlight)||(ii==stripHighlight),
                    plot(px,py,'m-')
                end
                % store the distances - from end of ii in direction di
                % to start of strip jj in direction dj
                transitTimes(1+2*ii-di,1+2*jj-dj) = ptt(end);
                % and the flights
                transitFlights{ii,di,jj,dj} = [px;py];
                % store the "cost" - time to complete strip ii in direction
                % di and then fly to start of strip jj direction dj
                cost(1+2*ii-di,1+2*jj-dj) = transitTimes(1+2*ii-di,1+2*jj-dj) + stripTimes(ii,di);
                
                % opposite direction: next to curr
                cInit = [nextFlt(:,2);nextHdg];
                cTerm = [currFlt(:,1);currHdg];
                [px,py,ptt,pxa,pya,clInc]=shortestWindPathDB(cInit,cTerm,Rmin,vAir,vWind);
                % plot the things
                if (jj==stripHighlight)||(ii==stripHighlight),
                    plot(px,py,'m-')
                end% store the distances
                transitTimes(1+2*jj-dj,1+2*ii-di) = ptt(end);
                % and the flights
                transitFlights{jj,dj,ii,di} = [px;py];
                % store the "cost" - time to complete strip jj in direction
                % dj and then fly to start of strip ii direction di
                cost(1+2*jj-dj,1+2*ii-di) = transitTimes(1+2*jj-dj,1+2*ii-di) + stripTimes(jj,dj);
                
            end
        end
    end
end


[pp,pt,scanTime,turnTime] = simpleOrderedSequence(stripFlights,stripTimes,transitFlights,transitTimes);
plot(pp(1,:),pp(2,:),'k-', ...
    1.2*max(P(1,:)), 1.2*max(P(2,:)),'ro', 1.2*max(P(1,:)) + [0 vWind(1)], 1.2*max(P(2,:)) + [0 vWind(2)],'r-', ...
    pp(1,1),pp(2,1),'k^','LineWidth',1.5)
title(sprintf('%.0f^o : %.1f scanning and %.1f turning : %.1f total',ang*180/pi,scanTime,turnTime,scanTime+turnTime))

