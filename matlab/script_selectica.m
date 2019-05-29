
subject = 's11';
subjectfull = streams_subjinfo(subject);
datadir = '/project/3011044.02/preproc/meg';

datafile = fullfile(datadir, [subject '_meg.mat']);
compfile = fullfile(datadir, [subject '_comp.mat']);
eegfile = fullfile(datadir, [subject '_eeg.mat']);

load(datafile);
load(compfile);
load(eegfile);

cfg = [];
cfg.channel = eeg.label(strcmp(subjectfull.montage.labelnew, 'EOGv'));
eogv = ft_selectdata(cfg, eeg);
eogv = rmfield(eogv, {'grad', 'elec'});

x = eogv.trial{:};
y = comp.trial{:};
c = [y; x];

cormat = corrcoef(c');
cormat(logical(eye(21))) = nan;
figure; imagesc(cormat);
colorbar;
title('Cross-cov matrix (ICA-eogv)');
set(gcf, 'Name', sprintf('%s correlations', subject), 'NumberTitle', 'off')
[v, i] = max(abs(cormat(end, :)));

cfg= [];
cfg.component = 1:20;
cfg.layout = 'CTF275_helmet.mat';
figure;
ft_topoplotIC(cfg, comp);
set(gcf, 'Name', sprintf('%s ICA topos', subject), 'NumberTitle', 'off')

cfg = [];
cfg.viewmode = 'component';
cfg.continuous = 'yes';
cfg.blocksize = 10;
cfg.layout = 'CTF275_helmet.mat';
ft_databrowser(cfg, comp);
set(gcf, 'Name', sprintf('%s ICA comps', subject), 'NumberTitle', 'off')

cfg = [];
cfg.viewmode = 'butterfly';
cfg.preproc.demean = 'yes';
cfg.continuous = 'yes';
cfg.blocksize = 10;
cfg.layout = 'CTF275_helmet.mat';
ft_databrowser(cfg, eogv);
set(gcf, 'Name', sprintf('%s EOG', subject), 'NumberTitle', 'off')

cfg = [];
cfg.length = 10;
comp2 = ft_redefinetrial(cfg, comp);
cfg = [];
cfg.method = 'summary';
ft_rejectvisual(cfg, comp2);
set(gcf, 'Name', sprintf('%s ICA summary', subject), 'NumberTitle', 'off')

selcomp = [9];

data_old = data;
clear data;
cfg = [];
cfg.component = selcomp;
data = ft_rejectcomponent(cfg, comp, data_old);

cfg = [];
cfg.layout = 'CTF275_helmet.mat';
cfg.preproc.demean = 'yes';
cfg.continuous = 'yes';
cfg.blocksize = 1;
ft_databrowser(cfg, data_old);
set(gcf, 'Name', sprintf('%s data pre', subject), 'NumberTitle', 'off')
ft_databrowser(cfg, data);
set(gcf, 'Name', sprintf('%s data post', subject), 'NumberTitle', 'off')
