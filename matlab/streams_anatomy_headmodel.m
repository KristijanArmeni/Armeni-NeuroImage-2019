function streams_anatomy_headmodel(subject)

if ischar(subject)
  subject = streams_subjinfo(subject);
end

subject_code                = subject.name;
anatomy_savedir             = fullfile('/project/3011044.02/preproc/anatomy'); %just for test, should be: '/home/language/jansch/projects/streams/data/anatomy'
headmodel_filename          = fullfile(anatomy_savedir, [subject_code, '_headmodel' '.mat']);

mni_resliced_filename       = fullfile(anatomy_savedir, [subject_code, '_mni_resliced' '.mgz']);
transform                   = fullfile(anatomy_savedir, [subject_code, '_transform_vox2ctf.mat']);
load(transform);

mri                         = ft_read_mri(mni_resliced_filename);
mri.coordsys                = 'ctf';
mri.transform               = transform_vox2ctf;

cfg = [];
cfg.output = 'brain';
seg = ft_volumesegment(cfg, mri);

cfg = [];
cfg.method = 'projectmesh';
cfg.numvertices = 10000;
bnd = ft_prepare_mesh(cfg, seg);

cfg = [];
cfg.method = 'singleshell';
headmodel = ft_prepare_headmodel(cfg, bnd);

save(headmodel_filename, 'headmodel');

end

