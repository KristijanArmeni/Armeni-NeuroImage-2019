function streams_anatomy_workbench(subject)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Strings for the command
shell_script      = '/project/3011044.02/scripts/meg-pipeline/matlab/streams_anatomy_postfreesurferscript.sh';
mri_dir           = '/project/3011044.02/preproc/anatomy';
subject_dir       = subject;

% streams_anatomy_freesurfer2.sh
command = [shell_script, ' ', mri_dir, ' ', subject_dir];

system(command);

end

