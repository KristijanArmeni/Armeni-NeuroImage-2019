function streams_anatomy_coregistration_qc(subject)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if ischar(subject)
  subject = streams_subjinfo(subject);
end

anatomy_dir = fullfile('/project/3011044.02/preproc/anatomy');
headmodel   = fullfile(anatomy_dir, [subject.name '_headmodel.mat']);
sourcemodel = fullfile(anatomy_dir, [subject.name, '_sourcemodel.mat']);

load(headmodel)
load(sourcemodel)

figure; hold on;
ft_plot_vol(headmodel, 'facecolor', 'none'); alpha 0.5;
ft_plot_mesh(sourcemodel, 'facecolor', 'cortex', 'edgecolor', 'none'); camlight;

end

