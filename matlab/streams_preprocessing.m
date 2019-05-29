function [data, eeg, audio, featuredata] = streams_preprocessing(subject, inpcfg)

% streams_preprocessing() 


% try whether this solves the problems with finding fftfilt when running it
% in a torque job
addpath('/opt/matlab/R2014b/toolbox/signal/signal');

%% INITIALIZE

if ischar(subject)
  subject = streams_subjinfo(subject);
end

% make a local version of the variable input arguments
bpfreq            = ft_getopt(inpcfg, 'bpfreq');
hpfreq            = ft_getopt(inpcfg, 'hpfreq');
lpfreq            = ft_getopt(inpcfg, 'lpfreq'); % before the post-envelope computation downsampling
dftfreq           = ft_getopt(inpcfg, 'dftfreq', [49 51; 99 101; 149 151]);
audiofile         = ft_getopt(inpcfg, 'audiofile', 'all');
fsample           = ft_getopt(inpcfg, 'fsample', 30);
dosns             = ft_getopt(inpcfg, 'dosns', 0);
dospeechenvelope  = ft_getopt(inpcfg, 'dospeechenvelope', 0);
bp_speechenvelope = ft_getopt(inpcfg, 'bp_speechenvelope', 0);
filter_audio      = ft_getopt(inpcfg, 'filter_audio', 'no');
feature           = ft_getopt(inpcfg, 'feature');
dofeature         = ft_getopt(inpcfg, 'dofeature', 0);
addnoise          = ft_getopt(inpcfg, 'addnoise', 0);
word_quantify     = ft_getopt(inpcfg, 'word_quantify', 'content_noonset');

%% check whether all required user specified input is there

if isempty(bpfreq) && isempty(hpfreq) 
  %error('no filter specified');
  usehpfilter = false;
  usebpfilter = false;
elseif isempty(bpfreq)
  usehpfilter = true;
  usebpfilter = false;
elseif isempty(hpfreq)
  usebpfilter = true;
  usehpfilter = false;
else
  error('both a highpassfilter and bandpassfilter cannot be specified');
end
if ~isempty(dftfreq)
  usebsfilter = true;
else
  usebsfilter = false;
end

% determine which audiofile(s) to use
if ischar(audiofile) && strcmp(audiofile, 'all')
  % use all 
  audiofile = subject.audiofile;
elseif ischar(audiofile)
  audiofile = {audiofile};
end

% determine the trials with which the audiofiles correspond
seltrl   = zeros(0,1);
selaudio = cell(0,1);
for k = 1:numel(audiofile)
  tmp = ~cellfun('isempty', strfind(subject.audiofile, audiofile{k}));
  if sum(tmp)==1
    seltrl   = cat(1,seltrl,find(tmp));
    selaudio = cat(1,selaudio,audiofile(k)); 
  else
    % file is not there
  end
end

% deal with more than one ds-directory per subject
if iscell(subject.dataset)
  dataset = cell(0,1);
  trl     = zeros(0,size(subject.trl{1},2));
  mixing  = cell(0,1);
  unmixing = cell(0,1);
  badcomps = cell(0,1);
  for k = 1:numel(subject.dataset)
    trl     = cat(1, trl, subject.trl{k});
    dataset = cat(1, dataset, repmat(subject.dataset(k), [size(subject.trl{k},1) 1])); 
    mixing    = cat(1, mixing,    repmat(subject.eogv.mixing(k), [size(subject.trl{k},1) 1]));
    unmixing  = cat(1, unmixing,  repmat(subject.eogv.unmixing(k), [size(subject.trl{k},1) 1]));
    badcomps  = cat(1, badcomps,  repmat(subject.eogv.badcomps(k), [size(subject.trl{k},1) 1]));
    
  end
  trl     = trl(seltrl,:);
  dataset = dataset(seltrl);
  mixing  = mixing(seltrl);
  unmixing = unmixing(seltrl);
  badcomps = badcomps(seltrl);
else
  dataset = repmat({subject.dataset}, [numel(seltrl) 1]);
  trl     = subject.trl(seltrl,:);
  mixing    = repmat({subject.eogv.mixing},   [numel(seltrl) 1]);
  unmixing  = repmat({subject.eogv.unmixing}, [numel(seltrl) 1]);
  badcomps  = repmat({subject.eogv.badcomps}, [numel(seltrl) 1]);

end

% in case dofeature is not specifified
if ~isempty(feature)
    dofeature = 1;
else
    featuredata = {}; % apparently output variables must be assigned
end

%% PREPROCESSING LOOP PER AUDIOFILE

audiodir                    = '/project/3011044.02/lab/pilot/stim/audio';
subtlex_table_filename      = '/project/3011044.02/raw/stimuli/worddata_subtlex.mat';
subtlex_firstrow_filename   = '/project/3011044.02/raw/stimuli/worddata_subtlex_firstrow.mat';
subtlex_data     = [];          % declare the variables, it throws a dynamic assignment error otherwise
subtlex_firstrow = [];

% load in the files that contain word frequency information
load(subtlex_firstrow_filename);
load(subtlex_table_filename);

for k = 1:numel(seltrl)
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  % MEG AND AUDIO DATA     %
  %%%%%%%%%%%%%%%%%%%%%%%%%% 
  
  [~,f,~] = fileparts(selaudio{k});

  cfg         = [];
  cfg.dataset = dataset{k};
  cfg.trl     = trl(k,:);
  cfg.trl(1,1) = cfg.trl(1,1) - 1200; % read in an extra second of data at the beginning
  cfg.trl(1,2) = cfg.trl(1,2) + 1200; % read in an extra second of data at the end
  cfg.trl(1,3) = -1200; % update the offset, to account for the padding
  cfg.channel  = 'MEG';
  cfg.continuous = 'yes';
  cfg.demean     = 'yes';
  
  % specify bandpas
  if usebpfilter
    cfg.bpfilter = 'yes';
    cfg.bpfreq   = bpfreq;
    cfg.bpfilttype = 'firws';
    cfg.usefftfilt = 'yes';
  end
  
  % specficy high pass
  if usehpfilter
    cfg.hpfilter = 'yes';
    cfg.hpfreq   = hpfreq;
    cfg.hpfilttype = 'firws';
    cfg.usefftfilt = 'yes';
  end
  
  % meg
  data           = ft_preprocessing(cfg); % read in the MEG data
  
  % eog channel
  cfg.channel = {'EEG057', 'EEG058', 'EEG059'};
  eeg        = ft_preprocessing(cfg);
  
  % audio channel
  if strcmp(filter_audio, 'no')
    cfg.bpfilter = 'no';
    cfg.hpfilter = 'no';
  end
  cfg.channel  = 'UADC004';
  audio        = ft_preprocessing(cfg); % read in the audio data
  
  %% AUDIO AVG
  if dospeechenvelope
      
      audio_orig = audio; % save the original audio channel from MEG
      
      wavfile = fullfile(audiodir, f, [f, '.wav']); % stimulus wavfile
      delay = subject.delay(seltrl(k))./1000;

      audio = streams_broadbandenvelope(audio_orig, wavfile, delay);
        
      if bp_speechenvelope
          
          cfg = [];
          cfg.channel = 'audio_avg';
          audio_avg = ft_selectdata(cfg, audio);
          
          cfg            = [];
          cfg.channel    = 'audio_avg';
          cfg.bpfilter   = 'yes';
          cfg.bpfreq     = bpfreq;
          cfg.bpfilttype = 'firws';
          cfg.usefftfilt = 'yes';

          audio = ft_preprocessing(cfg, audio);
          audio.label = {'audio_avg_bp'};
          
          audio = ft_appenddata([], audio, audio_avg);
          
      end
      
  end

%% BANDSTOP FILTERING FOR LINE NOISE

  if usebsfilter
    cfg = [];
    cfg.bsfilter = 'yes';
    for kk = 1:size(dftfreq,1)
      cfg.bsfreq = dftfreq(kk,:);
      data    = ft_preprocessing(cfg, data);
    end
  end
  
%% ARTIFACT REJECTION
  
  % reject muscle & SQUID artifacts
  cfg                  = [];
  cfg.artfctdef        = subject.artfctdef;
  cfg.artfctdef.reject = 'partial';
  cfg.artfctdef.minaccepttim = 2;
  data        = ft_rejectartifact(cfg, data);
  eeg         = ft_rejectartifact(cfg, eeg);
  audio       = ft_rejectartifact(cfg, audio);
  
  % sensor noise suppression
  if dosns
    fprintf('doing sensor noise suppression\n');
  
    addpath('/home/language/jansch/matlab/fieldtrip/denoise_functions');
    cfg             = [];
    cfg.nneighbours = 50;
    cfg.truncate    = 40;
    data            = ft_denoise_sns(cfg, data);
  end

  
%% LOW PASS FILTERING
  
  if ~isempty(lpfreq)
    cfg = [];
    cfg.lpfreq = lpfreq;
    cfg.lpfilter = 'yes';
    cfg.lpfilttype = 'firws';
    cfg.usefftfilt = 'yes';
    data = ft_preprocessing(cfg, data);
    eeg = ft_preprocessing(cfg, eeg);
  end
  
  %% RESAMPLING
  
  if fsample < 1200
    
    % subtract first time point for memory purposes
    for kk = 1:numel(data.trial)
      firsttimepoint(kk,1) = data.time{kk}(1);
      data.time{kk}        = data.time{kk}-data.time{kk}(1);
      eeg.time{kk}         = eeg.time{kk}-eeg.time{kk}(1);
      audio.time{kk}       = audio.time{kk}-audio.time{kk}(1);
    end
    
    cfg = [];
    cfg.demean  = 'no';
    cfg.detrend = 'no';
    cfg.resamplefs = fsample;
    data        = ft_resampledata(cfg, data);
    eeg         = ft_resampledata(cfg, eeg);
    audio       = ft_resampledata(cfg, audio);
    
    % add back the first time point, so that the relative time axis
    % corresponds again with the timing in combineddata
    for kk = 1:numel(data.trial)
      data.time{kk}  = data.time{kk} + firsttimepoint(kk);
      eeg.time{kk}   = eeg.time{kk} + firsttimepoint(kk);
      audio.time{kk} = audio.time{kk} + firsttimepoint(kk);
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  % LANGUAGE PREPROCESSING %
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  if dofeature
  
      % create combineddata data structure
      dondersfile  = fullfile(audiodir, f, [f,'.donders']);
      textgridfile = fullfile(audiodir, f, [f,'.TextGrid']);
      combineddata = combine_donders_textgrid(dondersfile, textgridfile);

      % Compute word duration
      for i = 1:numel(combineddata)
        
        if ~isempty(combineddata(i).start_time)
            combineddata(i).duration = combineddata(i).end_time - combineddata(i).start_time;
        else
            combineddata(i).duration = nan;
        end
      end
      
      % add .iscontent field to combineddata structure
      combineddata = streams_combinedata_iscontent(combineddata);
      
      % add subtlex frequency info and word length
      combineddata = add_subtlex(combineddata, subtlex_data,  subtlex_firstrow);

      % create language predictor based on language model output
      if iscell(feature)
        
        featuredata = cell(1, numel(feature));
        for m = 1:numel(feature)
          featuredata{m} = create_featuredata(combineddata, feature{m}, data, addnoise, word_quantify);
        end

        featuredata = ft_appenddata([], featuredata{:});

      else

        % single feature
        featuredata = create_featuredata(combineddata, feature, data, addnoise, word_quantify);

      end
      
  end
  % add to structs for outputting
  if dofeature
    tmpfeature{k}  = featuredata;
  end
  tmpdata{k}  = data;
  tmpeeg{k}   = eeg;
  tmpaudio{k} = audio;
  clear data eeg audio;
  
end

%% APPENDING FOR OUPUT

if numel(tmpdata) > 1
    
  data        = ft_appenddata([], tmpdata{:});
  eeg         = ft_appenddata([], tmpeeg{:});
  audio       = ft_appenddata([], tmpaudio{:});
  
  if dofeature
    featuredata     = ft_appenddata([], tmpfeature{:});
  end
  
else
    
  data        = tmpdata{1};
  eeg         = tmpeeg{1};
  audio       = tmpaudio{1};
  
  if dofeature
    featuredata     = tmpfeature{1};
  end
  
end
clear tmpdata tmpaudio tmpeeg tmpfeature

%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS           %
%%%%%%%%%%%%%%%%%%%%%%%%%%

% COMUPTING SUMMED AVERAGE SPEECH ENVELOPE
function out = streams_broadbandenvelope(audio, wavfile, delay)

  % now we get the audio signal from the wavfile, at the same Fs as the
  % MEG, and for now we are going to use the 'audio_avg signal'
  audio_broadband       = streams_wav2mat(wavfile);
  
  % first we are going to shift the time axis as bit, as specified in the
  % precomputed delays.
  audio_broadband.time{1} = audio_broadband.time{1} + delay;
  
  i1 = nearest(audio.time{1}, audio_broadband.time{1}(1));
  i2 = nearest(audio.time{1}, audio_broadband.time{1}(end));
  i3 = nearest(audio_broadband.time{1}, audio.time{1}(1));
  i4 = nearest(audio_broadband.time{1}, audio.time{1}(end));
  
  % add the correctly aligned average envelope signal to the 'audio' data structure
  audio.trial{1}(2,:) = 0;
  audio.trial{1}(3,:) = 0;
  
  avg_ind = find(all(ismember(audio_broadband.label, 'audio_avg'), 2)); % find index of 'audio_avg' in audio_wav.label
  aud_ind = find(all(ismember(audio_broadband.label, 'audio'), 2)); % find index of 'audio' channel in audio_wav.label
  
  audio.trial{1}(2, i1:i2) = audio_broadband.trial{1}(avg_ind, i3:i4); % assign audio_avg channel
  audio.trial{1}(3, i1:i2) = audio_broadband.trial{1}(aud_ind, i3:i4); % assign audio channel
  audio.label(2, 1) = audio_broadband.label(avg_ind); %add label as well
  audio.label(3, 1) = audio_broadband.label(aud_ind);
  
  out = audio;
end

% ADD SUBTLEX INFORMATION 
function [combineddata] = add_subtlex(combineddata, subtlex_data, subtlex_firstrow)

num_words = size(combineddata, 1);

word_column         = strcmp(subtlex_firstrow, 'spelling');
wlen_column         = strcmp(subtlex_firstrow, 'nchar');
frequency_column    = strcmp(subtlex_firstrow, 'Lg10WF');

subtlex_words = subtlex_data(:, word_column);

    % add frequency information to combineddata structure
    for j = 1:num_words

        word = combineddata(j).word;
        word = word{1};
        row = find(strcmp(subtlex_words, word)); % find the row index in subtlex data

        if ~isempty(row) 
            
             combineddata(j).log10wf = subtlex_data{row, frequency_column}; % lookup the according frequency values
             combineddata(j).nchar   = subtlex_data{row, wlen_column};
             
        else % write 'nan' if it is a punctuation mark or a proper name (subtlex doesn't give values in this case)
            
            combineddata(j).log10wf = nan;
            combineddata(j).nchar   = nan;
            
        end

    end
    
end

% Create box-shape predictors 
function [featuredata] = create_featuredata(combineddata, feature, data, addnoise, select)

% create FT-datastructure with the feature as a channel
[time, featurevector] = get_time_series(combineddata, feature, data.fsample, select);

if addnoise
  
  steps = unique(featurevector);
  steps_sel = isfinite(steps);  % indicate all non-Nan values
  steps = steps(steps_sel);     % select all non-Nan values
  steps = steps(find(steps));   % select all non-zero values
  
  range = 0.1*min(diff(steps));
  num_samples = size(featurevector, 2);

  noise = range.*rand(1, num_samples);
  noise(~isfinite(featurevector)) = NaN;
  featurevector = featurevector + noise;

end
  
featuredata   = ft_selectdata(data, 'channel', data.label(1)); % ensure that it only has 1 channel
featuredata.label{1} = feature;
for kk = 1:numel(featuredata.trial)
  if featuredata.time{kk}(1)>=0
    begsmp1 = 1;
    begsmp2 = nearest(time, featuredata.time{kk}(1));
    
    endsmp1 = min(numel(featuredata.time{kk}), numel(featurevector)-begsmp2+1);
    endsmp2 = endsmp1-begsmp1+begsmp2;
  else
    begsmp1 = nearest(data.time{kk},0);
    begsmp2 = 1;
  
    endsmp2 = min(numel(featuredata.time{kk})-begsmp1+1, numel(featurevector));
    endsmp1 = endsmp2-begsmp2+begsmp1;
  end
  featuredata.trial{kk}(:) = nan;
  featuredata.trial{kk}(begsmp1:endsmp1) = featurevector(begsmp2:endsmp2);
end
end

end
 