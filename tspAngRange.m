close all
clear all
Tstart = tic;

% flight parameters
Rmin = 0.75;
vAir = 1;
vWind = [-0.4,0.4];

%% field

% simple square
Psq = [0 10 10  0;
    0  0 10 10]*0.999;

% rectangle
Prect = [0 5  5  0;
    0 0 20 20]*0.999;

% rectangle, this time without whole numbered sides
Prect2 = [0 4.5  4.5  0;
    0   0 22.2 22.2];

% rectangle, this time without whole numbered sides
% and now with even number of strips
Prect3 = [0 5.5  5.5  0;
    0   0 18.2 18.2];

% odd shape, no sides parallel
Podd = [0 3  3   -1 -3.6
    0 1 11.3 10  3.6];

% rectangle 3, but with a notch
Pnotch = 0.5*[0 5.5  5.5  0    0     0.8  0;
    0   0 18.2 18.2 11.2  10.1  9.5];

% circular, almost
ths = pi*(1:10)/5;
Pcirc = 10*[cos(ths);sin(ths)];

% L-shaped
Pell = [0  10.3 10.4  1.8  1.8  0;
    0   0    2.3  2.3 10.2 10.2];

% choose test case
P = Pell;

%% flight params

% strip width
wid = 1.01;

% strip offset
ofs = 0.0; % always zero for TSP sequencing

% strip angle range to try
Nangs = 180;
angs = (1:Nangs)*2*pi/Nangs;

%% loop
hWait = waitbar(0,'Progress');
figure(1)
for kk=1:numel(angs),
    waitbar(kk/numel(angs),hWait);
    
    % extract the current angle
    ang = angs(kk);
    
    % divide into strips
    [strips,stripFlights] = stripPoly(P,ang,wid,ofs);
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
    
    % init cost matrix for TSP
    cost=zeros(2*numStrips,2*numStrips+1);
    
    transitFlights = {};
    
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
                    [px,py,ptt,pxa,pya,clInc]=shortestWindPath_mex(cInit,cTerm,Rmin,vAir,vWind);
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
                    [px,py,ptt,pxa,pya,clInc]=shortestWindPath_mex(cInit,cTerm,Rmin,vAir,vWind);
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
    fid = fopen('tsp.dat','w');
    AMPLscalarint(fid,'N',numStrips);
    AMPLmatrix(fid,'J',cost);
    fclose(fid);
    
    % run AMPL - either UoB or BRL version
    % latter uses local temp install of AMPL
    !ampl tsp.run
    %!runampl tsp_cplex.run
    
    % load results
    res = load('res.dat');
    
    % reshape to matrix
    X = reshape(res,2*numStrips+1,2*numStrips+1)';
    
    % convert back to sequence
    % start with first job
    currJob = find(X(2*numStrips+1,:));
    
    % initial path
    pp = [];
    scanTime = 0;
    turnTime = 0;
    
    for jj=1:(2*numStrips),
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
    
    scanTimeList(kk) = scanTime;
    turnTimeList(kk) = turnTime;
    
    % optional save of data and plot
    saveFlag = true;
    if saveFlag,
        fname=sprintf('results/tsp_ell3_%03d',kk);
        % save all data
        save([fname '.mat'], 'pp', 'scanTime', 'turnTime', 'X', 'cost', 'transitFlights', 'transitTimes', 'stripFlights', 'stripTimes', ...
            'P','ang','wid','ofs','stripHdgs','stripVgs','Rmin','vWind','vAir');
    end    
    
    plotFlag = true;
    if plotFlag,
        clf
        % plot
        %figure(2)
        %clf
        % plot the original field
        patch(P(1,:),P(2,:),'g')
        axis equal
        hold on
        for kk=1:numStrips,
            thisP = strips{kk};
            if numel(thisP)>0,
                col = 'c'; %[pp 0 numStrips-pp]/numStrips;
                patch(strips{kk}(1,:),strips{kk}(2,:),col,'FaceAlpha',0.5)
            end
        end
        
        plot(pp(1,:),pp(2,:),'k-', ...
            1.2*max(P(1,:)), 1.2*max(P(2,:)),'ro', 1.2*max(P(1,:)) + [0 vWind(1)], 1.2*max(P(2,:)) + [0 vWind(2)],'r-', ...
            pp(1,1),pp(2,1),'k^','LineWidth',1.5)
        title(sprintf('%.0f^o : %.1f scanning and %.1f turning : %.1f total',ang*180/pi,scanTime,turnTime,scanTime+turnTime))
        
        pause(0.001)
        
        if saveFlag,
            % print the figure
            print('-dpng',[fname '.png']);
        end
        
    end
    
    
    
end
close(hWait)

%% find the best
[bestTime,bestIndx] = min(scanTimeList+turnTimeList);

figure
%plot(angs*180/pi,scanTimeList,angs*180/pi,turnTimeList+scanTimeList)
area(angs*180/pi,[scanTimeList; turnTimeList]')
legend('Scanning','Turning','Location','SouthEast')
xlabel('Angle (^o)')
ylabel('Time')
hold on
plot(angs(bestIndx)*180/pi,bestTime,'m*')
toc(Tstart)