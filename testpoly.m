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

pq = [-0.25 1 -0.04];
%pq = [1 1 1.14];
%pq = [1 1 0.14];
%pq = [1 1 1.34];
%pq = [0 1 0.45];
%pq = [-0.25 1 0.24];
%pq = [0 1 -2.45];

subplot 321
patch(P(:,1),P(:,2),'g')
axis equal
hold on
a = axis();

Ps = splitpoly(P,pq)

for ii=1:numel(Ps),
    Pi = Ps{ii};
    ci = [ii 0 numel(Ps)-ii];
    ci = ci / norm(ci);
    subplot(3,2,1)
    patch(Pi(:,1),Pi(:,2),ci)
    subplot(3,2,ii+1)
    patch(Pi(:,1),Pi(:,2),ci)
    axis(a)
end