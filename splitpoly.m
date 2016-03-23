function Ps = splitpoly(P,pq)

% check for no intersection at all
if noIntersect(P,pq),
    Ps = {P};
    return
end

% split into two parts
Ps = split2(P,pq);

%return

% and the subdivide for closures
jj = 1;
while jj<=numel(Ps),
    [PsC,PsRest] = findFirstClosure(Ps{jj});
    % if no closure found
    if numel(PsRest)==0,
        % move to next in the list
        jj = jj+1;
    else
        % add two new polygons to list and keep dividing
        Ps{jj} = PsC;
        Ps{numel(Ps)+1} = PsRest;
    end
end

% final remove line segments
flags = true(numel(Ps),1);
for jj=1:numel(Ps),
    if size(Ps{jj},1)<3,
        flags(jj)=false;
    end
end
Ps = Ps(flags);

end % func

%% find closures in polygons - i.e. corridors of zero width
function [Pc,Prest] = findFirstClosure(P)

% nothing yet
Pc = [];
Prest = [];

% nothing to say if P is only a line
if size(P,1)<3,
    return
end

ii=0;
% test all vertices
for ii=1:size(P,1);
    thisP = P(ii,:);
    % test it against all segments
    for jj=1:size(P,1),
        j1 = jj;
        j2 = mod(jj,size(P,1))+1;
        if (j1~=ii)&&(j2~=ii),
            if pointOnSeg(thisP,P(j1,:),P(j2,:)),
                % closed polygon
                if j2<j1,
                    Pc = P(1:ii,:);
                    Prest = P((ii:size(P,1)),:);
                elseif ii>j2,
                    Pc = P(j2:ii,:);
                    Prest = P([(1:j1) (ii:size(P,1))],:);
                elseif ii<j1,
                    Pc = P(ii:j1,:);
                    Prest = P([(1:ii) (j2:size(P,1))],:);
                else
                    error('What am I doing here?')
                end
                %P
                %Pc
                %Prest
                %pause
                break
            end
        end
    end
    if numel(Pc)>0,
        break
    end
end

end % func

%% test for point being on a line segment
function flag=pointOnSeg(xyt,xy1,xy2)
%fprintf('Does (%f,%f) lie on (%f,%f)->(%f,%f)?\n',xyt(1),xyt(2),xy1(1),xy1(2),xy2(1),xy2(2));
flag=false;

% again put in M*z=v form
% where z is [a;b]
Mp = [xy1(1) xy2(1);
    xy1(2) xy2(2);
    1      1];
vp = [xyt(1); xyt(2); 1];
% solve (or attempt to)
zp = Mp\vp;
% test for on seg
if zp(1)>=0,
    if zp(2)>=0,
        if norm(Mp*zp-vp)<6*eps,
            flag=true;
        end
    end
end

end % func

%% divide boundary paths into two sides
function Ps = split2(P,pq)

% initialise basic split
Ps = {[],[]};
currList = 1;

% loop through line segments
for ii=2:size(P,1),
    xyi = segLineIntersect(P(ii-1,:),P(ii,:),pq(1:2),pq(3));
    if any(isnan(xyi)),
        % no intersection - add to current list
        Ps{currList} = [Ps{currList}; P(ii,:)];
    else
        % intersects - switch lists
        Ps{currList} = [Ps{currList}; xyi(1) xyi(2)];
        currList = 3-currList;
        Ps{currList} = [Ps{currList}; xyi(1) xyi(2); P(ii,:)];
    end
end
% and now just add the final one
xyi = segLineIntersect(P(size(P,1),:),P(1,:),pq(1:2),pq(3));
if any(isnan(xyi)),
    % no intersection - add to current list
    Ps{currList} = [Ps{currList}; P(1,:)];
else
    % intersects - switch lists
    Ps{currList} = [Ps{currList}; xyi(1) xyi(2)];
    currList = 3-currList;
    Ps{currList} = [Ps{currList}; xyi(1) xyi(2); P(1,:)];
end

end % func

%% global intersection check
function flag = noIntersect(P,pq)

% no intersection if all vertices are strictly one side
% or the other side of p*x=q
chk = [pq(1) pq(2)]*P';
flag = (max(chk)<pq(3)) || (min(chk)>pq(3));

end % func

%% intersection between segment and dividing line
function xyi = segLineIntersect(xy1,xy2,p,q)
%
% find intersection point between
% line segment from xy1 to xy2
% and line defined by p'*x=q
%

% set it up as solving M*z = v
% where z is [xyi;a;b]

M = [p(1) p(2) 0 0;
    -1  0  xy1(1) xy2(1);
    0 -1  xy1(2) xy2(2);
    0  0  1  1];

v = [q; 0; 0; 1];

% solve
z = M\v;

xyi = [NaN; NaN];
if (z(3)>0)&&(z(4)>=0),
    if norm(M*z-v)<6*eps,
        xyi = z(1:2);
        %subplot 321
        %plot(xyi(1),xyi(2),'ko')
    end
end

end % func