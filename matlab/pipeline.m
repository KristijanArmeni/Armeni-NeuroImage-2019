%% AUDITORY COMPONENT ANALYSIS
clear all

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};

inp_dir = '/home/language/kriarm/matlab/streams_output/data_preproc';

cd(inp_dir);

jobid_array_tlck = cell(1, numel(subjects));

for k = 1:numel(subjects)
    
    subject = streams_subjinfo(subjects{k});
    load(sprintf('%s_data.mat', subject.name));
    
    jobid_array_tlck{k} = qsubfeval('qsub_streams_dss_auditory', data, subject, ...
                                    'memreq', 1024^3 * 12,...
                                    'timreq', 240*60,...
                                    'batchid', 'streams_tlck');
end

%% CREATE MODEL OUTPUT

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
features = {'entropy', 'perplexity'};

if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

for k = 1:numel(subjects)
    
    subject = streams_subjinfo(subjects{k});
    
    qsubfeval('qsub_streams_getfeatures', subject, features, ...
                                        'memreq', 1024^3 * 8,...
                                        'timreq', 45*60,...
                                        'batchid', 'streams_features');
end

%% PREPROCESSING

clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = {'s01', 's02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
bpfreqs   = [04 08; 09 12];


% MEG: Subject, story and freq loops
for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	
  for k = 1:numel(audiofiles)
		
    audiofile = audiofiles{k};
	tmp       = strfind(audiofile, 'fn');
	audiofile = audiofile(tmp+(0:7));
    
    for h = 1:size(bpfreqs, 1)
      
      bpfreq = bpfreqs(h,:);
    
      qsubfeval('pipeline_preprocesssing_bandpasslimited_qsub', subject, audiofile, bpfreq, ...
                      'memreq', 1024^3 * 12,...
                      'timreq', 240*60,...
                      'batchid', 'streams_preproc');
    end
    
  end

end

% Language: Subject, story loops
for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	
  for k = 1:numel(audiofiles)
		
    audiofile = audiofiles{k};
	tmp       = strfind(audiofile, 'fn');
	audiofile = audiofile(tmp+(0:7));
    
    qsubfeval('qsub_streams_getfeatures', subject, audiofile, ...
                      'memreq', 1024^3 * 12,...
                      'timreq', 240*60,...
                      'batchid', 'streams_features');
    
  end

end


%% AUDIOCORTICO MI

clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = {'s02', 's03', 's04', 's05', 's07', 's08', 's09', 's10'};
bpfreqs   = [09 12; 13 18];

%Subject, story and freq loops
for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	
  for k = 1:numel(audiofiles)
		
    audiofile = audiofiles{k};
	tmp       = strfind(audiofile, 'fn');
	audiofile = audiofile(tmp+(0:7));
    
    for h = 1:size(bpfreqs, 1)
      
      bpfreq = bpfreqs(h,:);
    
      qsubfeval('qsub_streams_bpl_audio', subject, bpfreq, audiofile,...
                      'memreq', 1024^3 * 12,...
                      'timreq', 240*60,...
                      'batchid', 'streams_audio');
    end
    
  end

end

% Loops for computation with legacy code
for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	
  for k = 1:numel(audiofiles)
		
    audiofile = audiofiles{k};
		tmp       = strfind(audiofile, 'fn');
		audiofile = audiofile(tmp+(0:7));
    
    for h = 1:size(bpfreqs, 1)
      
      bpfreq = bpfreqs(h,:);
    
      qsubfeval('qsub_streams_bpl_feature_legacy', subject, bpfreq, audiofile,...
                      'memreq', 1024^3 * 12,...
                      'timreq', 60*60,...
                      'batchid', 'streams_feature');
    end
    
  end

end

%% LANGUAGE-MEG MI

clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end
[data_files, feature_files] = streams_datalist('12-18');
datadir       = '/home/language/jansch/projects/streams/data/preproc';
featuredir    = '/home/language/jansch/projects/streams/data/featuredata';

addpath(datadir)
addpath(featuredir)

for k = 1:numel(data_files)
    
    data = data_files{k};
    data = fullfile(datadir, data);
    featuredata = feature_files{k};
    featuredata = fullfile(featuredir, featuredata);
    subject = streams_subjinfo(data_files{k}(1:3));
    
    qsubfeval('qsub_streams_bpl_feature', subject, data, featuredata, ...
                      'memreq', 1024^3 * 4,...
                      'timreq', 420*60,...
                      'batchid', 'streams_feature');

end

unfinished = {4 5 48};

% for killed jobs
for k = 1:numel(unfinished)
    
    current_file = unfinished{k};
    
    data = data_files{current_file};
    data = fullfile(datadir, data);
    
    featuredata = feature_files{current_file};
    featuredata = fullfile(featuredir, featuredata);
    
    subject = streams_subjinfo(data_files{current_file}(1:3));
    
    qsubfeval('qsub_streams_bpl_feature', subject, data, featuredata, ...
                      'memreq', 1024^3 * 4,...
                      'timreq', 360*60,...
                      'batchid', 'streams_feature');

end

%% PREPROCESSING + BAND-PASS-LIMITED DATA ~ FEATURE ANALYSIS

clear all
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

subjects = {'s01' 's02' 's03' 's04' 's05' 's07' 's08' 's09' 's10'};
bpfreqs   = [04 08];

for j = 1:numel(subjects)
	subject    = streams_subjinfo(subjects{j});
	audiofiles = subject.audiofile;
	
  for k = 1:numel(audiofiles)
		audiofile = audiofiles{k};
		tmp       = strfind(audiofile, 'fn');
		audiofile = audiofile(tmp+(0:7));
 		
    for h = 1:size(bpfreqs)
    bpfreq = bpfreqs(h,:);  
    
    qsubfeval('qsub_streams_bpl_feature2', subject, bpfreq, audiofile,...
                      'memreq', 1024^3 * 12,...
                      'timreq', 480*60,...
                      'batchid', 'streams_feature');
    
    end
    
  end

end


%% FEATURE ANALYSIS: SOURCE
clear all;
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

subjects = {'s02', 's03', 's04' 's05' 's07' 's08' 's09' 's10'};
bpfreqs   = [04 08];

for j = 1:numel(subjects)
    subject    = streams_subjinfo(subjects{j});
    audiofiles = subject.audiofile;
	
  for k = 1:numel(audiofiles)
    audiofile = audiofiles{k};
    tmp       = strfind(audiofile, 'fn');
    audiofile = audiofile(tmp+(0:7));
 		
    for h = 1:size(bpfreqs)
        bpfreq = bpfreqs(h,:);  

        qsubfeval('qsub_streams_bpl_feature2_lcmv', subject, bpfreq, audiofile,...
                      'memreq', 1024^3 * 12,...
                      'timreq', 240*60,...
                      'batchid', 'streams_feature');
    
    end
    
  end

end

%% MRI PREPROCESSING, HEADMODEL, SOURCEMODEL

% PREPOCESSING
subject = 's05';

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
subjects = {'s12' 's13' 's14' 's15' 's16' 's17' 's18' 's19' 's20' 's21' 's22' 's23' 's24' 's25' 's26'};

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

qsubfeval('qsub_streams_anatomy_freesurfer2', subject,...
          'memreq', 1024^3 * 7,...
          'timreq', 720*60,...
          'batchid', 'streams_freesurfer2');

%% Post-processing Freesurfer script: workbench HCP tool
if ~ft_hastoolbox('qsub',1)
    addpath /home/common/matlab/fieldtrip/qsub;
end

subjects = {'s03' 's04' 's05' 's07' 's08' 's09' 's10'};

for k = 1:numel(subjects)
  
  subject = subjects{k};
  qsubfeval('streams_anatomy_workbench', subject,...
            'memreq', 1024^3 * 6,...
            'timreq', 480*60,...
            'batchid', 'streams_workbench');
          
end


% Coregistration check
streams_anatomy_coregistration_qc(subject);


%%  Sourcemodel
subjects = {'s04' 's05' 's07' 's08' 's09' 's10'};
for h = 1:numel(subjects)

  subject = subjects{h};
  streams_anatomy_sourcemodel2d(subject);

       
end

%% Headmodel

subjects = {'s04' 's05' 's07' 's08' 's09' 's10'};
for i = 1:numel(subjects)
   
  subject = subjects{i};
  qsubfeval('streams_anatomy_headmodel', subject, ...
            'memreq', 1024^3 * 5,...
            'timreq', 20*60,...
            'batchid', 'streams_headmodel')

end

%% Leadfield parcellation

subjects = {'s03' 's04' 's05' 's07' 's08' 's09' 's10'};
for h = 1:numel(subjects)

  subject = subjects{h};
  qsubfeval('streams_leadfield', subject, ...
            'memreq', 1024^3 * 6,...
            'timreq', 25*60,...
            'batchid', 'streams_headmodel');

       
end
