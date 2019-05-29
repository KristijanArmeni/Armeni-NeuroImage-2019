
% Load files
datadir = '/project/3011085.04/streams/analysis/freqanalysis/source/group4-combinedfreq/onset_lock_nooverlap';
l = dir(datadir);
l = l(contains({l.name}, '.mat')); % Grab only .mat files, not .htmls

%% Entropy

fnames = l(contains({l.name}, 'entropy'));
%fnames = fnames([2,3,4,6]); % TEMP: remove alpha and theta (not included with 0.25 time windows)


% Load freq-specific stat structures
for k = 1:numel(fnames)
    
    f = fullfile(datadir, fnames(k).name);
    load(f);                                 % <stat_group> variable
    
    s1(k) = stat_group;
    clear stat_group
    
end

out1 = streams_clustersignif(s1);

%% Perplexity

fnames = l(contains({l.name}, 'perplexity'));
%fnames = fnames([2,3,4,6]);

for k = 1:numel(fnames)
    
    f = fullfile(datadir, fnames(k).name);
    load(f);                                 % <stat_group> variable
    
    s2(k) = stat_group;
    clear stat_group
    
end

out2 = streams_clustersignif(s2);
