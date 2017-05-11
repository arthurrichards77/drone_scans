function [pp,pt,scanTime,turnTime] = simpleOrderedSequence(stripFlights,stripTimes,transitFlights,transitTimes)
%
% pp is matrix of waypoints [.....[xi;yi]......]
% pt is vector of times

% start arbitrarily at flight number one, first end
pp = stripFlights{1};
currFlt = stripFlights{1};
currDir = 1; % column 1 to column 2
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