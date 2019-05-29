function script_sourceplot4eps()

%% Iitialize

addpath /home/language/kriarm/matlab/BrewerMap

resultdir = '/project/3011085.04/streams/results/figures/revision';
datadir   = '/project/3011085.04/streams/analysis/freqanalysis/source/group4-combinedfreq/onset_lock_minoverlap';
prefix    = 's02-s28';
sep       = '_';
saveformat = '-png';
pixdim     = '-m8';

do_appendix = 'no';

%mesh
load /project/3011044.02/preproc/atlas/cortex_inflated_shifted.mat % ctx var

% ft_sourceplot configuration
cfg               = [];
cfg.funparameter  = 'stat';
cfg.maskparameter = 'stat';
cfg.maskstyle     = 'colormix';
cfg.method        = 'surface';
cfg.funcolormap   = flipud(brewermap(65, 'RdBu'));
cfg.camlight      = 'no';
cfg.colorbar      = 'yes';

opacityratio      = 0.5;
%% ENTROPY THETA

iv       = 'entropy';
freq     = '6';
filename = fullfile(datadir, [prefix sep iv sep freq]);

% Load data
load(filename);
s = stat_group; clear stat_group % make variable name shorter

% extract maximal lags
[maxlag_val, maxlag_idx] = max(abs(squeeze(s.stat))');

% general fig
cfg.funcolorlim   = 'maxabs';

sp        = keepfields(s, {'stat' 'time' 'dimord'});
sp.stat   = mean(s.stat.*double(s.posclusterslabelmat==1), 3);
sp.dimord = 'pos_time';
sp.time   = 0;
sp.pos    = ctx.pos;
sp.tri    = ctx.tri;

%ft_sourceplot(cfg, sp);

% Medial view
%view([-90 0]); camlight; material dull;
%figure11 = fullfile(resultdir, [iv sep freq sep 'avg' sep 'M']);
%export_fig(figure11, saveformat, pixdim)

% Lateral view
%view([90 0]); camlight; material dull;
%figure12 = fullfile(resultdir, [iv sep freq sep 'avg' sep 'L']);
%export_fig(figure12, saveformat, pixdim)

% Time slices
times           = [1 2 3 4];
maxabs          = max(abs(s.stat(:)));
cfg.funcolorlim = [-maxabs maxabs];

for k = 1:numel(times)   
    
    sp.stat   = s.stat(:, 1, k).*double(s.posclusterslabelmat(:, 1, k)==2);
    %sp.stat   = s.stat(:, 1, k);
    sp.dimord = 'pos_time';
    sp.time   = times(k);
    sp.pos    = ctx.pos;
    sp.tri    = ctx.tri;
    
    % lateral side
    cfg.opacitylim = cfg.funcolorlim.*opacityratio;
    ft_sourceplot(cfg, sp);
    
    t = [iv '-' freq '-' num2str(k)];
    view([90 0]); camlight; material dull; title(t);
    figure13 = fullfile(resultdir, [iv sep freq sep num2str(k) sep 'L2']);
    export_fig(figure13, saveformat, pixdim)
    
    % medial side
    cfg.opacitylim = 'auto';
    ft_sourceplot(cfg, sp);
    
    view([-90 0]); camlight; material dull; title(t)
    figure14 = fullfile(resultdir, [iv sep freq sep num2str(k) sep 'M2']);
    export_fig(figure14, saveformat, pixdim)
    
end

clear s sp

%% ENTROPY BETA

freq     = '16';
iv       = 'entropy';
filename = fullfile(datadir, [prefix sep iv sep freq]);

load(filename);
s = stat_group; clear stat_group % make variable name shorter

% Plot
cfg.funcolorlim   = 'maxabs';

sp        = keepfields(s, {'stat' 'time' 'dimord'});
sp.stat   = mean(s.stat.*double(s.negclusterslabelmat == 1),3);
sp.dimord = 'pos_time';
sp.time   = 0;
sp.pos    = ctx.pos;
sp.tri    = ctx.tri;

%ft_sourceplot(cfg, sp);

% Medial
% view([-90 0]); camlight; material dull;
% figure21 = fullfile(resultdir, [iv sep freq sep 'avg' sep 'M']);
% export_fig(figure21, saveformat, pixdim)

% Lateral
% view([90 0]); camlight; material dull;
% figure22 = fullfile(resultdir, [iv sep freq sep 'avg' sep 'L']);
% export_fig(figure22, saveformat, pixdim)

% Time slices
times           = [1 2 3 4];
maxabs          = max(abs(s.stat(:)));
cfg.funcolorlim = [-maxabs maxabs];

for k = 1:numel(times)   
    
    t = [iv '-' freq '-' num2str(k)];
    
    sp.stat   = s.stat(:, 1, k).*double(s.negclusterslabelmat(:, 1, k) == 1);
    %sp.stat   = s.stat(:, 1, k);
    sp.dimord = 'pos_time';
    sp.time   = times(k);
    sp.pos    = ctx.pos;
    sp.tri    = ctx.tri;
    
    % lateral sides
    cfg.opacitylim = 'auto';
    ft_sourceplot(cfg, sp);
    view([90 0]); camlight; material dull; title(t);
    
    figure23 = fullfile(resultdir, [iv sep freq sep num2str(k) sep 'L']);
    export_fig(figure23, saveformat, pixdim)
    
    % medial side
    ft_sourceplot(cfg, sp);
    
    view([-90 0]); camlight; material dull; title(t);
    figure24 = fullfile(resultdir, [iv sep freq sep num2str(k) sep 'M']);
    export_fig(figure24, saveformat, pixdim)
    
end

clear s sp

%% LOW BETA PERPLEXITY

freq     = '16';
iv       = 'perplexity';
filename = fullfile(datadir, [prefix sep iv sep freq]);

load(filename);
s = stat_group; clear stat_group % make variable name shorter

% Verage plot
cfg.funcolorlim = 'maxabs';

sp        = keepfields(s, {'stat' 'time' 'dimord'});
sp.stat   = mean(s.stat.*double(s.negclusterslabelmat==1),3);
sp.dimord = 'pos_time';
sp.time   = 0;
sp.pos    = ctx.pos;
sp.tri    = ctx.tri;

%ft_sourceplot(cfg, sp);

% Medial view
% view([-90 0]); camlight; material dull;
% figure31 = fullfile(resultdir, [iv sep freq sep 'avg' sep 'M']);
% export_fig(figure31, saveformat, pixdim)

% Lateral view
% view([90 0]); camlight; material dull;
% figure32 = fullfile(resultdir, [iv sep freq sep 'avg' sep 'L']);
% export_fig(figure32, saveformat, pixdim)

% Time-specific
times = [1 2 3 4];
maxabs          = max(abs(s.stat(:)));
cfg.funcolorlim = [-maxabs maxabs];
cfg.opacitylim  = 'auto';

for k = 1:numel(times)   
    
    t = [iv '-' freq '-' num2str(k)]; % title string
    
    sp.stat   = s.stat(:, 1, k).*double(s.negclusterslabelmat(:, 1, k) == 1);
    sp.dimord = 'pos_time';
    sp.time   = times(k);
    sp.pos    = ctx.pos;
    sp.tri    = ctx.tri;

    ft_sourceplot(cfg, sp);
    
    % Lateral side
    view([90 0]); camlight; material dull; title(t);
    figure33 = fullfile(resultdir, [iv sep freq sep num2str(k) sep 'L']);
    export_fig(figure33, saveformat, pixdim)
    
    % Medial side
    view([-90 0]); camlight; material dull; title(t);
    figure34 = fullfile(resultdir, [iv sep freq sep num2str(k) sep 'M']);
    export_fig(figure34, saveformat, pixdim)
    
end

clear s sp

%% HIGH BETA PERPLEXITY

freq     = '25';
iv       = 'perplexity';
filename = fullfile(datadir, [prefix sep iv sep freq]);

load(filename);
s = stat_group; clear stat_group % make variable name shorter

% Plot
cfg.funcolorlim   = 'maxabs';

sp        = keepfields(s, {'stat' 'time' 'dimord'});
sp.stat   = mean(s.stat.*double(s.negclusterslabelmat==1),3);
sp.dimord = 'pos_time';
sp.time   = 0;
sp.pos    = ctx.pos;
sp.tri    = ctx.tri;

%ft_sourceplot(cfg, sp);

% Medial view
% view([-90 0]); camlight; material dull;
% figure41 = fullfile(resultdir, [iv sep freq sep 'avg' sep 'M']);
% export_fig(figure41, saveformat, pixdim)

% Lateral view
% view([90 0]); camlight; material dull;
% figure42 = fullfile(resultdir, [iv sep freq sep 'avg' sep 'L']);
% export_fig(figure42, saveformat, pixdim)

% Time-specific
times           = [1 2 3 4];
maxabs          = max(abs(s.stat(:)));
cfg.funcolorlim = [-maxabs maxabs];
cfg.opacitylim  = 'auto';

for k = 1:numel(times)   

    t = [iv '-' freq '-' num2str(k)]; % title string
    
    sp.stat   = s.stat(:, 1, k).*double(s.negclusterslabelmat(:, 1, k) == 1);
    sp.dimord = 'pos_time';
    sp.time   = times(k);
    sp.pos    = ctx.pos;
    sp.tri    = ctx.tri;
    
    ft_sourceplot(cfg, sp);
    
    % lateral side
    view([90 0]); camlight; material dull; title(t);
    figure43 = fullfile(resultdir, [iv sep freq sep num2str(k) sep 'L']);
    export_fig(figure43, saveformat, pixdim)
    
    % medial side
    view([-90 0]); camlight; material dull; title(t);
    figure44 = fullfile(resultdir, [iv sep freq sep num2str(k) sep 'M']);
    export_fig(figure44, saveformat, pixdim);
    
end

if istrue(do_appendix)

% include here code for generarting other figures if needed
    
end


end