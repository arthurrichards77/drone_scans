function [px,py,pt]=shortestWindPath(cInit,cTerm,Rmin)

% all headings must be between -pi and pi
cInit(3)=fixHeading(cInit(3));
cTerm(3)=fixHeading(cTerm(3));

% start with no wind path
[px,py,pt]=shortestNoWindPath(cInit,cTerm,Rmin);

end

function hOut = fixHeading(hIn)
% all headings must be between -pi and pi

hOut=hIn;
while hOut>pi,
    hOut=hOut-2*pi;
end

end

function [px,py,pt]=shortestNoWindPath(cInit,cTerm,Rmin)

% start with just one class
[px,py,pt]=pathTST(cInit,cTerm,Rmin,-1,-1);
[px,py,pt]=pathTST(cInit,cTerm,Rmin,1,-1);
[px,py,pt]=pathTST(cInit,cTerm,Rmin,-1,1);
[px,py,pt]=pathTST(cInit,cTerm,Rmin,1,1);
px=[]
py=[]

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
    end
else
    % in RSR or LSL
    % tangent will be parallel to line joint centres
    [xt1,yt1,xt2,yt2]=findParallelTangent(xc1,yc1,xc2,yc2,Rmin,dir1);
end

px = [xc1 xc2];
py = [yc1 yc2];

% debug - plot it
%hold on
%plot(px,py,'m--')

end

function [xc,yc]=findTangCircCtr(cTang,Rmin,dir)
%

% make sure direction is sensible, +/-1
dir = sign(dir);
assert(dir~=0);

% rotation matrix
M = [0 dir; -dir 0];

% rotate the tangent vector to get vector from point to centre
vCtr = Rmin*M*[cos(cTang(3));sin(cTang(3))];

% add it to points
xc = cTang(1)+vCtr(1);
yc = cTang(2)+vCtr(2);

% debug - plot the thing
ths = pi*linspace(0,2,50);
hold on
plot(xc+Rmin*cos(ths),yc+Rmin*sin(ths),'m-')

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
hold on
plot([xt1 xt2],[yt1 yt2],'m--')

end