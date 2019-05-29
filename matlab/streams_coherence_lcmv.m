function streams_coherence_lcmv(subject, inputargs)
% streams_dics() performs epoching (1s), freqanalysis and source
% reconstruction on preprocessed data

%% INITIALIZE

% create variables from input argument options
dir             = ft_getopt(inputargs, 'datadir');
savedir         = ft_getopt(inputargs, 'savedir');
indepvar        = ft_getopt(inputargs, 'indepvar');
removeonset     = ft_getopt(inputargs, 'removeonset', 0);
shift           = ft_getopt(inputargs, 'shift', 0); 
word_selection  = ft_getopt(inputargs, 'word_selection', 'all');
roi             = ft_getopt(inputargs, 'roi');

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

%% LOAD

load(preprocfile);    % meg data, 'data' variable
load(headmodelfile);
load(leadfieldfile);
load(sourcemodelfile);
load(featurefile);
load(audiofile);

%% ADDITIONAL CLEANING STEPS, EPOCHING and BINNING

opt = {'save',              0, ...
       'language_features', [], ...
       'audio_features',    {'audio_avg'}, ...
       'contrastvars',      [], ...
       'removeonset',       removeonset, ...
       'shift',             shift, ...
       'epochlength',       4, ...
       'overlap',           0};
   
[~, data, ~, audio, ~] = streams_epochdefinecontrast(data, featuredata, audio, opt);

% to prevent ft_appenddata in l. 115 crash
audio.time    = data.time;
audio.fsample = data.fsample;

%% Timelock

dattmp              = data;
dattmp.time(1:end)  = data.time(1);

cfg            = [];
cfg.covariance = 'yes';

data_timelock  = ft_timelockanalysis(cfg, dattmp);

%% COMMON FILTER

cfg                     = []; 
cfg.method              = 'lcmv';
cfg.grid                = sourcemodel;
cfg.grid.leadfield      = leadfield.leadfield;
cfg.headmodel           = headmodel;
cfg.lcmv.projectnoise   = 'yes';
cfg.lcmv.lambda         = '100%';
cfg.lcmv.keepfilter     = 'yes';
cfg.lcmv.realfilter     = 'yes';
cfg.lcmv.fixedori       = 'yes';

source                  = ft_sourceanalysis(cfg, data_timelock);

%% MULTIPLY FILTER AND DATA

load /project/3011044.02/preproc/atlas/374/atlas_subparc374_8k.mat

% choose labels based on max coherence as shown by dics source localization
if strcmp(roi, 'dicsmax')
    dicsfile = fullfile('/project/3011044.02/analysis/coherence/source/subject', [subject '_6.mat']); 
    load(dicsfile); 
    
    llable = atlas.parcellationlabel(contains(atlas.parcellationlabel, 'L_'));
    llable = llable(~ismember(llable, {'R_MEDIAL.WALL_01', 'L_MEDIAL.WALL_01'}));
    lind = contains(atlas.parcellationlabel, llable);
    lparcind = ismember(atlas.parcellation, find(lind));
    
    rlable = atlas.parcellationlabel(contains(atlas.parcellationlabel, 'R_'));
    rlable = rlable(~ismember(rlable, {'L_MEDIAL.WALL_01', 'R_MEDIAL.WALL_01'}));
    rind   = contains(atlas.parcellationlabel, rlable);
    rparcind = ismember(atlas.parcellation, find(rind));
    
    [~, limax] = max(coh(lparcind));
    [~, rimax] = max(coh(rparcind));
    roiL = {atlas.parcellationlabel{atlas.parcellation(lparcind)}};
    roiR = {atlas.parcellationlabel{atlas.parcellation(rparcind)}};
    roiL = roiL(limax);
    roiR = roiR(rimax);
    
    roi  = [roiL, roiR];
    
    suffix = 'maxLR';
    clear coh
    
end

% choose labels defined in <roi> cell array ('_42' etc.)
parc_pos  = contains(atlas.parcellationlabel, roi); 
parc      = atlas.parcellationlabel(parc_pos);
parc_idx  = find(parc_pos);
vchan_pos = ismember(atlas.parcellation, parc_idx);

% make sure labels are ordered as in the parcellation scheme
label_idx                                   = {atlas.parcellation(vchan_pos)};
labels                                      = cell(numel(label_idx{:}), 1);

for k = 1:numel(parc_idx)
    labels(ismember(label_idx{:}, parc_idx(k))) = parc(k);  
end

for h = 1:numel(labels)
    labels{h} = [labels{h} '-' num2str(h)]; 
end

spatial_filter   = cat(1, source.avg.filter{vchan_pos});

sourcedata         = [];
sourcedata.time    = data.time;
sourcedata.label   = labels;
sourcedata.fsample = data.fsample;

for i = 1:numel(data.trial)

    sourcedata.trial{i} = spatial_filter * data.trial{i};
  
end

%% Append data

combineddata = ft_appenddata([], sourcedata, audio);

%% Coherence spectra

cfg            = [];
cfg.output     = 'fourier';
cfg.method     = 'mtmfft';
cfg.foilim     = [0 50];
cfg.tapsmofrq  = 1;
cfg.taper      = 'dpss';
freq           = ft_freqanalysis(cfg, combineddata);

freq           = ft_checkdata(freq,'cmbrepresentation','fullfast');

cfg            = [];
cfg.method     = 'coh';
coh            = ft_connectivityanalysis(cfg, freq);

%% SAVING 

savename = fullfile(savedir, [subject '_cohspectrum' '-' suffix]);
save(savename, 'coh', 'inputargs');

% pipelinesavename  = fullfile(savedir, ['pipeline' '_cohspectrum']);
% datecreated       = char(datetime('today', 'Format', 'dd-MM-yy'));
% pipelinefilename  = [pipelinesavename '_' datecreated];
% 
% if ~exist([pipelinefilename '.html'], 'file')
%      cfgt           = [];
%      cfgt.filename  = pipelinefilename;
%      cfgt.filetype  = 'html';
%      ft_analysispipeline(cfgt, coh);
% end


end