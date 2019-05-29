function streams_dics(subject, inpcfg)
% streams_dics() is a script, written as a matlab function. It performs epoching (1s), 
% freqanalysis and source reconstruction on preprocessed data MEG data.
% It splits the re-epoched trials into two groups and performs a first-level
% t-test on source estimates. 
% 
% 
% The following functions are called in this 'script':
%
% Custom:
%   streams_epochdefinecontrast()
%    
%
% Fieldtrip:
%   ft_selectdata
%   ft_freqanalysis
%   ft_sourceanalysis
%   ft_sourcestatistics
%   ft_regresconfound
%
%% INITIALIZE

dir             = ft_getopt(inpcfg, 'datadir');
savedir         = ft_getopt(inpcfg, 'savedir');
indepvar        = ft_getopt(inpcfg, 'indepvar');
removeonset     = ft_getopt(inpcfg, 'removeonset');
shift           = ft_getopt(inpcfg, 'shift'); % value for which to shif
savewhat        = ft_getopt(inpcfg, 'savewhat', 'stat');
freqband        = ft_getopt(inpcfg, 'freqband');
word_selection  = ft_getopt(inpcfg, 'word_selection', 'all');
epochtype       = ft_getopt(inpcfg, 'epochtype');
epochlength     = ft_getopt(inpcfg, 'epochlength');

% ft_diary('on', fullfile(dir, 'analysis', 'dics', 'firstlevel'));
% determine which featuredata.mat to load in
switch word_selection
    case 'all',             fdata = 'featuredata1';
    case 'content_noonset', fdata = 'featuredata2';
    case 'content',         fdata = 'featuredata3';
    case 'noonset',         fdata = 'featuredata4';
end 

preprocfile     = fullfile(dir, 'meg', [subject '_meg-clean.mat']);
featurefile     = fullfile(dir, 'meg', [subject '_' fdata]);
audiofile       = fullfile(dir, 'meg', [subject, '_aud.mat']);
headmodelfile   = fullfile(dir, 'anatomy', [subject '_headmodel.mat']);
leadfieldfile   = fullfile(dir, 'anatomy', [subject '_leadfield.mat']);
sourcemodelfile = fullfile(dir, 'anatomy', [subject '_sourcemodel.mat']);

% conditions file, frequency band doesn't matter here
% contrastfile    = fullfile('/project/3011044.02/analysis/lng-contrast/', [subject '.mat']); 

% determine 'foi' for ft_freqstatistics
switch freqband
    case 'delta',     foilim = [2 2];
    case 'theta',     foilim = [6 6];
    case 'alpha',     foilim = [10 10];
    case 'beta',      foilim = [16 16];
    case 'high-beta', foilim = [25 25];
    case 'gamma',     foilim = [45 45];
    case 'high-gamma',foilim = [75 75];
end

% condition taper and smoothing parameters on the frequency of interest
switch freqband
    case {'delta'}
        taper     = 'hanning';
    case {'theta', 'alpha'}
        taper     = 'dpss';
        tapsmooth = 2;
    case {'beta', 'high-beta'}
        taper     = 'dpss';
        tapsmooth = 5;
    case {'gamma', 'high-gamma'}
        taper     = 'dpss';
        tapsmooth = 15;
end

%% LOAD

load(preprocfile);    % meg data, 'data' variable
load(headmodelfile);
load(leadfieldfile);
load(sourcemodelfile);
load(featurefile);    % featuredata var
load(audiofile);      % audio var

%% PER SHIFT LOOP

for kk = 1:numel(shift)

    opt = {'save',              0, ...
           'language_features', {'log10wf' 'perplexity', 'entropy', 'word_'}, ...
           'audio_features',    {'audio_avg'}, ...
           'contrastvars',      {indepvar}, ...
           'removeonset',       removeonset, ...
           'shift',             shift(kk), ...
           'epochtype',         epochtype, ... 
           'epochlength',       epochlength, ...
           'overlap',           0};

    [avgfeature, data_epoched, ~, ~, contrast] = streams_epochdefinecontrast(data, featuredata, audio, opt);

    %% DO FREQANALYSIS

    cfg = [];
    cfg.method        = 'mtmfft';
    cfg.output        = 'fourier';
    cfg.keeptrials    = 'yes';
    cfg.taper         = taper;

    if strcmp(taper, 'dpss')
        cfg.tapsmofrq = tapsmooth;
    end

    cfg.foilim        = foilim;

    freq = ft_freqanalysis(cfg, data_epoched);
    clear data_epoched

    %% COMMON FILTER

    cfg                   = []; 
    cfg.method            = 'dics';
    cfg.frequency         = foilim(1);  
    cfg.grid              = sourcemodel;
    cfg.grid.leadfield    = leadfield.leadfield;
    cfg.headmodel         = headmodel;
    %cfg.keeptrials       = 'yes';
    cfg.dics.projectnoise = 'yes';
    cfg.dics.lambda       = '100%';
    cfg.dics.keepfilter   = 'yes';
    cfg.dics.realfilter   = 'yes';
    cfg.dics.fixedori     = 'yes';

    source_both = ft_sourceanalysis(cfg, ft_checkdata(freq,'cmbrepresentation','fullfast')); % trick to speed up the computation
    F           = cat(1,source_both.avg.filter{source_both.inside}); % common spatial filters per location

    %% SINGLE TRIAL POWER ESTIMATE

    % now do something hacky to efficiently compute the single trial power
    % estimates at the source level:
    ntap = freq.cumtapcnt(1); % number of tapers used

    nrpt = numel(freq.cumtapcnt); % number of trials
    x    = repmat(1:nrpt,[ntap 1]);
    x    = x(:);
    y    = 1:(nrpt*ntap);
    P    = sparse(y,x,ones(numel(x),1)./ntap);

    source = removefields(source_both, {'avg' 'cfg'});

    npos = size(source_both.pos,1);
    clear source_both;

    tmppow = abs(F*transpose(freq.fourierspctrm)).^2;
    %clear freq

    for k = 1:nrpt
        source.trial(k,1).pow                = zeros(npos, 1);
        source.trial(k,1).pow(source.inside) = tmppow*P(:,k);
    end

    % remove some stuff that's clogging wm
    clear tmppow;
    clear cfg;
    clear F P S;

    %% REGRESS OUT WORD FREQUENCY DATA

    tri = source.tri;
    if ~strcmp(indepvar, 'log10wf') % if ivarexp is lex. fr. itself skip this step

        nuisance_vars = {'log10wf', 'audio_avg'}; % take lexical frequency as nuissance
        confounds     = ismember(avgfeature.trialinfolabel, nuisance_vars); % logical with 1 in the columns for nuisance vars

        cfg          = [];
        cfg.confound = avgfeature.trialinfo(:, confounds); %pick the log10wf column

        source       = ft_regressconfound(cfg, rmfield(source, 'tri'));
        source.tri   = tri;

    end
    clear avgfeature % these are recreated within the loop
    
    %% SPLIT THE DATA

    ivarsel       = strcmp({contrast.indepvar}, indepvar); % use the precomputed contrasts
    contrastsel   = contrast(ivarsel); % chose a subset of the struct array

    low_column    = strcmp(contrastsel.label, 'low');
    high_column   = strcmp(contrastsel.label, 'high');

    trl_indx_low  = contrastsel.trial(:, low_column);
    trl_indx_high = contrastsel.trial(:, high_column);

    cfg         = [];
    cfg.trials  = trl_indx_low;
    source_low  = ft_selectdata(cfg, source);

    cfg         = [];
    cfg.trials  = trl_indx_high;
    source_high = ft_selectdata(cfg, source);
    clear source
    
    %% FIRST-LEVEL CONTRAST

    % desing matrix
    numobs_high = sum(trl_indx_high); % count the number of ones in this vector
    numobs_low  = sum(trl_indx_low);

    statdesign  = [ones(1, numobs_high) ones(1, numobs_low)*2];

    % independent between trials t-test
    cfg                     = [];
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'indepsamplesT'; % for each subject do between trials (independent) t-test
    cfg.parameter           = 'pow';
    cfg.numrandomization    = 0;
    cfg.design              = statdesign;

    stattmp(kk) = ft_sourcestatistics(cfg, source_high, source_low);
    %clear source_high source_low
    
end

%% CONCATENATE TIME-SHIFTED STAT STRUCTURES

stat             = rmfield(stattmp(1), {'stat'});
for kk = 1:numel(shift)
stat.stat(:,:,kk) = stattmp(kk).stat; 
end
clear stattmp

stat.dimord = 'chan_freq_time';
stat.time   = shift./1000;      % make it in seconds

%% SAVING 

dicsfreq           = num2str(foilim(1));

datecreated        = char(datetime('today', 'Format', 'dd-MM-yy'));
pipelinefilename   = [fullfile(savedir, ['pipeline' '_' indepvar '_' dicsfreq]) '_' datecreated];

if ~exist([pipelinefilename '.html'], 'file')
    cfgt           = [];
    cfgt.filename  = pipelinefilename;
    cfgt.filetype  = 'html';
    ft_analysispipeline(cfgt, stat);
end

savename = [subject '_' indepvar '_' dicsfreq];
%if strcmp(savewhat, 'stat')
%save(fullfile(savedir, savename), 'stat', 'inpcfg'); TEMP, to recompute trl_indx below
save(fullfile(savedir, [savename '-trlidx']), 'trl_indx_high', 'trl_indx_low'); 
%elseif strcmp(savewhat, 'source')
%    save(fullfile(savedir, 'source', [savename '_high']), 'source_high', 'inpcfg');
%    save(fullfile(savedir, 'source', [savename '_low']), 'source_low');
%else
%    save(savename, 'stat', 'inpcfg');
%    save(fullfile(savedir, 'source', [savename '_high']), 'source_high');
%    save(fullfile(savedir, 'source', [savename '_low']), 'source_low');
%end

end
