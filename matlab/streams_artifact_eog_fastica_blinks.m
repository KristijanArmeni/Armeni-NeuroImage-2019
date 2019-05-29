function [avgcomp, avgpre, avgeog, mixing, unmixing] = streams_artifact_eog_fastica_blinks(subject)

[status, filename] = streams_existfile([subject.name,'_eogv_fastica.mat']);
if status
  load(filename);
else
  fprintf('computing EOGv topographies for subject %s\n', subject.name);
  
  if ~iscell(subject.dataset)
    % convert to cell, to accommodate for the fact that some sessions may
    % consist of more than one dataset
    subject.dataset = {subject.dataset};
    subject.trl     = {subject.trl};
    subject.artfctdef = {subject.artfctdef};
  else
    % assume more than one dataset, and convert artfctdef accordingly
    for kk = 1:numel(subject.dataset)
      artfctdef{kk}.squidjumps = subject.artfctdef.squidjumps{kk};
      artfctdef{kk}.muscle     = subject.artfctdef.muscle{kk};
    end
    subject.artfctdef       = artfctdef;
  end
  
  for kk = 1:numel(subject.dataset)
    cfg0 = [];
    cfg0.dataset    = subject.dataset{kk};
    cfg0.trl        = subject.trl{kk};
    cfg0.artfctdef  = subject.artfctdef{kk};
    cfg0.artfctdef.reject = 'partial';
    cfg0 = ft_rejectartifact(cfg0);
    
    cfg1            = [];
    cfg1.continuous = 'yes';
    cfg1.dataset    = subject.dataset{kk};
    cfg1.channel    = 'MEG';
    cfg1.demean     = 'yes';
    cfg1.trl        = cfg0.trl;
    cfg1.trl(:,3)   = 0;
    
    cfg2            = cfg1;
    cfg2.channel    = subject.montage.labelorg(subject.montage.tra(strcmp(subject.montage.labelnew,'EOGv'),:)==1);
    cfg2.boxcar     = 0.2;
    cfg2.bpfilter   = 'yes';
    cfg2.bpfreq     = [1 10];
    cfg2.bpfiltord  = 2;
    cfg2.rectify    = 'yes';
    cfg2.trl        = cfg0.trl;
    
    cfg3            = [];
    cfg3.demean     = 'yes';
    cfg3.detrend    = 'no';
    cfg3.resamplefs = 300;
    
    % read in and normalise eog data
    data            = ft_resampledata(cfg3, ft_preprocessing(cfg1));
    eog             = ft_resampledata(cfg3, ft_channelnormalise([], ft_preprocessing(cfg2)));
    
   
    % compute peak times for eog
    clear p
    for k = 1:numel(eog.trial)
      p = peakdetect2(eog.trial{k}(1,:),0.5,120);
      params.tr{k,1} = p(:);
    end
    
    cfg2.rectify = 'no';
    cfg2         = rmfield(cfg2, 'boxcar');
    
    eognew = ft_resampledata(cfg3, ft_preprocessing(cfg2));
    eognew = ft_checkdata(eognew, 'hassampleinfo', 'yes');
    
    % do componentanalysis for eye blinks
    addpath /home/language/jansch/matlab/toolboxes/dss2_1-0
    params.demean   = 1;
    s.X             = 1;
    params.computenew = 0;
    params.pre      = 50;
    params.pst      = 75;
    [~,~,avgpre]    = denoise_avg2(params,data.trial,s);
    [~,~,avgeog]    = denoise_avg2(params,eognew.trial,s);
    
    cfg                   = [];
    cfg.method            = 'fastica';
    cfg.fastica.lastEig   = 50;
    cfg.fastica.g         = 'tanh';
    cfg.channel           = 'MEG';
    cfg.numcomponent      = 10;
    %cfg.cellmode          ='yes';
    comp                  = ft_componentanalysis(cfg, data);
    
    [~,~,avgcomp]         = denoise_avg2(params,comp.trial,s);
    
    mixing   = comp.topo;
    unmixing = comp.unmixing;
    
    if numel(subject.dataset)>1
      all_avgpre{kk}  = avgpre;
      all_avgcomp{kk} = avgcomp;
      all_avgeog{kk}  = avgeog;
      all_mixing{kk}  = mixing;
      all_unmixing{kk} = unmixing;
    end
  end
  
  if numel(subject.dataset)>1
    avgpre  = all_avgpre;
    avgcomp = all_avgcomp;
    avgeog  = all_avgeog;
    mixing  = all_mixing;
    unmixing = all_unmixing;
  end
  filename = fullfile('/project/3011044.02/preproc/meg', [subject.name,'_eogv_fastica.mat']);
  save(filename, 'avgpre', 'avgcomp', 'avgeog', 'mixing', 'unmixing');
end


