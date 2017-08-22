function [p_out, samp_dist, cum_dist] = resamplepath(p_in,d)

% get cumulative distance
step_dist = sqrt(sum(diff(p_in').^2,2));
cum_dist = [0;cumsum(step_dist)];

% and total distance
total_dist = cum_dist(end);

% remove duplicates
[cum_dist_un,ikeep] = unique(cum_dist,'stable');
p_un = p_in(:,ikeep);

% new sample points in terms of distance
num_samps = ceil(total_dist/d);
samp_dist = linspace(0,total_dist,num_samps);

% sample
px_out = interp1(cum_dist_un,p_un(1,:),samp_dist)';
py_out = interp1(cum_dist_un,p_un(2,:),samp_dist)';

% combine
p_out = [px_out';py_out'];