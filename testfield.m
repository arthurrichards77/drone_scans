close all
clear all

P = [0 0;
    0 1;
    1 1;
    1 0;
    0.75 0;
    0.75 0.5;
    0.3 0.5;
    0.3 0];

subplot 121
patch(P(:,1),P(:,2),'g')
axis equal

p = [0.25 1];
%p = [-0.25 1];
p = [1 eps];
%p = [eps 1];
%p = [1 1];
%p = [-1 0];

p = p/norm(p);

dq = 0.05;

q0 = min(p*P');
q1 = max(p*P');

%% split into strips
flag = true;
Ps = {P};
q = q0;

while q<q1,
    q = q+dq;
    np = numel(Ps);
    for ii=1:np,
        if flag(ii),
            Pnew = splitpoly(Ps{ii},[p q]);
            if numel(Pnew)>1,
                flag(ii) = false;
                Ps = {Ps{:},Pnew{:}};
                flag = [flag true(size(Pnew))];
            end
        end
    end
end
Ps = Ps(flag);

%% turn strips into rectangles

% perpendicular to p
pr = [-p(2) p(1)];

np = numel(Ps);
for ii=1:np,
    
    thisP = Ps{ii};
    epMin = min(p*thisP');
    epMax = max(p*thisP');
    erMin = min(pr*thisP');
    erMax = max(pr*thisP');
    Ps{ii}=[epMin epMax epMax epMin;
        erMin erMin erMax erMax]'*[p;pr];
    
    
end

%% draw polygons
subplot 122
axis equal
np = numel(Ps);
for ii=1:np,
    Pi = Ps{ii};
    ci = [ii 0 numel(Ps)-ii];
    ci = ci / norm(ci);
    patch(Pi(:,1),Pi(:,2),ci)
end
hold on
plot(P([1:end 1],1),P([1:end 1],2),'g')