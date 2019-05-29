function streams_anatomy_volumetricQC(subject)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if ischar(subject)
  subject = streams_subjinfo(subject);
end

anatomy_dir     = '/project/3011044.02/preproc/anatomy';
inp_dir         = fullfile(anatomy_dir, subject.name);

t1              = fullfile(inp_dir, 'mri', 'T1.mgz');
normalization2  = fullfile(inp_dir, 'mri', 'brain.mgz');
white_matter    = fullfile(inp_dir, 'mri', 'wm.mgz');
white_matter_old = fullfile(inp_dir, 'mri', 'wm_old.mgz');

% Show T1
mri = ft_read_mri(t1);
cfg = [];
cfg.interactive = 'yes';
ft_sourceplot(cfg, mri);
set(gcf, 'name', [subject.name ' ' 'T1'], 'numbertitle', 'off');

% Show skullstripped image
mri = ft_read_mri(normalization2);
cfg = [];
cfg.interactive = 'yes';
ft_sourceplot(cfg, mri);
set(gcf, 'name', [subject.name ' ' 'skull-stripped'], 'numbertitle', 'off');

% Show white matter image
mri = ft_read_mri(white_matter);
cfg = [];
cfg.interactive = 'yes';
ft_sourceplot(cfg, mri);
set(gcf, 'name', [subject.name ' ' 'white matter'], 'numbertitle', 'off');

if exist(white_matter_old)
  
  mri = ft_read_mri(white_matter_old);
  cfg = [];
  cfg.interactive = 'yes';
  ft_sourceplot(cfg, mri);
  set(gcf, 'name', [subject.name ' ' 'white matter old'], 'numbertitle', 'off');
  
end

end

