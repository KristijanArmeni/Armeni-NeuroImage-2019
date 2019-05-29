%% MRI PREPROCESSING, HEADMODEL, SOURCEMODEL

% PREPOCESSING
subject = 's28';

% converting dicoms to mgz format
streams_anatomy_dicom2mgz(subject);

% reslicing to freesufer-friendly 256x256x256
streams_anatomy_mgz2mni(subject);

streams_anatomy_mgz2ctf(subject);

% Skullstriping
streams_anatomy_skullstrip(subject);

%% Freesurfer scripts (creates subject-specific subdirectory in the directory where previous files are stored)
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end
subjects = {'s18' 's15' 's27' 's28'};

for i = 1:numel(subjects)
  
  subject = subjects{i};
  
  qsubfeval('qsub_streams_anatomy_freesurfer', subject,...
            'memreq', 1024^3 * 6,...
            'timreq', 720*60,...
            'batchid', 'streams_freesurferI');
end

%% Check-up and white matter segmentation cleaning if needed

streams_anatomy_volumetricQC(subject)

streams_anatomy_wmclean(subject)

%% Freesurfer qsub2
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

subjects = strsplit(sprintf('s%.2d ', [15,18,28]));
subjects = subjects(~cellfun(@isempty, subjects));

s6 = strcmp(subjects, 's06');
subjects(s6) = []; % s06 dataset does not exist, empty it to prevent errors

num_sub = numel(subjects);
display(subjects);

for k = 1:num_sub
    
    subject = subjects{k};
    
    qsubfeval('qsub_streams_anatomy_freesurfer2', subject,...
              'memreq', 1024^3 * 7,...
              'timreq', 720*60,...
              'batchid', 'streams_freesurfer2');

end
%% Post-processing Freesurfer script: workbench HCP tool
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

subjects = strsplit(sprintf('s%.2d ', [15, 18, 28, 27]));
subjects = subjects(~cellfun(@isempty, subjects));
excludestrings = {'s06'};
exclude = ismember(subjects, excludestrings);

subjects(exclude) = [];
num_sub = numel(subjects);
display(subjects);

for k = 1:num_sub
  
  subject = subjects{k};
  qsubfeval('streams_anatomy_workbench', subject,...
            'memreq', 1024^3 * 6,...
            'timreq', 480*60);
          
end


%%  Sourcemodel

for h = 1:numel(subjects)

  subject = subjects{h};
  qsubfeval('streams_anatomy_sourcemodel2d', subject, ...
            'memreq', 1024^3 * 5, ...
            'timreq', 20*60);

       
end

%% Headmodel

for i = 1:numel(subjects)
   
  subject = subjects{i};
  qsubfeval('streams_anatomy_headmodel', subject, ...
            'memreq', 1024^3 * 5,...
            'timreq', 20*60);

end


%%  Coregistration check

subjects = strsplit(sprintf('s%.2d ', [2:28]));
subjects = subjects(~cellfun(@isempty, subjects));
excludestrings = {'s06'};
exclude = ismember(subjects, excludestrings);

subjects(exclude) = [];
num_sub = numel(subjects);
display(subjects);

for i = 1:num_sub
    
    subject = subjects{i};
    streams_anatomy_coregistration_qc(subject);

end

%% Leadfield parcellation

for h = 1:numel(subjects)

  subject = subjects{h};
  qsubfeval('streams_leadfield', subject, ...
            'memreq', 1024^3 * 6,...
            'timreq', 25*60);

       
end
