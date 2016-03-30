function [px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vFly,vWind)
%
%

% debug flag - plot G(d) functions
dbgPlot = false;

% bisection tolerance
tolBisect = 1e-5;

% start by searching over default path classes
% lower bound
dLB = 0;
[gLB,pxLB,pyLB,ptLB,clLB] = targetTimeDiff(dLB,cInit,cTerm,Rmin,vWind,vFly,[]);
% gone wrong if g not zero at zero
assert(gLB>=0)

if dbgPlot,
    dgs = [dLB gLB];
end

% upper bound
dUB = 1;
[gUB,pxUB,pyUB,ptUB,clUB] = targetTimeDiff(dUB,cInit,cTerm,Rmin,vWind,vFly,[]);

if dbgPlot,
    dgs = [dgs; dUB gUB];
end

% stage 1 - expand until enclosing a zero crossing
while gUB>0,
    dLB = dUB;
    dUB = 2*dUB;
    [gUB,pxUB,pyUB,ptUB,clUB] = targetTimeDiff(dUB,cInit,cTerm,Rmin,vWind,vFly,[]);
    if dbgPlot,
        dgs = [dgs; dUB gUB];
        dmax = dUB;
    end
end

% stage 2 - bisection search
while dUB>dLB+tolBisect,
    dT = 0.5*(dUB+dLB);
    [gT,pxa,pya,pt,clInc] = targetTimeDiff(dT,cInit,cTerm,Rmin,vWind,vFly,[]);
    if gT<0,
        dUB = dT;
        gUB = gT;
        clUB = clInc;
    else
        dLB = dT;
        gLB = gT;
        clLB = clInc;
    end
    if dbgPlot,
        dgs = [dgs; dT gT];
    end
end

% check for discontinuity - am I riding same line both sides?
if ~strcmp(clLB,clUB),
    %disp('Discontinuity')
    % time to work right from the upper bound
    dT = dUB;
    % cautious steps here
    dStep = dUB/20;
    % initialize for each case
    for cc=1:8,
        [thisG,~,~,~,~] = targetTimeDiff(dT,cInit,cTerm,Rmin,vWind,vFly,((1:8)==cc));
        if isempty(thisG),
            gLast(cc)=NaN;
        else
            gLast(cc)=thisG;
        end
    end
    % winning class placeholder
    ccWins = 0;
    % linear search this time
    while ccWins==0,
        dT = dT + dStep;
        % initialize for each case
        for cc=1:8,
            clMask = ((1:8)==cc);
            [thisG,pxa,pya,pt,clInc] = targetTimeDiff(dT,cInit,cTerm,Rmin,vWind,vFly,clMask);
            if ~isempty(thisG),
                if thisG*gLast(cc)<=0,
                    % sign change - winner!
                    ccWins = cc;
                    break
                else
                    % store for next time
                    gLast(cc)=thisG;
                end
            end
            if dbgPlot,
                dgs = [dgs; dT thisG];
            end
        end
    end
    % found first sign change - now final bisection search
    dUB = dT;
    dLB = dT-dStep;
    % need to check if rising or falling
    gUBsign = sign(thisG);
    while dUB>dLB+tolBisect,
        dT = 0.5*(dUB+dLB);
        [gT,pxa,pya,pt,clInc] = targetTimeDiff(dT,cInit,cTerm,Rmin,vWind,vFly,clMask);
        if gT*gUBsign>0,
            dUB = dT;
        else
            dLB = dT;
        end
        if dbgPlot,
            dgs = [dgs; dT gT];
        end
    end
    
end

% shift back by the wind
px = pxa + vWind(1)*pt/vFly;
py = pya + vWind(2)*pt/vFly;

% optional plotting of G functions for debug
if dbgPlot,
    f=gcf;
    figure
    plot(dgs(:,1),dgs(:,2),'x')
    hold on
    dsRng = linspace(0,2*dmax,100);
    for cc=1:8,
        clTest = ((1:8)==cc);
        for ii=1:numel(dsRng),
            [thisG,~,~,~,~] = targetTimeDiff(dsRng(ii),cInit,cTerm,Rmin,vWind,vFly,clTest);
            if ~isempty(thisG),
                gsRng(ii,cc) = thisG;
            else
                gsRng(ii,cc) = NaN;
            end
        end
    end
    plot(dsRng,gsRng,'-')
    legend('s','LSL','RSR','RSL','LSR','RLRo','LRLo','RLRi','LRLi')
    plot([0 2*dmax],[0 0],'k:')
    figure(f)
end

return

G0 = gT;
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

function [G,pxa,pya,pt,cl] = targetTimeDiff(d,cInit,cTerm,Rmin,vWind,vFly,clMask)

% time for the wind to shift by d units
tShift = d/norm(vWind);

% find the wind-shifted target, moved by d units
cTermShifted = cTerm - [vWind(1);vWind(2);0]*tShift;

% find closest-timed Dubins path of selected class
[pxa,pya,pt,cl]=shortestDubinsPath(cInit,cTermShifted,Rmin,clMask);

% flight time for real aircraft
tFly = max(pt)/vFly;

% response is the difference
G = tFly - tShift;

end