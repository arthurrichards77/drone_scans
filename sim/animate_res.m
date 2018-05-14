close all
clear all

% needs data loaded from example case
fname='ell2rlw_225';

% load the path result
load(['../results/' fname '.mat'])
% and load the simulation result
load(['res/' fname '.mat'])

figure

% plot the original field
patch(P(1,:),P(2,:),'g')
axis equal
hold on

% label the wind
scWind = 10;
plot(1.2*max(P(1,:)), 1.2*max(P(2,:)),'ro', ...
     1.2*max(P(1,:)) + scWind*[0 vWind(1)], 1.2*max(P(2,:)) + scWind*[0 vWind(2)],'r-', 'LineWidth',1.5)

plot(p_out(1,:),p_out(2,:),'r--',...
    p_out(1,1),p_out(2,1),'ro',...
    p_out(1,end),p_out(2,end),'rx',...
    'Linewidth',2)
% add a buffer at the edges
a = axis();
axis(a+20*[-1 1 -1 1])

% marker shape
%mkrShape = 5*[-1,2,-1; 1,0,-1]; 
mkrShape = 8*[-1 0 1 0 -1 0;2 2 0 -2 -2 0];
pp = simout(:,1:2)';

% for artificial horizon
szAHoriz = 50;
posAHoriz = [300,70];
patch(posAHoriz(1)+szAHoriz*[-1 -1 1 1], ...
    posAHoriz(2)+szAHoriz*[-1 1 1 -1] , 'c');

% save video
vidObj = VideoWriter('flight','MPEG-4');
vidObj.Quality = 90;
open(vidObj)

for tt=1:(numel(tout)-1),
    h = plot(simout(1:tt,1),simout(1:tt,2),'b-',...
        'Linewidth',2);
    
    % display the UAV icon
    kk = tt;
    dx = pp(1,kk+1)-pp(1,kk);
    dy = pp(2,kk+1)-pp(2,kk);
    px = 0.5*(pp(1,kk+1)+pp(1,kk));
    py = 0.5*(pp(2,kk+1)+pp(2,kk));
    trk = atan2(dy,dx);
    hdg = hdgSpdForTrkInWind(vAir,trk,vWind);
    rotMat = [cos(hdg) -sin(hdg); sin(hdg) cos(hdg)];
    mkrRot = rotMat*mkrShape;
    hp = patch(px+mkrRot(1,:),py+mkrRot(2,:),'r');
    
    % artificial horizon
    ha = patch(posAHoriz(1)+szAHoriz*[-1 -1 1 1], ...
               posAHoriz(2)+szAHoriz*[-1 sin(simout(kk,6)*pi/180)*[1 -1] -1] , 'g');
    
    % update
    refresh
    pause(0.001)
    currFrame = getframe;
    writeVideo(vidObj,currFrame);
    
    % clear dynamic bits
    h.delete;
    hp.delete;
    ha.delete;
end

close(vidObj)