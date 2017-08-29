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
Pell = 0.999*50*[0 6 6 0 0 3 3 0 ;
    0  0 6 6 4 4 2 2];

% choose test case
P = Pell;

% rotation angle
rotAngle = 0.1*pi;

% rotate the field
P = [cos(rotAngle) sin(rotAngle);
    -sin(rotAngle) cos(rotAngle)]*P;

%% data saving options
plotFlag = true;
saveFlag = false;
fStub = 'results/tsp_ell3';

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
    saveFlag = false;
    if saveFlag,
        fname=sprintf('%s_%03d',fStub,kk);
        % save all data
        save([fname '.mat'], 'pp', 'scanTime', 'turnTime', 'totalTime', 'P','cutAngle','stripWidth','cutOffset','Rmin','vWind','vAir');
    end
    
    plotFlag = true;
    if plotFlag,
        clf
        plotFlight(pp,strips,P,vWind)
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