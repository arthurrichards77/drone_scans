function [bestTime,bestIndx,scanTimeList,turnTimeList]=tspSweepAngs(P,Rmin,vAir,vWind,stripWidth,plotFlag,saveFlag,fStub)

% strip offset
cutOffset = -0.0;

% strip angle range to try
Nangs = 180;
angs = (1:Nangs)*2*pi/Nangs;

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

if plotFlag,
    figure
    %plot(angs*180/pi,scanTimeList,angs*180/pi,turnTimeList+scanTimeList)
    area(angs*180/pi,[scanTimeList; turnTimeList]')
    legend('Scanning','Turning','Location','SouthEast')
    xlabel('Angle (^o)')
    ylabel('Time')
    hold on
    plot(angs(bestIndx)*180/pi,bestTime,'m*')
    title(sprintf('Best angle is %.0f^o taking %.1f',angs(bestIndx)*180/pi,bestTime))
    %% save
    if saveFlag,
        fname=sprintf('%s_summary',fStub);
        % print the figure
        print('-dpng',[fname '.png']);
    end
end