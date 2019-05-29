
subject = 's04';
datadir = '/project/3011044.02/preproc/meg';
savedir = '/project/3011044.02/docs/draft/figures/';

[wav, fs] = audioread('/project/3011044.02/lab/pilot/stim/audio/fn001078/fn001078.wav');
audiotime = [1:numel(wav)]./fs;

megf    = fullfile(datadir, [subject '_meg-clean.mat']); 
lngf    = fullfile(datadir, [subject, '_featuredata1.mat']);
audf    = fullfile(datadir, [subject, '_aud.mat']);

load(megf)
load(audf)
load(lngf)

% Read in raw MEG data

s = streams_subjinfo(subject);

cfg          = [];
cfg.dataset  = s.dataset;
cfg.trl      = s.trl(1,:); % trial nr.1
cfg.trl(1,1) = cfg.trl(1,1) - 1200; % read in an extra second of data at the beginning
cfg.trl(1,2) = cfg.trl(1,2) + 1200; % read in an extra second of data at the end
cfg.trl(1,3) = -1200; % update the offset, to account for the padding
cfg.channel  = 'MEG';
cfg.continuous = 'yes';
cfg.demean     = 'yes';

dataraw = ft_preprocessing(cfg);

% Plot elements for Figure 1, panel A
trlsel  = 1;
time1   = 2;
time2   = 4;
smp1    = nearest(audio.time{1}(1, :), time1);
smp2    = nearest(audio.time{1}(1, :), time2);
samples = smp1:smp2;

lpfreq = 20;

smpr1    = nearest(dataraw.time{1}(1, :), time1);
smpr2    = nearest(dataraw.time{1}(1, :), time2);
samplesr = smpr1:smpr2;

% Plot meg channel
figure; plot(dataraw.time{trlsel}(1,samplesr), dataraw.trial{trlsel}(50, samplesr)); box off; xlim([time1, time2]);
saveas(gcf, fullfile(savedir, 'signal_brain'),'epsc');

% Plot envelope
figure; plot(audio.time{trlsel}(1,samples), ft_preproc_lowpassfilter(audio.trial{trlsel}(2, samples), 300, lpfreq)); box off; xlim([time1, time2]);
saveas(gcf, fullfile(savedir, 'signal_env'), 'epsc');

% Plot perplexity
figure; plot(featuredata.time{trlsel}(1,samples), log10(featuredata.trial{trlsel}(6, samples))); box off % plot entropy
saveas(gcf, fullfile(savedir, 'signal_perp'), 'epsc');

% Plot entropy
figure; plot(featuredata.time{trlsel}(1,samples), featuredata.trial{trlsel}(7, samples)); box off % plot entropy
saveas(gcf, fullfile(savedir, 'signal_entr'), 'epsc');

% Plot raw audio signal with markers
smp1 = fs*time1;
smp2 = fs*time2;

% Create onset markers based on featuredata
wordonsets                    = featuredata.trial{trlsel}(2, samples)+1;
wordonsets(isnan(wordonsets)) = 0;
wordonsets                    = diff(wordonsets) ~= 0;

wordonsettimes                        = featuredata.time{trlsel}(1, samples);
wordonsettimes(isnan(wordonsettimes)) = 0;
times                                 = wordonsettimes(wordonsets);

w1 = nearest(audiotime, times(1)); 
w2 = nearest(audiotime, times(2)); 
w3 = nearest(audiotime, times(3)); 
w4 = nearest(audiotime, times(4)); 
w5 = nearest(audiotime, times(5)); 
w6 = nearest(audiotime, times(6)); 
w7 = nearest(audiotime, times(7)); 

smps         = [w1 w2 w3 w4 w5 w6 w7];
onsets       = nan(1, numel(wav));
onsets(smps) = 1;

figure; plot(audiotime(smp1:smp2), zscore(wav(smp1:smp2))); box off; ylim([-7, 4.5]); hold on
        stem(audiotime(smp1:smp2), -1*(onsets(smp1:smp2)+4), 'o');
saveas(gcf, fullfile(savedir, 'signal_audio'), 'epsc');


%% Plot elements for Figure 1, panel B
trlsel  = 1;
time1   = 2;
time2   = 8;
smp1    = nearest(audio.time{1}(1, :), time1);
smp2    = nearest(audio.time{1}(1, :), time2);
samples = smp1:smp2;

lpfreq = 20;

smpr1    = nearest(dataraw.time{1}(1, :), time1);
smpr2    = nearest(dataraw.time{1}(1, :), time2);
samplesr = smpr1:smpr2;

% Plot meg channel
figure; plot(dataraw.time{trlsel}(1,samplesr), dataraw.trial{trlsel}(50, samplesr)); box off; xlim([time1, time2]);
saveas(gcf, fullfile(savedir, 'signal_brainB'),'epsc');

% Plot envelope
figure; plot(audio.time{trlsel}(1,samples), ft_preproc_lowpassfilter(audio.trial{trlsel}(2, samples), 300, lpfreq)); box off; xlim([time1, time2]);
saveas(gcf, fullfile(savedir, 'signal_envB'), 'epsc');

% Plot entropy
figure; plot(featuredata.time{trlsel}(1,samples), featuredata.trial{trlsel}(7, samples)); box off % plot entropy
saveas(gcf, fullfile(savedir, 'signal_entrC'), 'epsc');

%% Source plot

d = vsm_dir;

load(d.atlas{3});
m.pos = ctx.pos;
m.tri = ctx.tri;

ft_plot_mesh(m, 'facecolor', 'none', 'edgecolor', 'black');
set(gcf,'color','w');
view([80 10])
l = camlight; material dull;
%saveas(gcf, fullfile(savedir, 'mesh'), 'epsc');
export_fig(fullfile(savedir, 'mesh-bw'), '-png', '-m8');


% Plot entropy distribution distribution histogram; Figure 1, Panel C

f        = 'fn001078';
audiodir = d.audio;

% create combineddata data structure
dondersfile  = fullfile(audiodir, f, [f,'.donders']);
textgridfile = fullfile(audiodir, f, [f,'.TextGrid']);
combineddata = combine_donders_textgrid(dondersfile, textgridfile);

perplexity = [combineddata(:).entropy];

opt = {'save',              0, ...
       'language_features', {'log10wf' 'perplexity', 'entropy', 'word_'}, ...
       'audio_features',    {'audio_avg'}, ...
       'contrastvars',      {'entropy'}, ...
       'removeonset',       0, ...
       'shift',             0, ...
       'epochlength',       0.5, ...
       'overlap',           0};

[avgfeature, data_epoched, ~, ~, contrast] = streams_epochdefinecontrast(data, featuredata, audio, opt);

selfeature = ismember(avgfeature.trialinfolabel, 'entropy');

figure; h = histogram(avgfeature.trialinfo(:, selfeature)); box off; hold on;
set(gcf,'color','w');
set(h, 'facealpha', 1);

x  = [contrast.quantdvalue(1), contrast.quantdvalue(1)];
ax = gca;
y  = ax.YLim;
line(x, y, 'LineStyle', '--', 'Color', 'red', 'LineWidth', 2);

x  = [contrast.quantdvalue(2), contrast.quantdvalue(2)];
ax = gca;
y  = ax.YLim;
line(x, y, 'LineStyle', '--', 'Color', 'red', 'LineWidth', 2);

legend(sprintf('N = %d', size(contrast.trial, 1)));
export_fig(fullfile(savedir, 'entropy_distC'), '-eps');

