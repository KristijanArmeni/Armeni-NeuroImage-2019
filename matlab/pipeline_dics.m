
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09'});

ivars     = {'entropy'};
freqbands = {'theta'};

datadir = '/project/3011085.04/streams/preproc/';
savedir = '/project/3011085.04/streams/analysis/freqanalysis/source/subject3';

%% WITH EPOCH = 0.5 S

% Subject loop
for k = 1:numel(freqbands)
    
    freqband = freqbands{k};
    
    for i = 1:numel(ivars)

    indepvar = ivars{i};
        
        for kk = 1:num_sub

        subject = subjects{kk};
        
        inpcfg = {'indepvar', indepvar, ...
                   'freqband', freqband, ...
                   'removeonset', 0, ...
                   'word_selection', 'all', ...
                   'epochtype', 'onset-ignore', ...
                   'epochlength', 0.5, ...
                   'shift', [0 200 400 600], ...
                   'savewhat', 'source', ...
                   'datadir', datadir, ...
                   'savedir', savedir};
        
        qsubfeval('streams_dics', subject, inpcfg, ...
                  'memreq', 1024^3*15,...
                  'timreq', 60*30, ...
                  'matlabcmd', 'matlab2016b', ...
                  'display', 'yes');
        
        end
    
        
    end
    
    
end

%% WITH EPOCH = 0.25 S

[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09'});

ivars     = {'entropy', 'perplexity'};
freqbands = {'beta'};

datadir = '/project/3011044.02/preproc/';
savedir = '/project/3011044.02/analysis/freqanalysis/source/subject4-0.25';

% Subject loop
for k = 1:numel(freqbands)
    
    freqband = freqbands{k};
    
    for i = 1:numel(ivars)

    indepvar = ivars{i};
        
        for kk = 1:num_sub

        subject = subjects{kk};
        
        inpcfg = {'indepvar', indepvar, ...
                   'freqband', freqband, ...
                   'removeonset', 0, ...
                   'word_selection', 'all', ...
                   'epochlength', 0.25, ...
                   'shift', [0 200 400 600], ...
                   'savewhat', 'source', ...
                   'datadir', datadir, ...
                   'savedir', savedir};
        
        qsubfeval('streams_dics', subject, inpcfg, ...
                  'memreq', 1024^3*15,...
                  'timreq', 60*30, ...
                  'matlabcmd', 'matlab2016b', ...
                  'display', 'yes');
        
        end
    
        
    end
    
    
end

%% With epochtype = 'onset-lock'

[subjects, num_sub] = streams_util_subjectstring(2:10, {'s06', 's09'});

ivars     = {'entropy', 'perplexity'};
freqbands = {'gamma', 'high-gamma'};

datadir = '/project/3011085.04/streams/preproc/';
savedir = '/project/3011085.04/streams/analysis/freqanalysis/source/subject3/onset_lock';

% Subject loop
for k = 1:numel(freqbands)
    
    freqband = freqbands{k};
    
    for i = 1:numel(ivars)

    indepvar = ivars{i};
        
        for kk = 1:num_sub

        subject = subjects{kk};
        
        inpcfg = {'indepvar', indepvar, ...
                   'freqband', freqband, ...
                   'removeonset', 0, ...
                   'word_selection', 'all', ...
                   'epochtype', 'onset-lock', ...
                   'epochlength', 0.5, ...
                   'shift', [0 200 400 600], ...
                   'savewhat', 'stat', ...
                   'datadir', datadir, ...
                   'savedir', savedir};
        
        qsubfeval('streams_dics', subject, inpcfg, ...
                  'memreq', 1024^3*40,...
                  'timreq', 60*40, ...
                  'matlabcmd', 'matlab2016b', ...
                  'display', 'yes');
        
        end
    
        
    end
    
    
end

%% With epochtype = 'onset-lock-nooverlap'

[subjects, num_sub] = streams_util_subjectstring(2:10, {'s06', 's09'});

ivars     = {'entropy', 'perplexity'};
freqbands = {'theta', 'alpha', 'beta', 'high-beta', 'gamma', 'high-gamma'};

datadir = '/project/3011085.04/streams/preproc/';
savedir = '/project/3011085.04/streams/analysis/freqanalysis/source/subject3/onset_lock_nooverlap';

% Subject loop
for k = 1:numel(freqbands)
    
    freqband = freqbands{k};
    
    for i = 1:numel(ivars)

    indepvar = ivars{i};
        
        for kk = 1:num_sub

        subject = subjects{kk};
        
        inpcfg = {'indepvar', indepvar, ...
                   'freqband', freqband, ...
                   'removeonset', 0, ...
                   'word_selection', 'all', ...
                   'epochtype', 'onset-lock-nooverlap', ...
                   'epochlength', 0.5, ...
                   'shift', [0 200 400 600], ...
                   'savewhat', 'stat', ...
                   'datadir', datadir, ...
                   'savedir', savedir};
        
        qsubfeval('streams_dics', subject, inpcfg, ...
                  'memreq', 1024^3*40,...
                  'timreq', 60*40, ...
                  'matlabcmd', 'matlab2016b', ...
                  'display', 'yes');
        
        end
    
        
    end
    
    
end

%% With epochtype = 'onset-lock-minoverlap'

[subjects, num_sub] = streams_util_subjectstring(11:28, {'s06', 's09'});

ivars     = {'entropy', 'perplexity'};
freqbands = {'theta', 'alpha', 'beta', 'high-beta', 'gamma', 'high-gamma'};

datadir = '/project/3011085.04/streams/preproc/';
savedir = '/project/3011085.04/streams/analysis/freqanalysis/source/subject3/onset_lock_minoverlap';

% Subject loop
for k = 1:numel(freqbands)
    
    freqband = freqbands{k};
    
    for i = 1:numel(ivars)

    indepvar = ivars{i};
        
        for kk = 1:num_sub

        subject = subjects{kk};
        
        inpcfg = {'indepvar', indepvar, ...
                   'freqband', freqband, ...
                   'removeonset', 0, ...
                   'word_selection', 'all', ...
                   'epochtype', 'onset-lock-minoverlap', ...
                   'epochlength', 0.5, ...
                   'shift', [0 200 400 600], ...
                   'savewhat', 'stat', ...
                   'datadir', datadir, ...
                   'savedir', savedir};
        
        qsubfeval('streams_dics', subject, inpcfg, ...
                  'memreq', 1024^3*20,...
                  'timreq', 60*40, ...
                  'matlabcmd', 'matlab2016b', ...
                  'display', 'yes');
        
        end
    
        
    end
    
    
end

%% Computing trl indx

[subjects, num_sub] = streams_util_subjectstring(11:28, {'s06', 's09'});

ivars     = {'entropy', 'perplexity'};
freqbands = {'theta', 'alpha', 'beta', 'high-beta', 'gamma', 'high-gamma'};

datadir = '/project/3011085.04/streams/preproc/';
savedir = '/project/3011085.04/streams/analysis/freqanalysis/source/subject3/onset_lock_minoverlap';

% Subject loop
for k = 1:numel(freqbands)
    
    freqband = freqbands{k};
    
    for i = 1:numel(ivars)

    indepvar = ivars{i};
        
        for kk = 1:num_sub

        subject = subjects{kk};
        
        inpcfg = {'indepvar', indepvar, ...
                   'freqband', freqband, ...
                   'removeonset', 0, ...
                   'word_selection', 'all', ...
                   'epochtype', 'onset-lock-minoverlap', ...
                   'epochlength', 0.5, ...
                   'shift', [0 200 400 600], ...
                   'savewhat', 'stat', ...
                   'datadir', datadir, ...
                   'savedir', savedir};
        
        qsubfeval('streams_dics', subject, inpcfg, ...
                  'memreq', 1024^3*20,...
                  'timreq', 60*40, ...
                  'matlabcmd', 'matlab2016b', ...
                  'display', 'yes');
        
        end
    
        
    end
    
    
end