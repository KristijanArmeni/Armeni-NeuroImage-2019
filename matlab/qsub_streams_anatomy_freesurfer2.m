function qsub_streams_anatomy_freesurfer2(subject)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here


% Fressurfer script2
shell_script      = '/project/3011044.02/scripts/meg-pipeline/matlab/streams_anatomy_freesurfer2.sh';
mri_dir           = '/project/3011044.02/preproc/anatomy';
subject_dir       = subject;

% streams_anatomy_freesurfer2.sh
command = [shell_script, ' ', mri_dir, ' ', subject_dir];

system(command);

end

