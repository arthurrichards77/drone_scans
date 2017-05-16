function [px,py,pt,pxa,pya,clInc]=shortestWindPath(cInit,cTerm,Rmin,vFly,vWind)
%
%

% debug flag - plot G(d) functions
dbgPlot = false;

% bisection tolerance
tolBisect = 1e-3;

% default path class mask
clMaskDef = [true(6,1); false(2,1)];

% start by searching over default path classes
% lower bound
dLB = 0;
[gLB,pxa,pya,pt,clLB] = targetTimeDiff(dLB,cInit,cTerm,Rmin,vWind,vFly,clMaskDef);
% gone wrong if g not zero at zero
% assert(gLB>=0)

% set default class here just to keep codegen happy
clInc = clLB;

if dbgPlot,
    dgs = [dLB gLB];
end

% upper bound
dUB = 1;
[gUB,pxUB,pyUB,ptUB,clUB] = targetTimeDiff(dUB,cInit,cTerm,Rmin,vWind,vFly,clMaskDef);

if dbgPlot,
    dgs = [dgs; dUB gUB];
end

% stage 1 - expand until enclosing a zero crossing
while gUB(1)>0,
    dLB = dUB;
    dUB = 2*dUB;
    [gUB,pxUB,pyUB,ptUB,clUB] = targetTimeDiff(dUB,cInit,cTerm,Rmin,vWind,vFly,clMaskDef);
    if dbgPlot,
        dgs = [dgs; dUB gUB];
        dmax = dUB;
    end
end

% stage 2 - bisection search
while dUB>dLB+tolBisect,
    dT = 0.5*(dUB+dLB);
    [gT,pxa,pya,pt,clInc] = targetTimeDiff(dT,cInit,cTerm,Rmin,vWind,vFly,clMaskDef);
    if gT(1)<0,
        dUB = dT;
        gUB = gT;
        clUB = clInc;
    else
        dLB = dT;
        gLB = gT;
        clLB = clInc;
    end
    if dbgPlot,
        dgs2=[0 NaN];
        dgs = [dgs; dT gT];
    end
end

% check for discontinuity - am I riding same line both sides?
if ~strcmp(clLB,clUB),
    if dbgPlot,
        disp('Discontinuity')
        clLB
        clUB
        gLB
        gUB
    end
    % time to work right from the upper bound
    dT = dUB*19/20;
    % cautious steps here
    dStep = dUB/20;
    % initialize for each case
    gLast = ones(8,1);
    for cc=1:8,
        [thisG,~,~,~,~] = targetTimeDiff(dT,cInit,cTerm,Rmin,vWind,vFly,((1:8)==cc));
        if isempty(thisG),
            gLast(cc)=NaN;
        else
            gLast(cc)=thisG;
            if dbgPlot,
                dgs2 = [dgs2; dT thisG];
            end
        end
    end
    if dbgPlot,
        disp('Starting second search')        
        gLast
    end
    % winning class placeholder
    ccWins = 0;
    % linear search this time
    for kk=1:1000,
        dT = dT + dStep;
        % initialize for each case
        for cc=1:8,
            clMask = ((1:8)==cc);
            [thisG,pxa,pya,pt,clInc] = targetTimeDiff(dT,cInit,cTerm,Rmin,vWind,vFly,clMask);
            if ~isempty(thisG),
                if dbgPlot,
                    dgs2 = [dgs2; dT thisG];
                end
                if thisG(1)*gLast(cc)<=0,
                    % sign change - possible winner!
%                     if dbgPlot,
%                         disp('Possible winner')
%                         cc
%                     end
                    % also check for step here too
                    if abs(thisG(1)-gLast(cc))<1.5*Rmin, % needs better tolerance
                        ccWins = cc;
                        if dbgPlot,
                            figure(9)
                            plot(pxa,pya)
                            title(clInc)
                        end
                        break
                    end
                else
                    % store for next time
                    gLast(cc)=thisG(1);
                end
            end
        end
        if ccWins>0,
            if dbgPlot,
                disp('Found a winner')
                cc
            end
            break
        end
    end
    
    % found first sign change - now final bisection search
    dUB = dT;
    dLB = dT-dStep;
    % need to check if rising or falling
    gUBsign = sign(thisG(1));
    while dUB>dLB+tolBisect,
        dT = 0.5*(dUB+dLB);
        [gT,pxa,pya,pt,clInc] = targetTimeDiff(dT,cInit,cTerm,Rmin,vWind,vFly,clMask);
        if gT(1)*gUBsign>0,
            dUB = dT;
        else
            dLB = dT;
        end
        if dbgPlot,
            dgs2 = [dgs2; dT gT];
        end
    end
    
end

% shift back by the wind
px = pxa + vWind(1)*pt/vFly;
py = pya + vWind(2)*pt/vFly;

% check we got where we wanted
%chkFinal = norm([px(end);py(end)]-cTerm(1:2))
%assert(chkFinal<1e-4)

% optional plotting of G functions for debug
if dbgPlot,
    dsRng = linspace(0,2*dmax,500);
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
    figure(12)
    plot(dgs(:,1),dgs(:,2),'x')
    hold on
    plot(dgs2(:,1),dgs2(:,2),'s')
    plot(dsRng,gsRng,'-')
    legend('s','s2','LSL','RSR','RSL','LSR','RLRo','LRLo','RLRi','LRLi')
    plot([0 2*dmax],[0 0],'k:')
end

end

function [G,pxa,pya,pt,cl] = targetTimeDiff(d,cInit,cTerm,Rmin,vWind,vFly,clMask)

% time for the wind to shift by d units
tShift = d/norm(vWind);

% find the wind-shifted target, moved by d units
cTermShifted = cTerm - [vWind(1);vWind(2);0]*tShift;

% find closest-timed Dubins path of selected class
[pxa,pya,pt,cl]=shortestDubinsPath(cInit,cTermShifted,Rmin,clMask);

% debug - plot the sucker
% figure(15)
% plot(pxa,pya)
% axis equal
% hold on

% trap empty case with NaN
if isempty(pt),
    tFly = NaN;
    G = NaN;
else
    % flight time for real aircraft
    tFly = max(pt,[],2)/vFly;
    
    % response is the difference
    G = tFly - tShift;
    
end

end