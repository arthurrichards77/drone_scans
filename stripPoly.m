function [strips,flights] = stripPoly(P,ang,wid,ofs)

% first rotate it to align strip angl with X axis
Mrot = [cos(ang) sin(ang); -sin(ang) cos(ang)];
Pr = Mrot*P;

% now shift it by the offset
Prs = [Pr(1,:);
       Pr(2,:)-ofs];
   
% start by splitting at the X axis
[Psabove,Psbelow] = splitPolyOnX(Prs);

% flip the below section
Psbel2 = Psbelow;
for ii=1:numel(Psbelow),
    Psbel2{ii} = [Psbelow{ii}(1,:);
                 -Psbelow{ii}(2,:)];
end

% divide each in horizontal strips working up from x axis
stripsAbove = cutStripPlusPolys(Psabove,wid);
stripsBel2 = cutStripPlusPolys(Psbel2,wid);

% flip below section back
stripsBelow = stripsBel2;
for ii=1:numel(stripsBelow),
    stripsBelow{ii}(2,:) = -stripsBel2{ii}(2,:);
end

% debug - just return the shifted rotated thing
strips = {stripsAbove{:},stripsBelow{:}};

% final post-processing of strips
for ii=1:numel(strips),
    % convert to bounding box
    strips{ii} = boundBox(strips{ii});
    % undo the original offset in y
    strips{ii}(2,:) = strips{ii}(2,:)+ofs;
    % rotate back to the original alignment
    strips{ii} = Mrot'*strips{ii};
    % and find the flight along its middle
    flights{ii} = findMidline(strips{ii});
end

end

function strips = cutStripPlusPolys(Ps,wid)

% list of polygons generated
strips = {};

% list of polygons above current cut
PsToGo = Ps;

% current cutting line
cut = -wid;

% keep going while there's anything above the line
while numel(PsToGo)>0,
    
    % move the cut line up
    cut=cut+wid;
    
    % do the next cut
    [Psabove,Psbelow]=splitPolyListHoriz(PsToGo,cut);
    
    % update the lists
    PsToGo = Psabove;
    strips = {strips{:},Psbelow{:}};
    
end

end

function [Psabove,Psbelow]=splitPolyListHoriz(Ps,cut)
Psabove = {};
Psbelow = {};
for ii=1:numel(Ps),
    [Psai,Psbi] = splitPolyHoriz(Ps{ii},cut);
    Psabove = {Psabove{:},Psai{:}};
    Psbelow = {Psbelow{:},Psbi{:}};
end
end

function [Psa,Psb] = splitPolyHoriz(P,cut)
Pshifted = [P(1,:);
            P(2,:)-cut];
[Psa,Psb] = splitPolyOnX(Pshifted);
for ii=1:numel(Psa),
    Psa{ii}(2,:) = Psa{ii}(2,:) + cut;
end
for ii=1:numel(Psb),
    Psb{ii}(2,:) = Psb{ii}(2,:) + cut;
end
end

function [Pbox] = boundBox(P)

% find min and max of each ordinate
xmin = min(P(1,:));
xmax = max(P(1,:));
ymin = min(P(2,:));
ymax = max(P(2,:));

% find the bounding box polygon
Pbox = [xmin xmax xmax xmin;
        ymin ymin ymax ymax];
    
end

function [midline]=findMidline(Pbox)

enda = 0.5*(Pbox(:,1)+Pbox(:,4));
endb = 0.5*(Pbox(:,2)+Pbox(:,3));
midline = [enda endb];

end