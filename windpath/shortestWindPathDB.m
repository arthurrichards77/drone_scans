function [px,py,pt,pxa,pya,clInc]=shortestWindPathDB(cInit,cTerm,Rmin,vFly,vWind)
%
% includes database of previous solutions
%

persistent turnDBrows turnDBsols nextDBrow
maxDBsize = 500;

% position offset - shift to start at origin
cInitOs=cInit - [cInit(1:2); 0];
cTermOs=cTerm - [cInit(1:2); 0];

% build into single row vector
queryRow = [cInitOs(3) cTermOs(1) cTermOs(2) cTermOs(3) Rmin vFly vWind(1) vWind(2)];

% test if in DB
if isempty(turnDBrows),
    loc=0;
    turnDBrows = zeros(maxDBsize,8);
    nextDBrow = 0;
else
    [loc]=myDBsearch(queryRow,turnDBrows);
    %disp(size(turnDBrows))
end

if loc>0,
    
    %disp('Reuse')
    % done this one already
    sol = turnDBsols{loc};
    px = sol.px;
    py = sol.py;
    pt = sol.pt;
    pxa = sol.pxa;
    pya = sol.pya;
    clInc = sol.clInc;
    
else
    
    %queryRow
    %turnDBrows
    
    %disp('Fresh case')
    
    % just call the other for now
    %[px,py,pt,pxa,pya,clInc]=shortestWindPath(cInitOs,cTermOs,Rmin,vFly,vWind);
    [px,py,pt,pxa,pya,clInc]=shortestWindPath_mex(cInitOs,cTermOs,Rmin,vFly,vWind);
    
    % store it in DB
    sol = struct('px',px,'py',py,'pt',pt,'pxa',pxa,'pya',pya,'clInc',clInc);
    nextDBrow = nextDBrow+1;
    if nextDBrow>maxDBsize,
        nextDBrow=1;
    end
    turnDBrows(nextDBrow,:) = queryRow;
    turnDBsols{nextDBrow} = sol;
end

% need to put it back to original location
px = px+cInit(1);
py = py+cInit(2);

%chkFinal = norm([px(end);py(end)]-cTerm(1:2))

end

function [loc]=myDBsearch(queryRow,turnDBrows)

% take difference with each row
for ii=1:size(turnDBrows,1),
    dbDiff(ii) = norm(turnDBrows(ii,:)-queryRow);
end

% find the closest
[minDiff,ixMin]=min(dbDiff);

% check against tolerance
if minDiff<1e-7,
    loc = ixMin;
else
    loc = 0;
end

end