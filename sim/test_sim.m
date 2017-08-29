close all
clear all

% load data and resample path for controller
load testpath
[p_out, samp_dist, cum_dist]=resamplepath(pp,5e-3);
%plot(pp(1,:),pp(2,:),'-g.',p_out(1,:),p_out(2,:),'r.')
%axis equal

% set initial conditions
x0 = pp(1,1);
y0 = pp(2,1);
% get heading carefully
trk0 = atan2(pp(2,2)-pp(2,1),pp(1,2)-pp(1,1));
[h0,~] = hdgSpdForTrkInWind(vAir,trk0,vWind);
% starting aim point for filtering
aim_point0 = [pp(1,10);pp(2,10)];

res = sim('uav','StopTime',sprintf('%.4f',1.5*totalTime));
simout = get(res,'simout');
% extract stopping time
tout = get(res,'tout');
simTime = max(tout)
%sim('uav')

figure
plot(p_out(1,:),p_out(2,:),'r--',...
    simout(:,1),simout(:,2),'b-',...
    p_out(1,1),p_out(2,1),'ro',...
    p_out(1,end),p_out(2,end),'rx',...
    'Linewidth',2)
axis equal
title(sprintf('Arrived in %.2f.  Prediction was %.2f',simTime,totalTime))
legend('Planned','Flown')