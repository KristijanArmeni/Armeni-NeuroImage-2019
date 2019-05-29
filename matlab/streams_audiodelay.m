function delay = streams_audiodelay(subject, audiofile)

% STREAMS_AUDIODELAY computes the delay between the actual sending of the
% trigger and the onset of the audio based on the slope of the phase
% difference spectrum.
%
% Use as
%   delay = streams_audiodelay(subject, audiofile)

[status, filename] = streams_existfile([subject.name,'_delay.mat']);
if status
  load(filename);
else
  
  if nargin==1
    fprintf('computing audio delay for subject %s\n', subject.name);

    delay = zeros(numel(subject.audiofile),1);
    for k = 1:numel(subject.audiofile)
      if iscell(subject.dataset)
        % data is in more than one file
        ntrlperdataset = cellfun('size',subject.trl,1);
        indx = zeros(0,2);
        cnt  = 0;
        for m = 1:numel(ntrlperdataset)
          indx(cnt+(1:ntrlperdataset(m)),1) = m;
          indx(cnt+(1:ntrlperdataset(m)),2) = 1:ntrlperdataset(m);
          cnt = size(indx,1);
        end
        tmpsubject = subject;
        tmpsubject.dataset = subject.dataset{indx(k,1)};
        tmpsubject.trl     = nan+zeros(numel(subject.audiofile),4);
        tmpsubject.trl(k,:) = subject.trl{indx(k,1)}(indx(k,2),:);
        delay(k,1) = streams_audiodelay(tmpsubject, tmpsubject.audiofile{k});
      else
        % normal case
        delay(k,1) = streams_audiodelay(subject, subject.audiofile{k});
      end
    end
    filename = fullfile('/project/3011044.02/preproc/meg', [subject.name,'_delay.mat']);
    save(filename, 'delay');
    return;
  end
  
  sel = find(strcmp(subject.audiofile, audiofile));
  if isempty(sel)
    error(sprintf('the audiofile %s is not present in the dataset',audiofile));
  end
  
  cfg = [];
  cfg.dataset = subject.dataset;
  cfg.trl     = subject.trl(sel,:);
  cfg.channel = {'UADC003'};
  cfg.continuous = 'yes';
  cfg.bsfilter = 'yes';
  cfg.bsfreq   = [49 51;99 101;149 151;199 201];
  data = ft_preprocessing(cfg);
  
  [p,f,e] = fileparts(audiofile);
  matfile = fullfile(subject.audiodir, f, [f '.mat']);
  load(matfile);
  
  audio = ft_selectdata(audio, 'channel', audio.label(1));
  nsmp1 = numel(audio.time{1});
  nsmp2 = numel(data.time{1});
  nsmp  = min(nsmp1,nsmp2);
  
  audio.trial{1} = audio.trial{1}(:,1:nsmp);
  audio.time{1}  = audio.time{1}(1:nsmp);
  data.trial{1}  = data.trial{1}(:,1:nsmp);
  data.time{1}   = data.time{1}(1:nsmp);
  
  data = ft_channelnormalise([],ft_appenddata([],data,audio));
  
  % redefine
  cfg =  [];
  cfg.length = 10;
  cfg.overlap = 0;
  data = ft_redefinetrial(cfg, data);
  
  % spectral analysis
  cfg = [];
  cfg.method = 'mtmfft';
  cfg.output = 'powandcsd';
  cfg.tapsmofrq = 1;
  cfg.channelcmb = {'all' 'all'};
  freq = ft_freqanalysis(cfg, data);
  
  % compute coherence
  cfg         = [];
  cfg.method  = 'coh';
  cfg.complex = 'complex';
  coh         = ft_connectivityanalysis(cfg, freq);
  phi         = unwrap(angle(coh.cohspctrm));
  
  f1 = nearest(freq.freq,150);
  f2 = nearest(freq.freq,250);
  X  = [ones(1,f2-f1+1);freq.freq(f1:f2)];
  X(2,:) = X(2,:)-mean(X(2,:));
  beta   = phi(:,f1:f2)/X;
  
  delay  = beta(:,2)*1000./(2*pi);

end
