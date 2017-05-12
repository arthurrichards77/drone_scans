% run "simpleSequence" first

% save for AMPL
fid = fopen('tsp.dat','w');
AMPLscalarint(fid,'N',numStrips);
AMPLmatrix(fid,'J',cost);
fclose(fid);

% run AMPL - either UoB or BRL version
% latter uses local temp install of AMPL
%!ampl tsp.run
!runampl tsp_cplex.run

% load results
res = load('res.dat');

% reshape to matrix
X = reshape(res,2*numStrips+1,2*numStrips+1)';

% convert back to sequence
% start with first job
currJob = find(X(2*numStrips+1,:));

% initial path
pp = [];
scanTime = 0;
turnTime = 0;

for kk=1:(2*numStrips),
    % complete current strip
    currStrip = ceil(currJob/2);
    currDir = 1+mod(currJob,2);
    % and strip path
    pp = [pp stripFlights{currStrip}(:,[3-currDir currDir])];
    scanTime = scanTime + stripTimes(currStrip,currDir);
    % next job
    nextJob = find(X(currJob,:));
    if nextJob == 2*numStrips+1,
        break
    end
    nextStrip = ceil(nextJob/2);
    nextDir = 1+mod(nextJob,2);
    % transit path
    pp = [pp transitFlights{currStrip,currDir,nextStrip,nextDir}];
    turnTime = turnTime + transitTimes(1+2*currStrip-currDir,1+2*nextStrip-nextDir);
    % update
    currJob = nextJob;
end

% plot
figure(2)
clf
% plot the original field
patch(P(1,:),P(2,:),'g')
axis equal
hold on
for kk=1:numStrips,
    thisP = strips{kk};
    if numel(thisP)>0,
        col = 'c'; %[pp 0 numStrips-pp]/numStrips;
        patch(strips{kk}(1,:),strips{kk}(2,:),col,'FaceAlpha',0.5)
    end
end

plot(pp(1,:),pp(2,:),'k-', ...
    1.2*max(P(1,:)), 1.2*max(P(2,:)),'ro', 1.2*max(P(1,:)) + [0 vWind(1)], 1.2*max(P(2,:)) + [0 vWind(2)],'r-', ...
    pp(1,1),pp(2,1),'k^','LineWidth',1.5)
title(sprintf('%.0f^o : %.1f scanning and %.1f turning : %.1f total',ang*180/pi,scanTime,turnTime,scanTime+turnTime))

testCost = sum(sum(X(1:(2*numStrips),:).*cost))