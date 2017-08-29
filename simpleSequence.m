function [scanTime,turnTime,totalTime,pp,strips] = simpleSequence(P,cutAngle,stripWidth,cutOffset,Rmin,vAir,vWind)

% divide into strips
[strips,stripFlights] = stripPoly(P,cutAngle,stripWidth,cutOffset);

% plot the original field
patch(P(1,:),P(2,:),'g')
axis equal
hold on

% sort flights towards wind
stripFlights = sortFlights(stripFlights,[sin(cutAngle);-cos(cutAngle)]);
numStrips = numel(strips);

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
stripHighlight = 0;

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
totalTime = scanTime+turnTime;

end

function [pp,pt,scanTime,turnTime] = simpleOrderedSequence(stripFlights,stripTimes,transitFlights,transitTimes)
%
% pp is matrix of waypoints [.....[xi;yi]......]
% pt is vector of times

% start arbitrarily at flight number one, first end
pp = stripFlights{1};
currFlt = stripFlights{1};
currDir = 2; % column 1 to column 2
%currTrk = atan2((stripFlights{1}(2,currDir)-stripFlights{1}(2,3-currDir)), ...
%    (stripFlights{1}(1,currDir)-stripFlights{1}(1,3-currDir)));
%[currHdg,Vg] = hdgSpdForTrkInWind(vAir,currTrk,vWind);
currTime = stripTimes(1,currDir);
pt = [0 currTime];
turnTime = 0;
scanTime = currTime;

for ii=2:numel(stripFlights),
    
    % stupid simple for now - just work through 1:n
    jj = ii;
    
    % opposite direction
    nextDir = 3-currDir;
    
    % the start and end points, in that order
    nextFlt = stripFlights{jj}(:,[3-nextDir nextDir]);
    
    % track of next flight strip
    %nextTrk = atan2((nextFlt(2,2)-nextFlt(2,1)), ...
    %    (nextFlt(1,2)-nextFlt(1,1)));
    
    % heading to fly it
    %[nextHdg,nextVg] = hdgSpdForTrkInWind(vAir,nextTrk,vWind);
    
    % now find the transition
    %cInit = [currFlt(:,2);currHdg];
    %cTerm = [nextFlt(:,1);nextHdg];
    %[px,py,ptt,pxa,pya,clInc]=shortestWindPathDB(cInit,cTerm,Rmin,vAir,vWind);
    
    % get transition from list
    pxpy = transitFlights{jj-1,currDir,jj,nextDir};
    
    % and the time
    ptt = transitTimes(1+2*jj-nextDir,1+2*(jj-1)-currDir);
    
    % append to the flight so far
    pp = [pp pxpy nextFlt];
    
    % add both the turn and the flight to the time
    pt = [pt currTime+ptt];
    currTime = currTime + max(ptt);
    turnTime = turnTime + max(ptt);
    % and the flight segment
    thisScanTime = stripTimes(jj,nextDir);
    scanTime = scanTime + thisScanTime;
    currTime = currTime + thisScanTime;
    pt = [pt currTime];
    
    % and update for next iter
    %currFlt = nextFlt;
    currDir = nextDir;
    %currHdg = nextHdg;
    
end

end

function fltsOut = sortFlights(fltsIn,dirVec)
%
% sort flights in ascending order of projection
% of midpoints on 'dirVec'
%

% calculate for each
for ii=1:numel(fltsIn),
    vals(ii) = [dirVec(1) dirVec(2)]*fltsIn{ii}*[0.5;0.5];
end

% do the sort
[svals,sidx]=sort(vals);

% and return the sorted flight list
fltsOut = fltsIn(sidx);

end