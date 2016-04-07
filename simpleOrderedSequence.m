function [p,pt,scanTime,turnTime] = simpleOrderedSequence(flights,vAir,Rmin,vWind)
%
% pp is matrix of waypoints [.....[xi;yi]......]
% pt is vector of times

% start arbitrarily at flight number one, first end
p = flights{1};
currFlt = flights{1};
currDir = 2; % column 1 to column 2
currTrk = atan2((flights{1}(2,currDir)-flights{1}(2,3-currDir)), ...
    (flights{1}(1,currDir)-flights{1}(1,3-currDir)));
[currHdg,Vg] = hdgSpdForTrkInWind(vAir,currTrk,vWind);
currTime = norm(currFlt(:,2)-currFlt(:,1))/Vg;
pt = [0 currTime];
turnTime = 0;
scanTime = currTime;

for ii=2:numel(flights),
    
    % stupid simple for now - just work through 1:n
    jj = ii;
    
    % opposite direction    
    nextDir = 3-currDir;
    
    % the start and end points, in that order
    nextFlt = flights{jj}(:,[3-nextDir nextDir]);
    
    % track of next flight strip
    nextTrk = atan2((nextFlt(2,2)-nextFlt(2,1)), ...
        (nextFlt(1,2)-nextFlt(1,1)));
    
    % heading to fly it
    [nextHdg,nextVg] = hdgSpdForTrkInWind(vAir,nextTrk,vWind);
    
    % now find the transition
    cInit = [currFlt(:,2);currHdg];
    cTerm = [nextFlt(:,1);nextHdg];
    [px,py,ptt,pxa,pya,clInc]=shortestWindPathDB(cInit,cTerm,Rmin,vAir,vWind);
    
    % append to the flight so far
    p = [p [px;py] nextFlt];
    
    % add both the turn and the flight to the time
    pt = [pt currTime+ptt];
    currTime = currTime + max(ptt);
    turnTime = turnTime + max(ptt);
    % and the flight segment
    thisScanTime = norm(nextFlt(:,2)-nextFlt(:,1))/nextVg;
    scanTime = scanTime + thisScanTime;
    currTime = currTime + thisScanTime;
    pt = [pt currTime];
    
    % and update for next iter
    currFlt = nextFlt;
    currDir = nextDir;
    currHdg = nextHdg;
    
end