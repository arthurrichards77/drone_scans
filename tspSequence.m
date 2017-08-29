function [scanTime,turnTime,totalTime,pp,strips] = tspSequence(P,cutAngle,stripWidth,cutOffset,Rmin,vAir,vWind)

% divide into strips
[strips,stripFlights] = stripPoly(P,cutAngle,stripWidth,cutOffset);
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

% save for AMPL
fid = fopen('tsp/tsp.dat','w');
AMPLscalarint(fid,'N',numStrips);
AMPLmatrix(fid,'J',cost);
fclose(fid);

% run AMPL - either UoB or BRL version
% latter uses local temp install of AMPL
%!ampl tsp.run
%!runampl tsp_cplex.run
% load results
%res = load('res.dat');

% glpk on linux
%!glpsol -m tsp.mod -d tsp.dat -o tsp.txt
% just grab the X results
%!grep -o 'X\[.*\]\W*\*\W*[01]' tsp.txt | grep -o '[01]$' > res.dat

% glpk via cygwin
!tspsolve

res = load('tsp/res.dat');
assert(numel(res)==(2*numStrips+1)^2)

% reshape to matrix
X = reshape(res,2*numStrips+1,2*numStrips+1)';

% convert back to sequence
% start with first job
currJob = find(X(2*numStrips+1,:));

% initial path
pp = [];
scanTime = 0;
turnTime = 0;

for kk=1:(2*numStrips),
    % complete current strip
    currStrip = ceil(currJob/2);
    currDir = 1+mod(currJob,2);
    % and strip path
    pp = [pp stripFlights{currStrip}(:,[3-currDir currDir])];
    scanTime = scanTime + stripTimes(currStrip,currDir);
    % next job
    nextJob = find(X(currJob,:));
    if nextJob == 2*numStrips+1,
        break
    end
    nextStrip = ceil(nextJob/2);
    nextDir = 1+mod(nextJob,2);
    % transit path
    pp = [pp transitFlights{currStrip,currDir,nextStrip,nextDir}];
    turnTime = turnTime + transitTimes(1+2*currStrip-currDir,1+2*nextStrip-nextDir);
    % update
    currJob = nextJob;
end

totalTime = scanTime+turnTime;

testCost = sum(sum(X(1:(2*numStrips),:).*cost))

save sim/testpath totalTime pp vWind vAir Rmin