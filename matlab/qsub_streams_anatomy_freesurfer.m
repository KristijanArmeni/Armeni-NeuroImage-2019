function qsub_streams_anatomy_freesurfer(subject)

% Fressurfer script1
shell_script      = '/project/3011044.02/scripts/meg-pipeline/matlab/streams_anatomy_freesurfer.sh';
mri_dir           = '/project/3011044.02/preproc/anatomy/';
subject_dir       = subject;

% create the string pointing to streams_anatomy_freesurfer.sh
command = [shell_script, ' ', mri_dir, ' ', subject_dir];

% call the script
system(command);

end

