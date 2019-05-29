function out = streams_clustersignif(s)

% Build reference distribution

posd = vertcat(s(:).posdistribution);
negd = vertcat(s(:).negdistribution);

posref = max(posd, [], 1); % take maximal clusterstat across freq
negref = min(negd, [], 1); % take lowest clusterstat across freq

% Take maximal/minimal observed cluster statistic across freqs
for j = 1:numel(s)
   posstats{j} = [s(j).posclusters(:).clusterstat]; % organize into cell array
   negstats{j} = [s(j).negclusters(:).clusterstat]; 
end

posobs = max([posstats{:}]); % concatenate cells, take max cluster stat
negobs = min([negstats{:}]); % concatenate cells, take min cluster stat

% Compute proportion of surrogate stats higher or equal than observed (p-value)
% (at least one frequency is not exchangeable across conditions)

alpha = 0.025; % test in two directions

ngreater   = sum(posref > posobs);              % number higher
nequal     = sum(posref == posobs);             % number equal
p1         = (ngreater + nequal)/numel(posref); % percentage relative to ref

ngreater   = sum(negref < negobs);              % number lower
nequal     = sum(negref == negobs);             % number equal
p2         = (ngreater + nequal)/numel(negref); % percentage relative to ref

[p, ind] = min([p1, p2]);

test = p < alpha;

out.test  = test;
out.alpha = alpha;
out.p     = p;
out.ind   = ind;

end