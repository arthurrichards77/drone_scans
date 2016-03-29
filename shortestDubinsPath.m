function [px,py,pt,clInc]=shortestDubinsPath(cInit,cTerm,Rmin,clMask)
%
% clMask(i)=True <=> try class i

% default to try first six classes
if ~exist('clMask','var'),
    clMask = [true(6,1); false(2,1)];
end

% initialise
tInc = inf;
clInc = 'NFP'; % no feasible path
px=[];
py=[];
pt=[];

if clMask(1),
    % start with just one class
    [px2,py2,pt2]=pathTST(cInit,cTerm,Rmin,-1,-1);
    % update incumbent
    if max(pt2)<tInc,
        px=px2;
        py=py2;
        pt=pt2;
        clInc = 'LSL';
        tInc = max(pt2);
    end
end

if clMask(2),
    % start with just one class
    [px2,py2,pt2]=pathTST(cInit,cTerm,Rmin,1,1);
    % update incumbent
    if max(pt2)<tInc,
        px=px2;
        py=py2;
        pt=pt2;
        clInc = 'RSR';
        tInc = max(pt2);
    end
end

if clMask(3),
    % start with just one class
    [px2,py2,pt2]=pathTST(cInit,cTerm,Rmin,1,-1);
    % update incumbent
    if max(pt2)<tInc,
        px=px2;
        py=py2;
        pt=pt2;
        clInc = 'RSL';
        tInc = max(pt2);
    end
end

if clMask(4),
    % start with just one class
    [px2,py2,pt2]=pathTST(cInit,cTerm,Rmin,-1,1);
    % update incumbent
    if max(pt2)<tInc,
        px=px2;
        py=py2;
        pt=pt2;
        clInc = 'LSR';
        tInc = max(pt2);
    end
end

if clMask(5),
    % start with just one class
    [px2,py2,pt2]=pathTTT(cInit,cTerm,Rmin,1,-1);
    % update incumbent
    if max(pt2)<tInc,
        px=px2;
        py=py2;
        pt=pt2;
        clInc = 'RLRouter';
        tInc = max(pt2);
    end
end

if clMask(6),
    % start with just one class
    [px2,py2,pt2]=pathTTT(cInit,cTerm,Rmin,-1,1);
    % update incumbent
    if max(pt2)<tInc,
        px=px2;
        py=py2;
        pt=pt2;
        clInc = 'LRLouter';
        tInc = max(pt2);
    end
end

if clMask(7),
    % start with just one class
    [px2,py2,pt2]=pathTTT(cInit,cTerm,Rmin,1,1);
    % update incumbent
    if max(pt2)<tInc,
        px=px2;
        py=py2;
        pt=pt2;
        clInc = 'RLRinner';
        tInc = max(pt2);
    end
end

if clMask(8),
    % start with just one class
    [px2,py2,pt2]=pathTTT(cInit,cTerm,Rmin,-1,-1);
    % update incumbent
    if max(pt2)<tInc,
        px=px2;
        py=py2;
        pt=pt2;
        clInc = 'LRLinner';
        tInc = max(pt2);
    end
end

end

function [px,py,pt]=pathTST(cInit,cTerm,Rmin,dir1,dir2)

pt=0;
[xc1,yc1]=findTangCircCtr(cInit,Rmin,dir1);
[xc2,yc2]=findTangCircCtr(cTerm,Rmin,dir2);

if dir1~=dir2,
    % LSR and RSL only exist if far enough apart
    if norm([xc1,yc1]-[xc2,yc2])<2*Rmin,
        % too close
        px=[];
        py=[];
        pt=inf;
        % no more to do
        return
    else
        % tangent will be parallel to line joint centres
        [xt1,yt1,xt2,yt2]=findCrossingTangent(xc1,yc1,xc2,yc2,Rmin,dir1);
    end
else
    % in RSR or LSL
    % tangent will be parallel to line joint centres
    [xt1,yt1,xt2,yt2]=findParallelTangent(xc1,yc1,xc2,yc2,Rmin,dir1);
end

% fill in the circles
[xr1,yr1,arc1]=pointsOnCirc(xc1,yc1,cInit(1),cInit(2),xt1,yt1,Rmin,dir1);
[xr2,yr2,arc2]=pointsOnCirc(xc2,yc2,xt2,yt2,cTerm(1),cTerm(2),Rmin,dir2);

% compile list of points
px = [xr1 xr2];
py = [yr1 yr2];

% add up length
len1=max(arc1);
len2=norm([xt2-xt1,yt2-yt1]);
pt = [arc1 (len1+len2)+arc2];

% debug
%hold on
%plot(px,py,'m-')

end

function [xc,yc]=findTangCircCtr(cTang,Rmin,dir)
%

% make sure direction is sensible, +/-1
%dir = sign(dir);
%assert(dir~=0);

% rotation matrix
%M = [0 dir; -dir 0];

% rotate the tangent vector to get vector from point to centre
vCtr = Rmin*[sin(cTang(3));-cos(cTang(3))];
if dir<0,
    vCtr = -vCtr;
end

% add it to points
xc = cTang(1)+vCtr(1);
yc = cTang(2)+vCtr(2);

% debug - plot the thing
%ths = pi*linspace(0,2,50);
%hold on
%plot(xc+Rmin*cos(ths),yc+Rmin*sin(ths),'m-')

end

function [xt1,yt1,xt2,yt2]=findParallelTangent(xc1,yc1,xc2,yc2,Rmin,dir)

vx = xc2-xc1;
vy = yc2-yc1;
hdg = atan2(vy,vx);
ang = hdg + dir*pi/2;
xt1 = xc1 + Rmin*cos(ang);
yt1 = yc1 + Rmin*sin(ang);
xt2 = xc2 + Rmin*cos(ang);
yt2 = yc2 + Rmin*sin(ang);

% debug plot
%hold on
%plot([xt1 xt2],[yt1 yt2],'m--')

end

function [xt1,yt1,xt2,yt2]=findCrossingTangent(xc1,yc1,xc2,yc2,Rmin,dir)

vx = xc2-xc1;
vy = yc2-yc1;
hdg = atan2(vy,vx);
ang = hdg + dir*acos(2*Rmin/norm([vx vy]));
xt1 = xc1 + Rmin*cos(ang);
yt1 = yc1 + Rmin*sin(ang);
xt2 = xc2 - Rmin*cos(ang);
yt2 = yc2 - Rmin*sin(ang);

% debug plot
%hold on
%plot([xt1 xt2],[yt1 yt2],'m--')

end

function [xr,yr,arc]=pointsOnCirc(xc,yc,x1,y1,x2,y2,R,dir)
% find a set of points on a circle centred on (xc,yc) from (x1,y1) to
% (x2,y2) in direction dir.  R is radius.

dir = -dir;

%assert(norm([x1-xc,y1-yc])==R)
%assert(norm([x2-xc,y2-yc])==R)

% angles
t1 = atan2(y1-yc,x1-xc);
t2 = atan2(y2-yc,x2-xc);

% check for wraparound
if dir*(t2-t1)<0,
    t2 = t2 + 2*dir*pi;
end
arc = (0:49)*R*abs(t2-t1)/49;

% make angles
ts = dir*linspace(dir*t1,dir*t2,50);

% make points
xr = xc+R*cos(ts);
yr = yc+R*sin(ts);

end

function [px,py,pt]=pathTTT(cInit,cTerm,Rmin,dir1,dir2)

[xc1,yc1]=findTangCircCtr(cInit,Rmin,dir1);
[xc2,yc2]=findTangCircCtr(cTerm,Rmin,dir1);

% these paths only exist if close enough
if norm([xc1,yc1]-[xc2,yc2])>4*Rmin,
    % too far
    px=[];
    py=[];
    pt=inf;
    % no more to do
    return
end

% find centre of the mutual tangent circle
brg = atan2(yc2-yc1,xc2-xc1);
ang = acos(norm([xc1,yc1]-[xc2,yc2])/(4*Rmin));
xcm = xc1+2*Rmin*cos(brg+dir2*ang);
ycm = yc1+2*Rmin*sin(brg+dir2*ang);

% tangent points with first and second circle
xt1 = xc1+Rmin*cos(brg+dir2*ang);
yt1 = yc1+Rmin*sin(brg+dir2*ang);
xt2 = xc2+Rmin*cos(brg+pi-dir2*ang);
yt2 = yc2+Rmin*sin(brg+pi-dir2*ang);

% fill in the circles
[xr1,yr1,arc1]=pointsOnCirc(xc1,yc1,cInit(1),cInit(2),xt1,yt1,Rmin,dir1);
[xrm,yrm,arcm]=pointsOnCirc(xcm,ycm,xt1,yt1,xt2,yt2,Rmin,-dir1);
[xr2,yr2,arc2]=pointsOnCirc(xc2,yc2,xt2,yt2,cTerm(1),cTerm(2),Rmin,dir1);

% compile list of points
px = [xr1 xrm xr2];
py = [yr1 yrm yr2];

% add up length
len1 = max(arc1);
len2 = max(arcm);
pt = [arc1 len1+arcm len1+len2+arc2];

% debug
%hold on
%plot(px,py,'m-')

end
