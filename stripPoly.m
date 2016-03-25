function strips = stripPoly(P,ang,wid,ofs)

% first rotate it to align strip angl with X axis
Mrot = [cos(ang) sin(ang); -sin(ang) cos(ang)];
Pr = Mrot*P;

% now shift it by the offset
Prs = [Pr(1,:);
       Pr(2,:)-ofs];
   
% start by splitting at the X axis
[Psabove,Psbelow] = splitPolyOnX(Prs);
   
% debug - just return the shifted rotated thing
strips = {Psabove{:},Psbelow{:}};
