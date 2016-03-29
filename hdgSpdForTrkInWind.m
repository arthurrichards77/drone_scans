function [hdg,Vg] = hdgSpdForTrkInWind(Va,trk,vWind)
%
% find heading and ground speed given airspeed and ground track
% compensating for wind vector vWind
%

% wind angle
psi = atan2(vWind(2),vWind(1));

% internal angle of tri at ground meets wind
beta = psi-trk;

% sine rule to get internal angle at origin
alpha = asin(sin(beta)*norm(vWind)/Va);

% this give me the heading
hdg = trk - alpha;

% third internal angle of the triangle
gamma = pi - alpha - beta;

% sine rule again to get the ground speed
Vg = Va*sin(gamma)/sin(beta);

