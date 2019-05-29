function [mri, skullstrip, mask] = streams_anatomy_mni(subject)

if ischar(subject)
  subject = streams_subjinfo(subject);
end

% coregister to MNI coordinate system

% grab a dicomfile
d     = dir(fullfile(subject.mridir, subject.id, 'dicom'));
fname = fullfile(subject.mridir,subject.id,'dicom',d(end).name);

% load the mri
mri   = ft_read_mri(fname);

% do an interactive approximate registration
cfg             = [];
cfg.interactive = 'yes';
mri             = ft_volumerealign(cfg, mri);

% save
cfg = [];
cfg.filetype = 'nifti';
cfg.filename = fullfile('/home/language/jansch/projects/streams/anatomy/',[subject.name,'_anatomy_mni.nii']);
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, mri);

% skullstrip
mri.coordsys = 'mni';
threshold    = 0.5;
T            = inv(mri.transform);
center       = round(T(1:3,4))';

d   = '/home/language/jansch/projects/streams/anatomy/';
str = ['/opt/fsl_5.0.4/bin/bet ',d,subject.name,'_anatomy_mni.nii ',d,subject.name,'_anatomy_mni_skullstrip '];
str = [str,'-R -f ',num2str(threshold),' -c ', num2str(center),' -g 0 -m -v'];

system(str);
skullstrip = ft_read_mri(fullfile(d,[subject.name,'_anatomy_mni_skullstrip.nii.gz']));
mask       = ft_read_mri(fullfile(d,[subject.name,'_anatomy_mni_skullstrip_mask.nii.gz']));

