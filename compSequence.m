close all
clear all
Tstart = tic;

% flight parameters
Rmin = 0.75;
vAir = 1;
vWind = -[-0.3,-0.5];

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
Pnotch = [0 5.5  5.5  0    0     0.8  0;
          0   0 18.2 18.2 11.2  10.1  9.5];

% circular, almost
ths = pi*(1:10)/5;
Pcirc = 10*[cos(ths);sin(ths)];

% L-shaped
Pell = [0  10.3 10.4  1.8  1.8  0;
        0   0    2.3  2.3 10.2 10.2];

% choose test case
P = Pnotch;

% find centroid
pCent = mean(P,2);

% strip width
wid = 1;

% strip offset
ofs = -0.0;

% strip angle range to try
Nangs = 60;
angs = (1:Nangs)*2*pi/Nangs;

hWait = waitbar(0,'Progress');
figure(1)
for kk=1:numel(angs),
    waitbar(kk/numel(angs),hWait);
    
    % extract the current angle
    ang = angs(kk);
    
    % divide into strips
    [strips,flights] = stripPoly(P,ang,wid,ofs);
    
    % sort flights in basic direction
    flights = sortFlights(flights,[sin(ang);-cos(ang)]);
    
    % compile the total path in sorted order
    [pp,pt,scanTime,turnTime] = simpleOrderedSequence(flights,vAir,Rmin,vWind);
    
    scanTimeList(kk) = scanTime;
    turnTimeList(kk) = turnTime;
    
    % optional save of data and plot
    saveFlag = false;
    if saveFlag,
            fname=sprintf('results/ell_windoblq3_n%d',kk);
            % save all data
            save([fname '.mat']);
    end
    
    plotFlag=true;
    if plotFlag,
        % clear it
        pause(0.001)
        clf
        % plot the strips
        numStrips = numel(strips);
        for ii=1:numStrips,
            thisP = strips{ii};
            if numel(thisP)>0,
                %col = [pp 0 numStrips-pp]/numStrips;
                patch(strips{ii}(1,:),strips{ii}(2,:),'g')
                %plot(flights{pp}(1,:),flights{pp}(2,:),'ko--')
            end
        end
        hold on
        % plot the original field
        plot([P(1,:) P(1,1)],[P(2,:) P(2,1)],'k--','LineWidth',2)
        axis equal
        % plot the path
        plot(pp(1,:),pp(2,:),'b-', ...
            pp(1,1),pp(2,1),'b^')
        % plot the wind vector
        plot(pCent(1)+[0 vWind(1)],pCent(2)+[0,vWind(2)],'r-','LineWidth',2)
        plot(pCent(1),pCent(2),'ro','LineWidth',2)
        % info in the title
        title(sprintf('%.0f^o : %.1f (scans %.1f turns %.1f)',ang*180/pi,scanTime+turnTime,scanTime,turnTime))
        % optional save of data and
        if saveFlag,
            % print the figure
            print('-dpng',[fname '.png']);
        end
    end
    
end
close(hWait)

%%
figure
%plot(angs*180/pi,scanTimeList,angs*180/pi,turnTimeList+scanTimeList)
area(angs*180/pi,[scanTimeList; turnTimeList]')
legend('Scanning','Turning','Location','SouthEast')
xlabel('Angle (^o)')
ylabel('Time')

toc(Tstart)