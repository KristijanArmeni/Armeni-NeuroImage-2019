function streams_anatomy_skullstrip(subject)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

%% Initialize the variables

% create the subject structure
if ischar(subject)
  subject = streams_subjinfo(subject);
end

% directories and filenames
subject_code                 = subject.name;
anatomy_dir                  = fullfile('/project/3011044.02/preproc/anatomy/'); %just for test, should be: '/home/language/jansch/projects/streams/data/anatomy'
resliced_mni_filename        = fullfile(anatomy_dir, [subject_code, '_mni_resliced.mgz']);
mri_skullstrip               = fullfile(anatomy_dir, [subject_code, '_skullstrip']);

% read in the .mgz file created with streams_anatomy_mgz2mni
mri_resliced_mni             = ft_read_mri(resliced_mni_filename);

% FSL variables
threshold       = 0.5;
T               = inv(mri_resliced_mni.transform);
center          = round(T(1:3,4))';
subjectname     = subject_code;

% name for the temporary nifti file
t   = fullfile(anatomy_dir, [subject_code, '_nifti_tmp']);

%% Skullstrip via FSL

% Convert to nifti temporarily and save;
cfg = [];
cfg.filename = t;
cfg.filetype = 'nifti';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, mri_resliced_mni);

% Create the FSL command-string
str = ['/opt/fsl/5.0.9/bin/bet ',t,'.nii ',t];
str = [str,'-R -f ',num2str(threshold),' -c ', num2str(center),' -g 0 -m -v'];

% Call the FSL command-string
system(str);

% Read the FSL-based segmentation
seg  = ft_read_mri([t,'-R.nii.gz']);
delete([t,'.nii']);
delete([t,'-R.nii.gz']);
delete([t,'-R_mask.nii.gz']);

% Save the FSL-based segmentation in .mgz
cfg = [];
cfg.filename = mri_skullstrip;
cfg.filetype = 'mgz';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, seg);

% Check the plot already now
skullstrip = ft_read_mri([mri_skullstrip '.mgz']);
cfg = [];
cfg.interactive = 'yes';
ft_sourceplot(cfg, skullstrip);

end

