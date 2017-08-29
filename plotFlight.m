function plotFlight(pp,strips,P,vWind)

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
    1.2*max(P(1,:)), 1.2*max(P(2,:)),'ro', 1.2*max(P(1,:)) + [0 vWind(1)], 1.2*max(P(2,:)) + [0 vWind(2)],'r-', ...
    pp(1,1),pp(2,1),'k^','LineWidth',1.5)
