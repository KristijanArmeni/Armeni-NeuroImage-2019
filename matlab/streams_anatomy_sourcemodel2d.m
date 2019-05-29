function [sourcemodel] = streams_anatomy_sourcemodel2d(subject)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if ischar(subject)
  subject = streams_subjinfo(subject);
end


anatomy_dir           = '/project/3011044.02/preproc/anatomy';
inp_dir               = fullfile(anatomy_dir, subject.name);
sourcemodel_filename  =fullfile(anatomy_dir, [subject.name, '_sourcemodel.mat']); %string for saving the sourcemodel file


% load in the cortical sheet
filename = fullfile(inp_dir,['workbench/' subject.name, '.L.midthickness.8k_fs_LR.surf.gii']);
filename2 = strrep(filename, '.L.', '.R.');

sourcemodel = ft_read_headshape({filename, filename2});

% get the necessary coregistration information
datapath = fullfile(anatomy_dir);
load(fullfile(datapath,[subject.name,'_transform_vox2mni']));
T1 = transform_vox2mni;
load(fullfile(datapath,[subject.name,'_transform_vox2ctf']));
T2 = transform_vox2ctf;

sourcemodel = ft_transform_geometry((T2/T1), sourcemodel);
sourcemodel.inside = sourcemodel.atlasroi>0;
sourcemodel = rmfield(sourcemodel, 'atlasroi');

save(sourcemodel_filename, 'sourcemodel');

end

