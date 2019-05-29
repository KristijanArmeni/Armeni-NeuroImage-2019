function streams_dics_groupcontrast(opt)

% directories
datadir = ft_getopt(opt, 'datadir'); 
savedir = ft_getopt(opt, 'savedir'); 
ivar    = ft_getopt(opt, 'ivar');
foi     = ft_getopt(opt, 'foi');

load '/project/3011044.02/preproc/anatomy/connectivity_eucl5.mat';

% define subject array
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s01', 's06', 's09'});

% create strings for saving

prefix = [subjects{1} '-' subjects{end}];
sep    = '_';

savename_stat_all   = fullfile(datadir, [prefix sep ivar sep foi]);
savename_stat_group = fullfile(savedir, [prefix sep ivar sep foi]);

stat_all = cell(num_sub, 1);

%% Combine subject-specific structures

fprintf('Loading the following datafiles: %s over %d subjects \n\n', foi, num_sub)

% subject loop
for k = 1:num_sub

    subject = subjects{k};

    file_T = fullfile(datadir, [subject sep ivar sep foi]);
    load(file_T)

    stat_all{k} = stat;

end

% make all positions the same so that ft_sourcestat doesnt complain
for kk = 1:num_sub
   
    stat_all{kk}.pos = stat_all{1}.pos;
    
end

for k = 1:numel(stat_all)
    
    stat_all{k}.inside(:) = true;
    
end

%% Freq statistics
fprintf('Doing second level stats on: \n\n')

% Create the null structure
data_N = stat_all;
for k = 1:numel(data_N)
    data_N{k}.stat(:) = 0;
    %data_N{k}.stat(:) = nanmean(stat_all{k}.stat(:));
end

% specify design matrix
design                           = zeros(2, 2*num_sub);
design(1, 1:num_sub)             = 1:num_sub;
design(1, num_sub + 1:num_sub*2) = 1:num_sub;
design(2, 1:num_sub)             = 1;
design(2, num_sub + 1:num_sub*2) = 2;

% second-level t-test
cfg                  = [];
cfg.method           = 'montecarlo';
cfg.parameter        = 'stat';
cfg.statistic        = 'depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.alpha            = 0.025; % adjust alpha-level for two-sided test
cfg.correcttail      = 'prob';  
cfg.numrandomization = 1000;
cfg.design           = design;
cfg.uvar             = 1;
cfg.ivar             = 2;

cfg.connectivity     = d; % this is precomputed connecitivy matrix from /project/3011044.02/preproc/anatomy

stat_group           = ft_sourcestatistics(cfg, stat_all{:}, data_N{:});

%% Saving

datecreated      = char(datetime('today', 'Format', 'dd-MM-yy'));
pipelinefilename = fullfile(savedir, ['s02-s28' sep ivar sep foi sep datecreated]);

if ~exist([pipelinefilename '.html'], 'file')

    cfgt          = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    
    ft_analysispipeline(cfgt, stat_group);

end

fprintf('Saving %s... \n', savename_stat_group)
save(savename_stat_group, 'stat_group');
