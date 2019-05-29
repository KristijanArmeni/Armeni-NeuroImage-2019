function [mri, sourcemodel, headmodel, shape, shapemri] = streams_anatomy(subject)

if ischar(subject)
  subject = streams_subjinfo(subject);
end

% coregister to CTF coordinate system

% grab a dicomfile
d     = dir(fullfile(subject.mridir, subject.id, 'dicom'));
fname = fullfile(subject.mridir,subject.id,'dicom',d(end).name);

% load the mri
mri   = ft_read_mri(fname);

% do an interactive approximate registration
cfg             = [];
cfg.interactive = 'yes';
mri             = ft_volumerealign(cfg, mri);

% do a refined coregistration
try,
  cfg           = [];
  cfg.method    = 'headshape';
  cfg.headshape = fullfile(subject.dataset,[subject.name,'.pos']);
  mri           = ft_volumerealign(cfg, mri);

  shape    = mri.cfg.headshape;
  shapemri = mri.cfg.headshapemri;
catch
  shape    = [];
  shapemri = [];
end

% segment the mri
thr = 0.3;
cfg = [];
cfg.output = 'brain';
cfg.brainthreshold = thr;
seg = ft_volumesegment(cfg, mri);

% create the headmodel
cfg = [];
cfg.method = 'singleshell';
headmodel  = ft_prepare_headmodel(cfg, seg);
headmodel  = ft_convert_units(headmodel, 'cm');

% create the sourcemodel
cfg                 = [];
cfg.grid.warpmni    = 'yes';
cfg.grid.resolution = 6;
cfg.grid.nonlinear  = 'yes';
cfg.mri             = mri;
sourcemodel         = ft_prepare_sourcemodel(cfg);

% remove the mri-structure from sourcemodel.cfg
sourcemodel.cfg = rmfield(sourcemodel.cfg, 'mri');
