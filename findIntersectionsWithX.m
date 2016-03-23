function ints = findIntersectionsWithX(P)

% num vertices
nv = size(P,2);

% initial intersection list
ints = [];

for ii=1:nv,
    % adjoining vertex
    jj = mod(ii,nv)+1;
    % does it cross?
    if (P(2,ii)>0)&&(P(2,jj)<0),
        intx = P(1,ii) + (P(1,jj)-P(1,ii))*(0-P(2,ii))/(P(2,jj)-P(2,ii));
        ints = [ints [intx;0]];
    elseif (P(2,ii)<0)&&(P(2,jj)>0),
        intx = P(1,ii) + (P(1,jj)-P(1,ii))*(0-P(2,ii))/(P(2,jj)-P(2,ii));
        ints = [ints [intx;0]];
    elseif P(2,jj)==0,
        % if vertex on the axis, check points either side
        j2 = mod(jj,nv)+1;
        if (P(2,ii)<0)&&(P(2,j2)>0),
            intx = P(1,jj);
            ints = [ints [intx;0]];
        elseif (P(2,ii)>0)&&(P(2,j2)<0),
            intx = P(1,jj);
            ints = [ints [intx;0]];
        end
    end
end
        