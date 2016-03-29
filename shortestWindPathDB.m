function [px,py,pt,pxa,pya,clInc]=shortestWindPathDB(cInit,cTerm,Rmin,vFly,vWind)
%
% includes database of previous solutions
%

persistent turnDBrows turnDBsols

% position offset - shift to start at origin
cInitOs=cInit - [cInit(1:2); 0];
cTermOs=cTerm - [cInit(1:2); 0];

% build into single row vector
queryRow = [cInitOs(3) cTermOs(1) cTermOs(2) cTermOs(3) Rmin vFly vWind(1) vWind(2)];

% test if in DB
if isempty(turnDBrows),
    loc=0;
else
    [~,loc]=ismember(queryRow,turnDBrows,'rows');
end

if loc>0,
    
    disp('Reuse')
    % done this one already
    sol = turnDBsols{loc};
    px = sol.px;
    py = sol.py;
    pt = sol.pt;
    pxa = sol.pxa;
    pya = sol.pya;
    clInc = sol.clInc;
    
else
    
    queryRow
    turnDBrows
    
    % just call the other for now
    [px,py,pt,pxa,pya,clInc]=shortestWindPath(cInitOs,cTermOs,Rmin,vFly,vWind);
    
    % store it in DB
    sol = struct('px',px,'py',py,'pt',pt,'pxa',pxa,'pya',pya,'clInc',clInc);
    
    if isempty(turnDBrows),
        turnDBrows = queryRow;
        turnDBsols = {sol};
    else
        turnDBrows = [turnDBrows;queryRow];
        turnDBsols = {turnDBsols{:},sol};
    end
end

% need to put it back to original location
px = px+cInit(1);
py = py+cInit(2);