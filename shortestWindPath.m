function [px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vFly,vWind)
%
%

% initialise search
dStar = inf;
clStar = [];

% start by searching over default path classes
[d0,G0] = fzero(@(d)targetTimeDiff(d,cInit,cTerm,Rmin,vWind,vFly,[]),0.0);

% check if we're OK or at a discontinuity
if abs(G0)<1e-6,
    
    % found it OK
    dStar = d0;
    
    % time for the wind to shift by d units
    tShift = dStar/norm(vWind);
    
    % find the wind-shifted target, moved by d units
    cTermShifted = cTerm - [vWind(1);vWind(2);0]*tShift;
    
    % find closest-timed Dubins path of selected class
    [pxa,pya,pt,clInc]=shortestDubinsPath(cInit,cTermShifted,Rmin,clStar);
    
    % shift back by the wind
    px = pxa + vWind(1)*pt/vFly;
    py = pya + vWind(2)*pt/vFly;
    
    % find closest-timed Dubins path of selected class
    [pxa,pya,pt,clStar]=shortestDubinsPath(cInit,cTermShifted,Rmin,[]);
    
else
    
    % search through all classes
    for cc=1:8,
        
        % mask for just this path
        clMask = ((1:8)==cc);
        
        % find the intercept time
        % pretty sensitive to initial guess
        [dCl,G] = fzero(@(d)targetTimeDiff(d,cInit,cTerm,Rmin,vWind,vFly,clMask),0);
        
        if abs(G)<1e-6,
            if dCl<dStar,
                dStar = dCl;
                clStar = clMask;
            end
        end
        
        % debug
        %     figure(2)
        %     subplot(3,3,cc)
        %     for ii=1:100,
        %         ds(ii)=ii/10;
        %         Gs(ii)=targetTimeDiff(ds(ii),cInit,cTerm,Rmin,vWind,vFly,clMask);
        %         plot(ds,Gs)
        %         grid on
        %     end
    end
    %figure(1)
    
    % time for the wind to shift by d units
    tShift = dStar/norm(vWind);
    
    % find the wind-shifted target, moved by d units
    cTermShifted = cTerm - [vWind(1);vWind(2);0]*tShift;
    
    % find closest-timed Dubins path of selected class
    [pxa,pya,pt,clInc]=shortestDubinsPath(cInit,cTermShifted,Rmin,clStar);
    
    % shift back by the wind
    px = pxa + vWind(1)*pt/vFly;
    py = pya + vWind(2)*pt/vFly;
    
end

end

function G = targetTimeDiff(d,cInit,cTerm,Rmin,vWind,vFly,clMask)

% time for the wind to shift by d units
tShift = d/norm(vWind);

% find the wind-shifted target, moved by d units
cTermShifted = cTerm - [vWind(1);vWind(2);0]*tShift;

% find closest-timed Dubins path of selected class
[pxa,pya,pt,clInc]=shortestDubinsPath(cInit,cTermShifted,Rmin,clMask);

% flight time for real aircraft
tFly = max(pt)/vFly;

% response is the difference
G = tFly - tShift;

% trap case if empty
if isempty(G),
    G = 1000;
end

end