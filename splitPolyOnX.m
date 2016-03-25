function [PsAbove,PsBelow] = splitPolyOnX(P)

[Pabove,Pbelow] = splitPolyIn2OnX(P);

PsAbove = splitClosedPolys(Pabove);
PsBelow = splitClosedPolys(Pbelow);

%PsAbove = {Pabove};
%PsBelow = {Pbelow};

PsAbove = removeLines(PsAbove);
PsBelow = removeLines(PsBelow);

end

function [Pabove,Pbelow] = splitPolyIn2OnX(P)

% num vertices
nv = size(P,2);

% initialize polygons
Pabove = [];
Pbelow = [];

% find lowest vertex
[ymin,v1] = min(P(2,:));

% if all above, nothing more to do
if ymin>0,
    Pabove = P;
    return
end

% work from the lowest vertex up
Pbelow = P(:,v1);

% flag for next - true=above; false=below
flagAbove = false;

for ii=1:nv,
    % adjoining vertex
    v2 = mod(v1,nv)+1;
    % are we above or below?
    if ~flagAbove,
        % we're starting below
        % if next one strictly above
        if P(2,v2)>0,
            % crossed axis - break to other poly
            Pc = crossPoint(P(:,v1),P(:,v2));
            Pbelow = [Pbelow Pc];
            Pabove = [Pabove Pc P(:,v2)];
            % change to above
            flagAbove=true;
        elseif P(2,v2)==0,
            % possible degeneracy - check next one along
            v3 = mod(v2,nv)+1;
            if P(2,v3)>0,
                % it is a crossing
                Pc = P(:,v2);
                Pbelow = [Pbelow Pc];
                Pabove = [Pabove Pc];
                % change to above
                flagAbove=true;
            else
                % staying below
                Pbelow = [Pbelow P(:,v2)];
            end
        else
            % no crossing - still below the line
            Pbelow = [Pbelow P(:,v2)];
        end
    else
        % we're starting above
        % if next one strictly below
        if P(2,v2)<0,
            % crossed axis - break to other poly
            Pc = crossPoint(P(:,v1),P(:,v2));
            Pbelow = [Pbelow Pc P(:,v2)];
            Pabove = [Pabove Pc];
            % change to below
            flagAbove=false;
        elseif P(2,v2)==0,
            % possible degeneracy - check next one along
            v3 = mod(v2,nv)+1;
            if P(2,v3)<0,
                % it is a crossing
                Pc = P(:,v2);
                Pbelow = [Pbelow Pc];
                Pabove = [Pabove Pc];
                % change to above
                flagAbove=false;
            else
                % staying above
                Pabove = [Pabove P(:,v2)];
            end
        else
            % no crossing - still above the line
            Pabove = [Pabove P(:,v2)];
        end
    end
    % move to next vertex
    v1 = v2;
end

end

function Pc = crossPoint(P1,P2)
xc = P1(1) + (P2(1)-P1(1))*(0-P1(2))/(P2(2)-P1(2));
Pc = [xc;0];
end

function Ps = splitClosedPolys(P)
Ps = {P};
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

end

function [Pc,Prest] = findFirstClosure(P)

% nothing yet
Pc = [];
Prest = [];

% number of vertices
nv = size(P,2);

% nothing to say if P is only a line
if nv<3,
    return
end

ii=0;
% test all vertices
for ii=1:nv;
    thisP = P(:,ii);
    % test it against all segments
    for jj=1:nv,
        j1 = jj;
        j2 = mod(jj,nv)+1;
        if (j1~=ii)&&(j2~=ii),
            if pointOnSeg(thisP,P(:,j1),P(:,j2)),
                % closed polygon
                if j2<j1,
                    Pc = P(:,1:ii);
                    Prest = P(:,(ii:nv));
                elseif ii>j2,
                    Pc = P(:,j2:ii);
                    Prest = P(:,[(1:j1) (ii:nv)]);
                elseif ii<j1,
                    Pc = P(:,ii:j1);
                    Prest = P(:,[(1:ii) (j2:nv)]);
                else
                    error('What am I doing here?')
                end
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
flag = false;
% must all be on x axis
if xyt(2)~=0,
    return
end
if xy1(2)~=0,
    return
end
if xy2(2)~=0,
    return
end
% test points could be either way round
if (xyt(1)>=xy1(1))&&(xyt(1)<=xy2(1)),
    flag=true;
elseif (xyt(1)>=xy2(1))&&(xyt(1)<=xy1(1)),
    flag=true;
end

end % func

function PsOut = removeLines(Ps)

% final remove line segments
flags = true(numel(Ps),1);
for jj=1:numel(Ps),
    if size(Ps{jj},2)<3,
        flags(jj)=false;
    end
end
PsOut = Ps(flags);

end