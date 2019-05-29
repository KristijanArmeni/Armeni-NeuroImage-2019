function [avgfeature, data, featuredata, audio, split] = streams_epochdefinecontrast(data, featuredata, audio, opt)
%
% streams_definecontrast() averages language data from featuredata
% obtained from streams_preprocessing() and computes tertile split
% for entropy, perplexity and word frequency. It saves the ouput to:
% '/project/3011044.02/analysis/lng-contrast/'
%

%% INITIALIZE 

%altmean           = ft_getopt(opt, 'altmean', 0);
language_features = ft_getopt(opt, 'language_features');
audio_features    = ft_getopt(opt, 'audio_features');
contrastvars      = ft_getopt(opt, 'contrastvars');
removeonset       = ft_getopt(opt, 'removeonset', 0);
shift             = ft_getopt(opt, 'shift', 0);          % in miliseconds
epochtype         = ft_getopt(opt, 'epochtype'); 
epochlength       = ft_getopt(opt, 'epochlength', 1);    % integer, seconds, the amount of semgent length
overlap           = ft_getopt(opt, 'overlap', 0);

% some data structures do not have .fsample field, I reconstruct it for now from
if ~isfield(data, 'fsample')    
    data.fsample = round(data.cfg.previous{1}.resamplefs);
end

%% NORMALIZE THE AUDIO CHANNEL DATA per story

% select auditory envelope channel
cfg         = [];
cfg.channel = audio_features{1};
audio       = ft_selectdata(cfg, audio);

stories = audio.trialinfo(diff([0;audio.trialinfo])~=0); % select unique story IDs
tmpaudio = cell(1, numel(stories));

for kk = 1:numel(stories)
  
  cfg  = [];
  cfg.trials   = find(audio.trialinfo == stories(kk));
  tmpaudio{kk} = ft_selectdata(cfg, audio); % select only a single story
  
  cfg2 = [];
  cfg2.demean = 'no';
  tmpaudio{kk} = ft_channelnormalise(cfg2, tmpaudio{kk});

end

audio = ft_appenddata([], tmpaudio{:});

%% REMOVE SHORT DATA EPOCHS PRIOR TO SHIFTING
sr         = round(data.fsample); % sometimes data.fsample is 300.000
shift_size = shift/1000;      % express msec shift size relatively
shift_sr   = sr * shift_size; % shift expressed in the number of samples

% check whether there the epochs are at least twice the sampling rate in length
trlsel = logical(cell2mat(cellfun(@(x) numel(x) > 2*sr, data.time(:), 'UniformOutput', 0)));

% if there are epochs < 2*sr, leave them out at this step (regardless of shift value)
if ~all(trlsel)  
    cfg         = [];
    cfg.trials  = trlsel;

    data        = ft_selectdata(cfg, data);
    audio       = ft_selectdata(cfg, audio);
    featuredata = ft_selectdata(cfg, featuredata);
end

%% ADD PER TRIAL TIME SHIFT TO THE DATA

num_trl = numel(data.trial);

if shift > 0

    for ii = 1:num_trl

        new_onset = shift_sr + 1;                  % sample index that represents the new onset

        data.trial{ii} = data.trial{ii}(:, new_onset:end); % selectdata from the new index to the end
        data.time{ii}  = data.time{ii}(:, new_onset:end);
        
        num_smpl = numel(featuredata.time{ii});
        cut_tail              = num_smpl-shift_sr;   % sample number to cut the left over featuredata at
        featuredata.trial{ii} = featuredata.trial{ii}(:, 1:cut_tail); % discard feature data at the end
        featuredata.time{ii}  = featuredata.time{ii}(:, 1:cut_tail);

        audio.trial{ii} = audio.trial{ii}(:, 1:cut_tail);   
        audio.time{ii}  = audio.time{ii}(:, 1:cut_tail);
            
    end
    
end 

%% EPOCH FEATURE and MEG DATA

% Configure cfg based on type of desired epoching
switch epochtype
    
    case 'onset-ignore'
      % old behaviour: just torpedoeing the exhaust fumes of cortical
      % computation
      
      cfg         = [];
      cfg.length  = epochlength;
      cfg.overlap = overlap;
      
    case 'onset-lock'
      % identify the word onsets, and define the epochs to start at the word
      % onset (resulting in overlapping data, but that's how it is)

      for ii = 1:numel(featuredata.trial)
        sel = match_str(featuredata.label, 'word_');  % take word index
        tmp = featuredata.trial{ii}(sel,:);
        tmp(~isfinite(tmp)) = 0;
        dtmp = [0 diff(tmp)>0];                       % use non-negative diffs
        delta{ii,1} = find(dtmp);
      end

      data = ft_checkdata(data, 'hassampleinfo', 'yes');
      newtrl = zeros(0,3);
      
      for ii = 1:numel(data.trial)
          
        tmpdelta    = delta{ii}(:);
        tmpdelta(tmpdelta+round(data.fsample.*epochlength)>size(data.trial{ii},2)) = [];
        tmptrl(:,1) = tmpdelta+data.sampleinfo(ii,1)-1;
        tmptrl(:,2) = tmptrl(:,1)+round(data.fsample.*epochlength)-1;
        tmptrl(:,3) = 0;

        newtrl = cat(1,newtrl,tmptrl);
        clear tmptrl;
      
      end

      cfg = [];
      cfg.trl = newtrl;

    case 'onset-lock-nooverlap'
      % identify the word onsets, and define the epochs to start at the word
      % onset (resulting in overlapping data, but that's how it is)

      for ii = 1:numel(featuredata.trial)
        sel = match_str(featuredata.label, 'word_');  % take word index
        tmp = featuredata.trial{ii}(sel,:);
        tmp(~isfinite(tmp)) = 0;
        dtmp = [0 diff(tmp)>0];                       % use non-negative diffs
        delta{ii,1} = find(dtmp);
      end

      data = ft_checkdata(data, 'hassampleinfo', 'yes');
      newtrl = zeros(0,3);
      
      for ii = 1:numel(data.trial)
          
        tmpdelta    = delta{ii}(:);
        keep = tmpdelta+round(data.fsample.*epochlength) < size(data.trial{ii},2);
        if all(~keep)
            continue
        elseif any(keep)
            
            tmpdelta(~keep) = [];
        
            newtmpdelta = tmpdelta(1);
            for iii = 2:numel(tmpdelta)
              if tmpdelta(iii)>newtmpdelta(end)+round(epochlength.*data.fsample)
                  newtmpdelta(end+1,1) = tmpdelta(iii);
              end
            end
        
            tmptrl(:,1) = newtmpdelta+data.sampleinfo(ii,1)-1;
            tmptrl(:,2) = tmptrl(:,1)+round(data.fsample.*epochlength)-1;
            tmptrl(:,3) = 0;

            newtrl = cat(1,newtrl,tmptrl);
            clear tmptrl;
        end
      end
      
      cfg = [];
      cfg.trl = newtrl;
      
    case 'onset-lock-minoverlap'
      % identify the word onsets, and define the epochs to start at the word
      % onset and allow for 20 % overlap

      for ii = 1:numel(featuredata.trial)
        sel = match_str(featuredata.label, 'word_');  % take word index
        tmp = featuredata.trial{ii}(sel,:);
        tmp(~isfinite(tmp)) = 0;
        dtmp = [0 diff(tmp)>0];                       % use non-negative diffs
        delta{ii,1} = find(dtmp);
      end

      data = ft_checkdata(data, 'hassampleinfo', 'yes');
      newtrl = zeros(0,3);
      
      for ii = 1:numel(data.trial)
          
        tmpdelta    = delta{ii}(:);
        keep = tmpdelta+round(data.fsample.*epochlength) < size(data.trial{ii},2);
        if all(~keep)
            continue
        elseif any(keep)
            
            tmpdelta(~keep) = [];
        
            newtmpdelta = tmpdelta(1);
            for iii = 2:numel(tmpdelta)
              if tmpdelta(iii)>newtmpdelta(end)+round(epochlength.*data.fsample)*0.8
                  newtmpdelta(end+1,1) = tmpdelta(iii);
              end
            end
        
            tmptrl(:,1) = newtmpdelta+data.sampleinfo(ii,1)-1;
            tmptrl(:,2) = tmptrl(:,1)+round(data.fsample.*epochlength)-1;
            tmptrl(:,3) = 0;

            newtrl = cat(1,newtrl,tmptrl);
            clear tmptrl;
        end
      end
      
      cfg = [];
      cfg.trl = newtrl;
      
end

featuredata = ft_redefinetrial(cfg, featuredata);
data        = ft_redefinetrial(cfg, data);
audio       = ft_redefinetrial(cfg, audio);

%% ADHOC TRIAL REMOVAL

sel          = streams_cleanadhoc(data); % select trials with high variance (as was done for freqanalysis

cfg          = [];
cfg.trials   = sel; % make sure featuredata has the same trials as MEG data

featuredata  = ft_selectdata(cfg, featuredata);
data         = ft_selectdata(cfg, data);         
audio        = ft_selectdata(cfg, audio);

%% REMOVE ONSET TRIALS

if removeonset

    word_nr_chan = strcmp(featuredata.label, 'word_');

    word_idx    = cellfun(@(x) x(word_nr_chan,:), featuredata.trial(:), 'UniformOutput', 0); % select word_ channel
    word_idx_un = cellfun(@unique , word_idx, 'UniformOutput', 0);                           % get unique word index values                 

    criterion = 1; % numbering starts at 0, so this excludes all epochs containting at least first 2 words
    trl_sel   = ~logical(cell2mat(cellfun(@(x) any(x <= criterion), word_idx_un, 'UniformOutput', 0))); % keep trials without sentence onsets

    cfg          = [];
    cfg.trials   = trl_sel; 

    featuredata  = ft_selectdata(cfg, featuredata);
    data         = ft_selectdata(cfg, data);         
    audio        = ft_selectdata(cfg, audio);

end
%% AVERAGE FEATURE
if ~isempty(language_features) % do averaging and nan removal only if features are specified
    
    % put average feature information into .trialinfo and labels into .trialinfolabel
    featuredata       = streams_averagefeature(featuredata, language_features);
    audio             = streams_averagefeature(audio, audio_features);

    % append together

    data.fsample        = sr; % this is needed for s14 and s28
    featuredata.fsample = sr;
    audio.time          = featuredata.time; % make time info the same else appenddata fails
    audio.fsample       = sr;

    avgfeature             = ft_appenddata([], featuredata, audio);

    % add averaging information back in
    audio_col = strcmp(audio.trialinfolabel, audio_features);

    avgfeature.trialinfo      = [featuredata.trialinfo, audio.trialinfo(:, audio_col)];
    avgfeature.trialinfolabel = [featuredata.trialinfolabel; audio.trialinfolabel(audio_col)];

    %% REMOVE NAN TRIALS

    selected_column = strcmp(avgfeature.trialinfolabel, 'log10wf'); % this column is used as a confound and must not have Nans
    trialskeep      = logical(~isnan(avgfeature.trialinfo(:, selected_column))); % keep only non-nan trials

    trialinfolabel = avgfeature.trialinfolabel; % store this because ft_selectdata below discards it

    cfg         = [];
    cfg.trials  = trialskeep;

    data        = ft_selectdata(cfg, data);
    featuredata = ft_selectdata(cfg, featuredata);
    audio       = ft_selectdata(cfg, audio);
    avgfeature  = ft_selectdata(cfg, avgfeature); % this also removes Nans in .trialinfo cells with lex. freq. info (needed for ft_regressconfound)

    avgfeature.trialinfolabel = trialinfolabel; % plug trialinfolabel back in
else
    
    avgfeature = [];
    
end
%% DO THE TERTILE SPLIT

if ~isempty(contrastvars)

    for i = 1:numel(contrastvars)

        indepvarsel = contrastvars{i};

        % determine quantile range for split based on the measure
        if strcmp(indepvarsel, 'word_')
            quantile_range = [0.33 0.66];
        else
            quantile_range = [0.33 0.66];
        end

        % do the split
        split(i) = streams_split(avgfeature, indepvarsel, quantile_range);

    end

else
    
    split = [];
    
end
%% SUBFUNCTIONS

function split = streams_split(datain, indepvarsel, quantile_range)
           
    col_indepvar = strcmp(datain.trialinfolabel(:), indepvarsel);
    indepvar     = datain.trialinfo(:, col_indepvar); % pick the appropriate language variable (mean complexity for each trial)

    % find channel index
    q            = quantile(indepvar, quantile_range); % extract the two quantile values
    low_tertile  = q(1);
    high_tertile = q(2);

    % split into high and low tertile groups
    trl_indx_low  = indepvar < low_tertile; % this gives a logical vector
    trl_indx_high = indepvar > high_tertile; 

    % create the contrast structure
    split.indepvar     = indepvarsel;
    split.quantrange   = quantile_range;
    split.quantdvalue  = [low_tertile, high_tertile];
    split.label        = {'low', 'high'};
    split.trial        = [trl_indx_low, trl_indx_high];

    % do the prunned contrast
    sel_column   = strcmp(datain.trialinfolabel, 'numNan');
    threshold    = 0.30;
    total_points = numel(datain.time{1}); % depends on epoching and sampling rate

    prunned_trls     = round(datain.trialinfo(:, sel_column)./total_points, 2) < threshold; % snippets with less than 0.30 % nans
    indepvar_prunned = datain.trialinfo(prunned_trls, col_indepvar); % pick the appropriate language variable and snippets

    q = quantile(indepvar_prunned, quantile_range); % extract the new quantile values based only on snippets with < threshold nans
    low_tertile_2  = q(1);
    high_tertile_2 = q(2);

    trl_indx_low2   = all([prunned_trls, indepvar < low_tertile_2], 2);  % select 0.3 < NaN high complexity trials
    trl_indx_high2  = all([prunned_trls, indepvar > high_tertile_2], 2); % select 0.3 < NaN low complexity trials
    
    split.quantvalue2  = [low_tertile_2, high_tertile_2];
    split.label2       = {'low2', 'high2'};
    split.trial2       = [trl_indx_low2, trl_indx_high2];



function dataout = streams_averagefeature(datain, selected_features)
% streams_averagefeature() takes the output of
% streams_preprocessing.m (featuredata struct) and averages single trial values

dataout                      = rmfield(datain, 'trialinfo');
dataout.trialinfolabel{1, 1} = 'trialnr';                  % this is the preprocessed trialinfo
dataout.trialinfo(:, 1)      = datain.trialinfo;           % assign trial numbers
num_features_pre             = size(dataout.trialinfo, 2); % store the number of features already assigned

    % average entropy, perplexity and audio lex. freq.
    for k = 1:numel(selected_features)

        feature   = selected_features{k};
        chan_indx = strcmp(datain.label, feature); % find the correct index

        tmp = cellfun(@(x) x(chan_indx,:), datain.trial(:), 'UniformOutput', 0); % choose the correct row in every cell
        
        if strcmp(feature, 'word_') % take mode for word index
        
           dataout.trialinfo(:, num_features_pre + k)      = cellfun(@mode, tmp(:)); % take the mode
           dataout.trialinfolabel{k + num_features_pre, 1} = feature;
       
        else % mean, weighted by word's duration
            
            % switch epochtype
            % case 'onset-ignore'
            dataout.trialinfo(:, num_features_pre + k)       = cellfun(@nanmean, tmp(:)); % take the mean, ignoring nans
            dataout.trialinfolabel{num_features_pre + k, 1} = feature;
                %case 'onset-lock'
%                     t = cellfun(@(x) unique(x(:), 'stable'), tmp(:), 'UniformOutput', 0); % extract unique values in original order
%                     t2 = cellfun(@(x) x(~isnan(x)), t(:), 'UniformOutput', 0);            % consider only non-nan values
%                     for i = 1:numel(t2)
%                        if isempty(t2{i})
%                            t2{i} = nan;  % write back a NaN if there were no ~Nan values to begin with
%                        end
%                     end
%                     dataout.trialinfo(:, num_features_pre + k) = cell2mat(cellfun(@(x) x(1), t2(:), 'UniformOutput', 0)); % grab the first value only
%                     dataout.trialinfolabel{num_features_pre + k, 1} = feature;
            %end
        end
        
    end
      
    total_columns = numel(dataout.trialinfolabel);
    
    % add information about the number of nan's
    dataout.trialinfo(:, total_columns + 1)       = cellfun(@(x) sum(isnan(x)), tmp(:));
    dataout.trialinfolabel{total_columns + 1, 1}  = 'numNan';
    
    clear tmp
    
