function script_fig5()

addpath /home/language/kriarm/matlab/BrewerMap
datadir            = '/project/3011085.04/streams/analysis/coherence/source/subject';
savedir            = '/project/3011085.04/streams/results/figures/coherence';
[subjects, numsub] = streams_util_subjectstring(2:28, {'s06', 's09'});

suffixkey = 'maxLR';
t         = dir(datadir);
t         = t(contains({t.name}, suffixkey));
suffix    = {t.name}';

%% FIGURE 1, Panel B

% Create the data structure
for k = 1:numsub

    subject = subjects{k};

    %cohf     = fullfile(datadir, [subject '_' suffix]); % load lcmv coherence
    cohf      = fullfile(datadir, suffix{k});
    cohdics   = fullfile(datadir, [subject, '_6']);      % load disc coherence
    load(cohf); cohlcmv = coh; clear coh;               % rename the variable to 'cohspec' to safely load in cohtheta as 'coh'
    load(cohdics);

    % take median over a subselection of locations
    r        = contains(cohlcmv.label, {'R_'}); % vertices in the right hemisphere
    cohlcmvR = squeeze(cohlcmv.cohspctrm(r, end, :));
    cohlcmvR = median(cohlcmvR, 1);        % median across vertex locations

    % left hemisphere
    l        = contains(cohlcmv.label, {'L_',});
    cohlcmvL = squeeze(cohlcmv.cohspctrm(:, end, :));
    cohlcmvL = median(cohlcmvL, 1);

    cohall(k).subject    = subject;
    cohall(k).lcmvfile   = cohf;
    cohall(k).cohlcmvR   = cohlcmvR;
    cohall(k).cohlcmvL   = cohlcmvL;
    cohall(k).dicsfile   = cohdics;
    cohall(k).dics       = coh;

end

% Panel A
% saveformat = '-png';
% 
load /project/3011085.04/streams/preproc/atlas/cortex_inflated_shifted.mat
m.tri = ctx.tri;
m.pos = ctx.pos;
% 
% cohdics = cat(1, cohall(:).dics);
% 
% s.stat = mean(cohdics); % take average across subjects
% s.pos  = m.pos;
% s.tri  = m.tri;
% 
% cfg               = [];
% cfg.funparameter  = 'stat';
% cfg.maskparameter = 'stat';
% cfg.maskstyle     = 'colormix';
% cfg.method        = 'surface';
% cfg.funcolormap   = flipud(brewermap(65, 'RdBu'));
% cfg.funcolorlim   = 'maxabs';
% cfg.camlight      = 'no';
% cfg.colorbar      = 'yes';
% 
% ft_sourceplot(cfg, s)
% view([70 10]);
% l = camlight;
% material dull;
% 
% figure10 = fullfile(savedir, 'theta-L');
% export_fig(figure10, saveformat, '-m8')
% 
% ft_sourceplot(cfg, s)
% view([110 10]);
% l = camlight;
% l.Position = l.Position(2).*[1 0.5 0.8];
% material dull;
% 
% figure11 = fullfile(savedir, 'theta-R');
% export_fig(figure11, saveformat, '-m8')

% Panel B
saveformat = '-eps';
xlims      = [0 30];
ylims      = [0 0.5];
linecolor  = [0.65, 0.65, 0.65];

cohlcmvR = cat(1, cohall(:).cohlcmvR);
cohlcmvL = cat(1, cohall(:).cohlcmvL);

% Right parcel
figure;
plot(cohlcmv.freq, cohlcmvR, '-', 'Color', linecolor); hold on;
plot(cohlcmv.freq, median(cohlcmvR), 'r');
xlim(xlims);
ylim(ylims);
title('right');
box('off')

% hold on;
% xsel       = cohspec.freq(cohspec.freq >= 4 & cohspec.freq < 8);

% xpatch      = [xsel(1), xsel(1), xsel(end), xsel(end)];
% ypatch      = [ylims(1), ylims(2), ylims(2), ylims(1)];
% p           = patch(xpatch, ypatch, [0.7 0.7 0.7]);
% p.LineStyle = 'none';
% p.FaceAlpha = 0.2;

figure13 = fullfile(savedir, [suffixkey '-R']);
export_fig(figure13, saveformat);

% Left parcel
figure;
plot(cohlcmv.freq, cohlcmvL, '-', 'Color', linecolor); hold on;
plot(cohlcmv.freq, median(cohlcmvL), 'r');
xlim(xlims);
ylim(ylims);
title('left');
box('off')
% 
% xpatch      = [xsel(1), xsel(1), xsel(end), xsel(end)];
% ypatch      = [ylims(1), ylims(2), ylims(2), ylims(1)];
% p           = patch(xpatch, ypatch, [0.7 0.7 0.7]);
% p.LineStyle = 'none';
% p.FaceAlpha = 0.2;

figure14 = fullfile(savedir, [suffixkey '-L']);
export_fig(figure14, saveformat)

%% Show the location of the selected parcel

saveformat = '-png';

% Load atlas
load /project/3011044.02/preproc/atlas/374/atlas_subparc374_8k.mat

% Strip last 4 characters form labels
for k = 1:numel(cohlcmv.label)-1 % skip 'audio_avg' label
    lab{k} = cohlcmv.label{k}(1:11);
end
idx = find(contains(atlas.parcellationlabel, lab));

% Emphasize right
ba42 = ismember(atlas.parcellation, idx);

figure;
set(gcf,'color','w');
ft_plot_mesh(m, 'vertexcolor', double(ba42)); colormap parula
view([110 10]);
l = camlight;
material dull;

figure15 = fullfile(savedir, [suffixkey, 'R']);
export_fig(figure15, saveformat, '-m8');

% Emphasize left
figure;
set(gcf,'color','w');
ft_plot_mesh(m, 'vertexcolor', double(ba42)); colormap parula
view([70 10]);
l = camlight;
material dull;

figure16 = fullfile(savedir, [suffixkey, 'L']);
export_fig(figure16, saveformat, '-m8');

%% Check left-right

% dicsselL = ismember(atlas.parcellation, idx(1:3));
% dicsselR = ismember(atlas.parcellation, idx(4:6));
% 
% cohdicsR = s.stat(dicsselR); % grand average dics coherence for 6 Hz in right BA42
% cohdicsL = s.stat(dicsselL); 
% 
% cohdifflcmv = mean(cohlcmvR - cohlcmvL);   % grand average of diference in BA42 per frequency
% cohdiffdics = mean(cohdicsR - cohdicsL);  % average difference in grand average for 6 Hz in BA42

end