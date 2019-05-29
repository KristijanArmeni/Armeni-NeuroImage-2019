function streams_anatomy_mgz2ctf(subject)
%streams_anatomy_mgz2ctf reads in the resliced volume created with
%streams_anatomy_mgz2mni and the transformation matrix and calls
%ft_volumerealign to perform interactive coregistration to CTF coordinate
%headspace. It then saves the transformation matrix


%% Initialize the variables
if ischar(subject)
  subject = streams_subjinfo(subject);
end

subject_code                = subject.name;
anatomy_savedir             = fullfile('/project/3011044.02/preproc/anatomy'); 
resliced_filename           = fullfile(anatomy_savedir, [subject_code, '_mni_resliced' '.mgz']);
transformation_matrix_mni   = fullfile(anatomy_savedir, [subject_code, '_transform_vox2mni.mat']);

%read in the resliced volume
mri_resliced_mni = ft_read_mri(resliced_filename);

% check if the transformation matrix exist, if so read it in 
if exist(transformation_matrix_mni, 'file')

  load(transformation_matrix_mni);
  
  if isequal(mri_resliced_mni.transform, transformation_matrix_mni)
    % do nothing
  else
    fprintf('adding coregistration information to the mrifile of subject %s\n', subject_code);

    mri_resliced_mni.transform = transform_vox2mni;

    cfg = [];
    cfg.parameter = 'anatomy';
    cfg.filename  = resliced_filename;
    cfg.filetype  = 'mgz';
    ft_volumewrite(cfg, mri_resliced_mni);

    clear mri;
  end

end
%% Interactive realignment to the CTF conventions

cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'ctf';
mri_ctf    = ft_volumerealign(cfg, mri_resliced_mni);

% save the transformation matrix
transform_vox2ctf = mri_ctf.transform;
filename_vox2ctf  = fullfile(anatomy_savedir, [subject_code, '_transform_vox2ctf']);
save(filename_vox2ctf, 'transform_vox2ctf');
  
end

