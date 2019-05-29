function streams_leadfield(subject)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% create the subject structure
if ischar(subject)
  subject = streams_subjinfo(subject);
end

% directories 
subject_code                 = subject.name;
anatomy_dir                  = fullfile('/project/3011044.02/preproc/anatomy');
meg_dir                      = fullfile('/project/3011044.02/preproc/meg');
atlas_dir                    = fullfile('/project/3011044.02/preproc/atlas');

% filenames for loading
headmodel_filename           = fullfile(anatomy_dir, [subject_code, '_headmodel.mat']);
sourcemodel_filename         = fullfile(anatomy_dir, [subject_code, '_sourcemodel.mat']);
parcellation                 = fullfile(atlas_dir, '374/atlas_subparc374_8k.mat');
datafile                     = fullfile(meg_dir, sprintf('%s_meg.mat', subject_code));

%for saving
leadfield_filename           = fullfile(anatomy_dir, [subject_code, '_leadfield.mat']);
% leadfield_parcellated        = fullfile(anatomy_dir, [subject_code, '_leadfield_parc.mat']);


%% Full leadfield

% load the necessary files
load(sourcemodel_filename)
load(headmodel_filename)
load(parcellation);  % load in the atlas
load(datafile); %for gradiometer information

% compute leadfield
cfg = [];
cfg.headmodel = headmodel;
cfg.pos = sourcemodel.pos;
cfg.inside = sourcemodel.inside;
leadfield = ft_prepare_leadfield(cfg, data);

%% Also save the original leadfield, but with a 'dummy' label, to allow code further downstream to work
leadfield.labelorg = leadfield.label;
inside = find(leadfield.inside);
for k = 1:numel(inside)
    indx = inside(k);
    leadfield.label{k} = sprintf('source%0.5d',indx);
end

save(leadfield_filename, 'leadfield');

%% Parcellated leadfield

% leadfield_parc = streams_parcellate_leadfield(leadfield, atlas);
% save(leadfield_parcellated, 'leadfield_parc');

end

