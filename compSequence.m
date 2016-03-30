close all
clear all

% flight parameters
Rmin = 0.75;
vAir = 1;
vWind = [0.6,-0.1];

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
     
% choose test case
P = Podd;
     
% find centroid
pCent = mean(P,2);

% strip width
wid = 1;

% strip offset
ofs = -0.0;

% strip angle range to try
Nangs = 120;
angs = (1:Nangs)*2*pi/Nangs;

for kk=1:numel(angs),
    
    ang = angs(kk);
    
    % divide into strips
    [strips,flights] = stripPoly(P,ang,wid,ofs);
    
    
    % plot what we got back
    numStrips = numel(strips);
    for pp=1:numStrips,
        thisP = strips{pp};
        if numel(thisP)>0,
            %col = [pp 0 numStrips-pp]/numStrips;
            patch(strips{pp}(1,:),strips{pp}(2,:),'g')
            %plot(flights{pp}(1,:),flights{pp}(2,:),'ko--')
        end
    end
    hold on    
    % plot the original field
    plot([P(1,:) P(1,1)],[P(2,:) P(2,1)],'k:','LineWidth',2)
    axis equal
    
    % sort flights in basic direction
    flights = sortFlights(flights,[sin(ang);-cos(ang)]);
    
    % compile the total path in sorted order
    [pp,pt,scanTime,turnTime] = simpleOrderedSequence(flights,vAir,Rmin,vWind);
    
    % plot
    plot(pp(1,:),pp(2,:),'b-', ...
        pp(1,1),pp(2,1),'b^')
    % plot the wind vector
    plot(pCent(1)+[0 vWind(1)],pCent(2)+[0,vWind(2)],'r-','LineWidth',2)
    plot(pCent(1),pCent(2),'ro','LineWidth',2)
    
    title(sprintf('%.0f^o : %.1f scanning and %.1f turning',ang*180/pi,scanTime,turnTime))
    
    scanTimeList(kk) = scanTime;
    turnTimeList(kk) = turnTime;
    
    % print the figure
    fname=sprintf('results/odd_windacross_n%d',kk);
    save([fname '.mat']);
    print('-dpng',[fname '.png']);
    % clear it
    clf
    % or open a new one
    %figure
    
end
%%
figure
%plot(angs*180/pi,scanTimeList,angs*180/pi,turnTimeList+scanTimeList)
area(angs*180/pi,[scanTimeList; turnTimeList]')
legend('Scanning','Turning','Location','SouthEast')
xlabel('Angle (^o)')
ylabel('Time')