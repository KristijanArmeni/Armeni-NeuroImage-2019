function pipeline_preprocessing_broadband_qsub(subject, audiofile, optarg)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

savedir = '/project/3011044.02/preproc/meg';

% preprocessing options
fsample = ft_getopt(optarg, 'fsample');
feature = {'sent_' 'word_' 'nchar' 'duration' 'log10wf'  'perplexity' 'entropy'};

%% Preprocessing, band-pass filtering, and downsampling

inpcfg = {'audiofile', audiofile, ...
          'feature', feature, ...
          'lpfreq', [], ...
          'hpfreq', [], ...
          'dftfreq', [49 51; 99 101; 149 151], ...
          'dospeechenvelope', 1, ...
          'word_quantify', 'noonset', ...)
          'fsample', fsample};

[~, ~, audio, ~] = streams_preprocessing(subject, inpcfg);
   
%% Saving

% savenamemeg = [subject.name '_meg'];
% savenamemeg = fullfile(savedir, savenamemeg);

% savenameeeg = [subject.name '_eeg'];
% savenameeeg = fullfile(savedir, savenameeeg);

% savenameaudio = [subject.name '_aud'];
% savenameaudio = fullfile(savedir, savenameaudio);

savenamefeaturedata = [subject.name '_featuredata4'];
savenamefeaturedata = fullfile(savedir, savenamefeaturedata);

datecreated = char(datetime('today', 'Format', 'dd-MM-yy'));
pipelinefilename = fullfile(savedir, ['s02_meg_' datecreated]);

% save the pipeline if not yet saved
if ~exist([pipelinefilename '.html'], 'file') && exist('data', 'var')
    cfgt = [];
    cfgt.filename = pipelinefilename;
    cfgt.filetype = 'html';
    ft_analysispipeline(cfgt, data);
end
    
% save(savenamemeg, 'data');
% save(savenameeeg, 'eeg');
% save(savenameaudio, 'audio');
save(savenamefeaturedata, 'featuredata', 'inpcfg');


end

