function streams_coherence_dics(subject, inputargs)
% streams_dics() performs epoching (1s), freqanalysis and source
% reconstruction on preprocessed data

%% INITIALIZE

% create variables from input argument options
dir             = ft_getopt(inputargs, 'datadir');
savedir         = ft_getopt(inputargs, 'savedir');
indepvar        = ft_getopt(inputargs, 'indepvar');
removeonset     = ft_getopt(inputargs, 'removeonset', 0);
shift           = ft_getopt(inputargs, 'shift', 0);
freqband        = ft_getopt(inputargs, 'freqband');  
word_selection  = ft_getopt(inputargs, 'word_selection', 'all');
docontrast      = ft_getopt(inputargs, 'docontrast', 'no');

% determine what predictor to load
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

% determine 'foi' for ft_freqstatistics
switch freqband
    case 'delta',     foilim = [2 2];
    case 'theta',     foilim = [6 6];
    case 'alpha',     foilim = [10 10];
    case 'beta',      foilim = [16 16];
    case 'high-beta', foilim = [26 26];
    case 'gamma',     foilim = [45 45];
    case 'high-gamma',foilim = [75 75];
end

% condition taper and smoothing paramteres on the frequency of interest
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
load(featurefile);
load(audiofile);

%% ADDITIONAL CLEANING STEPS, EPOCHING and BINNING

opt = {'save',              0, ...
       'altmean',           0, ...
       'language_features', {'log10wf' 'perplexity', 'entropy'}, ...
       'audio_features',    {'audio_avg'}, ...
       'contrastvars',      {indepvar}, ...
       'removeonset',       removeonset, ...
       'shift',             shift, ...
       'epochlength',       0.5, ...
       'overlap',           0};
   
[~, data, ~, audio, contrast] = streams_epochdefinecontrast(data, featuredata, audio, opt);

% combine the data

% somewhere in the pipelines something goes wrong with .time numericla preciscion, this is a pedestrian way
% of correcting it
try 
    datac            = ft_appenddata([], data, audio); 
catch ME
    if  strcmp(ME.message, 'cannot append this data') && ...
        strcmp(lastwarn, 'correcting numerical inaccuracy in the time axes')
    
        audio.time = data.time;
        datac      = ft_appenddata([], data, audio);
    end
end

datac.grad = data.grad;
clear data audio

%% GET COMPLEX REPRESENTATION

cfg = [];
cfg.method        = 'mtmfft';
cfg.output        = 'fourier';
cfg.keeptrials    = 'yes';
cfg.taper         = taper; % hanning

if strcmp(taper, 'dpss')
    cfg.tapsmofrq = tapsmooth;
end

cfg.foilim        = foilim; 

freq = ft_freqanalysis(cfg, datac);

%% SPLIT DATA

if strcmp(docontrast, 'yes')
    
    % use the 'contrast' struct, computed in streams_epochdefinecontrast()
    ivarsel     = strcmp({contrast.indepvar}, indepvar); % use the correct struct dimeension
    contrastsel = contrast(ivarsel);                    % chose a subset of the struct array

    low_column  = strcmp(contrastsel.label, 'low');
    high_column = strcmp(contrastsel.label, 'high');

    trl_indx_low  = contrastsel.trial(:, low_column);  % select non-NaN high complexity trials
    trl_indx_high = contrastsel.trial(:, high_column); % select non-NaN low complexity trials

    % select data
    cfg        = [];
    cfg.trials = trl_indx_low;
    freq_low   = ft_selectdata(cfg, freq);

    cfg        = [];
    cfg.trials = trl_indx_high;
    freq_high  = ft_selectdata(cfg, freq);
    clear contrast
    
end

%% COMMON FILTER

cfg                     = []; 
cfg.method              = 'dics';
cfg.frequency           = foilim(1);  
cfg.grid                = sourcemodel;
cfg.grid.leadfield      = leadfield.leadfield;
cfg.headmodel           = headmodel;
cfg.refchan             = 'audio_avg';
%cfg.keeptrials         = 'yes';
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '100%';
cfg.dics.keepfilter     = 'yes';
cfg.dics.realfilter     = 'yes';
cfg.dics.fixedori       = 'yes';

source       = ft_sourceanalysis(cfg, ft_checkdata(freq,'cmbrepresentation','fullfast')); % trick to speed up the computation
%F           = cat(1,source_both.avg.filter{source_both.inside}); % common spatial filters per location

%%
% get the cross-spectrum per condition
inside_indx = find(source.inside);
switch docontrast    
    
    case 'no' % just overall coherence (no spliting)
   
        freq = ft_checkdata(freq, 'cmbrepresentation', 'fullfast');
        coh  = zeros(1, numel(inside_indx));
    
        for k = inside_indx(:)'

            Ftmp   = blkdiag(source.avg.filter{k}, 1);

            % compute the 2x2 csd matrix
            csdtmp      = Ftmp*freq.crsspctrm*Ftmp';
            coh(k)      = abs(csdtmp(1,2))./sqrt(abs(csdtmp(1,1))*abs(csdtmp(2,2)));

        end
        
    case 'yes'
        
        freq_high = ft_checkdata(freq_high, 'cmbrepresentation', 'fullfast');
        freq_low  = ft_checkdata(freq_low, 'cmbrepresentation', 'fullfast');
        
        coh_high = zeros(1, numel(inside_indx));
        coh_low  = zeros(1, numel(inside_indx));
    
        % compute coherence value per each vertex in the cortical sheet
        for k = inside_indx(:)'

            Ftmp   = blkdiag(source.avg.filter{k}, 1);

            % compute the 2x2 csd matrix
            csdtmp_high = Ftmp*freq_high.crsspctrm*Ftmp'; 
            csdtmp_low  = Ftmp*freq_low.crsspctrm*Ftmp';

            coh_high(k) = abs(csdtmp_high(1,2))./sqrt(abs(csdtmp_high(1,1))*abs(csdtmp_high(2,2)));
            coh_low(k)  = abs(csdtmp_low(1,2))./sqrt(abs(csdtmp_high(1,1))*abs(csdtmp_high(2,2)));

        end
        
        % COHERENCE Z-STATISTIC
        % Following eq(1) in Maris et al, 2007, Nonparametric statistical testing of coherence differences

        % atang transformation
        coh_high = atanh(coh_high);
        coh_low  = atanh(coh_low);

        % condition specific degrees of freedom
        dfhigh = 1./(2*sum(trl_indx_high) - 2);
        dflow  = 1./(2*sum(trl_indx_low) - 2);

        % subtract degrees of freedom
        coh_high = coh_high - dfhigh;
        coh_low  = coh_low - dflow;

        % divide by joint df
        jointdf  = sqrt(dfhigh + dflow);
        coh_low  = coh_low./jointdf;
        coh_high = coh_high./jointdf;

        % subtract
        cohdif = coh_high - coh_low;
        
end

clear source freq

%% SAVING 

dicsfreq           = num2str(foilim(1));

switch docontrast
    case 'no'
        savename = fullfile(savedir, [subject '_' dicsfreq]);
        save(savename, 'coh', 'inputargs');
        %pipelinesavename = fullfile(savedir, ['pipeline' '_' dicsfreq]);
    case 'yes'
        savename  = fullfile(savedir, [subject '_' indepvar '_' dicsfreq]);
        save(savename, 'cohdif', 'inputargs');
        %pipelinesavename = fullfile(savedir, ['pipeline_' indepvar '_' dicsfreq]);
end

% datecreated        = char(datetime('today', 'Format', 'dd-MM-yy'));
% pipelinefilename   = [pipelinesavename '_' datecreated];
% 
% if ~exist([pipelinefilename '.html'], 'file')
%      cfgt           = [];
%      cfgt.filename  = pipelinefilename;
%      cfgt.filetype  = 'html';
%      ft_analysispipeline(cfgt, stat);
% end


end