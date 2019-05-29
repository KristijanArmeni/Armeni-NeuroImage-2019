function cfg = streams_artifact_muscle(subject)

if ~iscell(subject.trl)
  subject.dataset = {subject.dataset};
  subject.trl     = {subject.trl};
end

[status, filename] = streams_existfile([subject.name,'_muscle.mat']);
if status
  load(filename);
else
  fprintf('computing muscle artifact definition for subject %s\n', subject.name);
  
  for kk = 1:numel(subject.dataset)
    % convert trl into slightly ovelapping 4 second epochs
    trl = zeros(0,3);
    for k = 1:size(subject.trl{kk},1)
      tmp = [];
      tmp(:,1) = ((subject.trl{kk}(k,1)-2400):4700:(subject.trl{kk}(k,2)+2400))';
      tmp(:,2) = tmp(:,1) + 4799;
      tmp(:,3) = 0;
      trl      = [trl;tmp];
    end
    fprintf('creating temporary trl containing %d epochs\n', size(trl,1));
    
    % muscle artifacts
    cfg                          = [];
    cfg.trl                      = trl;
    cfg.continuous               = 'yes';
    cfg.dataset                  = subject.dataset{kk};
    cfg.memory                   = 'low';
    cfg.artfctdef.zvalue.channel = {'MEG'};
    cfg.artfctdef.zvalue.bpfilter = 'no';
    cfg.artfctdef.zvalue.hilbert  = 'no';
    cfg.artfctdef.zvalue.rectify  = 'yes';
    cfg.artfctdef.zvalue.hpfilter = 'yes';
    cfg.artfctdef.zvalue.hpfreq   = 80;
    cfg.artfctdef.zvalue.cutoff     = 10;
    cfg.artfctdef.zvalue.demean     = 'yes';
    cfg.artfctdef.zvalue.boxcar     = 0.5;
    cfg.artfctdef.zvalue.fltpadding = 0;
    cfg.artfctdef.zvalue.trlpadding = 0;
    cfg.artfctdef.zvalue.artpadding = 0.1; % .1 sec padding
    cfg.artfctdef.zvalue.interactive= 'yes';
    cfg.artfctdef.type           = 'zvalue';
    cfg.artfctdef.reject         = 'partial';
    
    cfg = ft_checkconfig(cfg, 'dataset2files', 'yes');
    cfg = ft_artifact_zvalue(cfg);
    allcfg{kk} = cfg;
  end
  cfg = allcfg;
  if numel(subject.dataset)==1
    cfg = cfg{1};
  end
  filename = fullfile('/project/3011044.02/preproc/meg', [subject.name,'_muscle.mat']);
  save(filename, 'cfg');
end

