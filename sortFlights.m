function fltsOut = sortFlights(fltsIn,dirVec)
%
% sort flights in ascending order of projection
% of midpoints on 'dirVec'
%

% calculate for each
for ii=1:numel(fltsIn),
    vals(ii) = [dirVec(1) dirVec(2)]*fltsIn{ii}*[0.5;0.5];
end

% do the sort
[svals,sidx]=sort(vals);

% and return the sorted flight list
fltsOut = fltsIn(sidx);