close all
clear all
Tstart = tic;

%% flight parameters
Rmin = 35;
vAir = 10;
vWind = [0.0,-7.0];

% strip width
stripWidth = 30;

% strip offset
cutOffset = -0.0;

% strip angle range to try
Nangs = 180;
angs = (1:Nangs)*2*pi/Nangs;

%% field

% simple square
Psq = [0 200 200  0;
    0  0 200 200]*0.999;

% rotation angle
rotAngle = 0.1*pi;

% rotate the field
P = [cos(rotAngle) sin(rotAngle);
    -sin(rotAngle) cos(rotAngle)]*Psq;

%% data saving options
plotFlag = true;
saveFlag = true;
fStub = 'results/sq';

%% loop
hWait = waitbar(0,'Progress');
figure(1)
for kk=1:numel(angs),
    waitbar(kk/numel(angs),hWait);
    
    % strip angle
    cutAngle = angs(kk);
    
    [scanTime,turnTime,totalTime,pp,strips] = tspSequence(P,cutAngle,stripWidth,cutOffset,Rmin,vAir,vWind);
    scanTimeList(kk) = scanTime;
    turnTimeList(kk) = turnTime;
    
    % optional save of data and plot
    if saveFlag,
        fname=sprintf('%s_%03d',fStub,kk);
        % save all data
        save([fname '.mat'], 'pp', 'scanTime', 'turnTime', 'totalTime', 'P','cutAngle','stripWidth','cutOffset','Rmin','vWind','vAir');
    end
    
    if plotFlag,
        clf
        plotFlight(pp,strips,P,vWind,vAir)
        % results summary in title
        title(sprintf('%.0f^o TSP : %.1f scanning and %.1f turning : %.1f total',cutAngle*180/pi,scanTime,turnTime,totalTime))
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