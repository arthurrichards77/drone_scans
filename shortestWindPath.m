function [px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vFly,vWind)
%
%

% iterate over the time taken for the manoeuvre
t = 0;
dt = 0.05;

% just fixed loop for now
for ii=1:1000,
    % time for intercept
    t = t+dt;
    
    % find the wind-shifted target
    cTermShifted = cTerm - [vWind(1);vWind(2);0]*t;
    
    % find closest-timed Dubins path
    [pxa,pya,pt,clInc]=shortestDubinsPath(cInit,cTermShifted,Rmin,vFly*t);
    
    % store stuff
    ts(ii)=t;
    Gs(ii)=max(pt)-vFly*t;
    
    % stop at first intercept
    if Gs(ii)<0,
        break
    end

end

% limits for next stage
thi = ts(ii);
tlo = ts(ii-1);

% now bisection search
for jj=1:20,

    % time for intercept
    t = 0.5*(thi+tlo);
    
    % find the wind-shifted target
    cTermShifted = cTerm - [vWind(1);vWind(2);0]*t;
    
    % find closest-timed Dubins path
    [pxa,pya,pt,clInc]=shortestDubinsPath(cInit,cTermShifted,Rmin,vFly*t);
    
    % store stuff
    ts(jj+ii)=t;
    Gs(jj+ii)=max(pt)-vFly*t;
    
    % update bounds
    if Gs(jj+ii)<0,
        % new upper
        thi = t;
    else
        % new lower
        tlo = t;
    end
end

% shift back by the wind
px = pxa + vWind(1)*pt/vFly;
py = pya + vWind(2)*pt/vFly;

figure(2)
plot(ts,Gs,'.b-')
figure(1)
