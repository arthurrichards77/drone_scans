function plotFlight(pp,strips,P,vWind,vAir)

% plot the original field
patch(P(1,:),P(2,:),'g')
axis equal
hold on
% plot the strips
for kk=1:numel(strips),
    if numel(strips{kk})>0,        
        patch(strips{kk}(1,:),strips{kk}(2,:),'c','FaceAlpha',0.5)        
    end
end
% and the flight
plot(pp(1,:),pp(2,:),'k-', ...
    pp(1,1),pp(2,1),'k^','LineWidth',1.5)
% label the wind
scWind = 10;
plot(1.2*max(P(1,:)), 1.2*max(P(2,:)),'ro', ...
     1.2*max(P(1,:)) + scWind*[0 vWind(1)], 1.2*max(P(2,:)) + scWind*[0 vWind(2)],'r-', 'LineWidth',1.5)

% marker shape
%mkrShape = 5*[-1,2,-1; 1,0,-1]; 
mkrShape = 5*[-1 0 1 0 -1 0;2 2 0 -2 -2 0]; 
% markers showing headings
mkrMin = 50;
mkrIndx=find(sum(abs(diff(pp')),2)>mkrMin);
%plot(0.5*pp(1,mkrIndx)+0.5*pp(1,mkrIndx+1),0.5*pp(2,mkrIndx)+0.5*pp(2,mkrIndx+1),'bs')
for kk=mkrIndx',
    dx = pp(1,kk+1)-pp(1,kk);
    dy = pp(2,kk+1)-pp(2,kk);
    px = 0.5*(pp(1,kk+1)+pp(1,kk));
    py = 0.5*(pp(2,kk+1)+pp(2,kk));
    trk = atan2(dy,dx);
    hdg = hdgSpdForTrkInWind(vAir,trk,vWind);
    rotMat = [cos(hdg) -sin(hdg); sin(hdg) cos(hdg)];
    mkrRot = rotMat*mkrShape;
    patch(px+mkrRot(1,:),py+mkrRot(2,:),'r')
end
    