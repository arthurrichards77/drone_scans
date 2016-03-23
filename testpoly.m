close all
clear all

% field polygon
% each column is a vertex
P = [0 0;
     0 1;
     1 1;
     1 0;
     0.75 0;
     0.75 0.5;
     0.3 0.5;
     0.3 0]';

%% rotate the polygon

% rotation angle
ang = -1*pi/7;

% rotation matrix
Mrot = [cos(ang) sin(ang); -sin(ang) cos(ang)];

% rotate polygon
Pr = Mrot*P;

% plot it
figure
patch(Pr(1,:),Pr(2,:),'g')
axis equal
hold on

%% find intersections with strip boundaries

% limits
dely = 0.2;
miny = min(Pr(2,:));
maxy = max(Pr(2,:));
dy = miny-dely;

kk=0;
while dy<maxy,
    kk = kk+1;
    
    % and shift it
    dy = dy + dely;
    % store the shift for later
    dys(kk) = dy;

    % the shift in Y
    Prs = [Pr(1,:);
           Pr(2,:) - dy];

    % find intersections with X axis
    ints = findIntersectionsWithX(Prs);
    if numel(ints)>0,
        % shift the intersection line back
        ints(2,:) = ints(2,:)+dy;
        % plot strip boundary
        plot(ints(1,:),ints(2,:),'--ko')
    end
    intsLists{kk} = ints;
end

%% determine strips

% initialise list
% each strip stored as vertices
strips = {};

for kk=2:numel(intsLists),
    
    % the appropriate min and max y values
    miny = dys(kk-1)
    maxy = dys(kk)
    
    % combine intersection lists
    intsBoth = [intsLists{kk-1} intsLists{kk}];
    
    % sort them by x ordinate
    [sortx,isort]=sort(intsBoth(1,:));
    intsBothSorted = [sortx; intsBoth(2,isort)]
    
    % initialize sweep along x
    inTop = false;
    inBtm = false;
    xStart = inf;
    
    for ii=1:size(intsBothSorted,2),
        % grab the next intersection
        thisInt = intsBothSorted(:,ii);
        % toggle top or bottom state
        if thisInt(2)==miny,
            inBtm = not(inBtm);
        else
            inTop = not(inTop);
        end
        % if not in a strip
        if isinf(xStart),
            % start a new strip
            xStart = thisInt(1);
        elseif (not(inBtm))&&(not(inTop)),
            % end of a strip
            xEnd = thisInt(1);            
            % add to strip list
            strips = {strips{:},[[xStart xEnd xEnd xStart];[miny miny maxy maxy]]};
            % plot it
            patch([xStart xEnd xEnd xStart],[miny miny maxy maxy],'r')
            % reset xStart
            xStart = inf;
        end
    end
end