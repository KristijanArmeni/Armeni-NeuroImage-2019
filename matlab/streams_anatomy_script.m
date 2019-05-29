%% create anatomical objects needed for source reconstruction, part I

if 0,
  subject = streams_subjinfo({'s03' 's04' 's05' 's07' 's08' 's09' 's10'});
  for k = 1:numel(subject)
    [mri, sourcemodel, headmodel, shape, shapemri] = streams_anatomy(subject(k));
    anatomydir = '/home/language/jansch/projects/streams/data/anatomy';
    save(fullfile(anatomydir, [subject(k).name, '_anatomy_mri.mat']), 'mri');
    save(fullfile(anatomydir, [subject(k).name, '_anatomy_sourcemodel.mat']), 'sourcemodel');
    save(fullfile(anatomydir, [subject(k).name, '_anatomy_headmodel.mat']),   'headmodel');
    save(fullfile(anatomydir, [subject(k).name, '_anatomy_shape.mat']),       'mri');
    save(fullfile(anatomydir, [subject(k).name, '_anatomy_shapemri.mat']),    'shapemri');
  end
end

if 0,
  subject = streams_subjinfo({'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's09' 's10'});
  for k = 1:numel(subject)
    anatomydir = '/home/language/jansch/projects/streams/data/anatomy';
    load(fullfile(anatomydir, [subject(k).name, '_anatomy_mri.mat']));
    sourcemodel = streams_anatomy_sourcemodel3d(mri, 5);
    sourcemodel.cfg = rmfield(sourcemodel.cfg, 'mri');
    save(fullfile(anatomydir, [subject(k).name, '_anatomy_sourcemodel5mm.mat']), 'sourcemodel');
  end
end

if 0,
  load('/home/language/jansch/matlab/mri/standard_sourcemodel3d5mm_parcellated_aal_sub.mat');
  parc    = sourcemodel;
  subject = streams_subjinfo({'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's09' 's10'});
  for k = 1:numel(subject)
    anatomydir = '/home/language/jansch/projects/streams/data/anatomy';
    load(fullfile(anatomydir, [subject(k).name, '_anatomy_sourcemodel5mm.mat']), 'sourcemodel');
    sourcemodel.tissue      = parc.tissue;
    sourcemodel.tissuelabel = parc.tissuelabel;
    sourcemodel.inside      = parc.inside;
    sourcemodel.outside     = parc.outside;
    save(fullfile(anatomydir, [subject(k).name, '_anatomy_sourcemodel5mm_parc.mat']), 'sourcemodel');  
  end
end

if 1,
  subject = streams_subjinfo({'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's09' 's10'});
  for k = 1:numel(subject)
    anatomydir = '/home/language/jansch/projects/streams/data/anatomy';
    load(fullfile(anatomydir, [subject(k).name, '_anatomy_sourcemodel5mm_parc.mat']), 'sourcemodel');  
    load(fullfile(anatomydir, [subject(k).name, '_anatomy_headmodel.mat']),           'headmodel');  
    datadir    = '/home/language/jansch/projects/streams/data/preproc';
    d = dir(fullfile(datadir,[subject(k).name,'*']));
    load(fullfile(datadir,d(1).name));
    grad = data.grad;
    clear data;
    
    cfg         = [];
    cfg.grid    = ft_convert_units(sourcemodel, 'm');
    cfg.grad    = ft_convert_units(grad,        'm');
    cfg.vol     = ft_convert_units(headmodel,   'm');
    cfg.channel = 'MEG';
    sourcemodel = ft_prepare_leadfield(cfg);
    leadfield   = streams_parcellate_leadfield(sourcemodel, parc, 'parcellationparam', 'tissue');
    save(fullfile(anatomydir, [subject(k).name, '_anatomy_leadfield.mat']),           'leadfield');
  end
end