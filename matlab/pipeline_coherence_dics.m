
[subjects, num_sub] = streams_util_subjectstring(02:28, {'s06', 's09'});

indepvars = {'entropy'};
datadir   = '/project/3011044.02/preproc/';
savedir   = '/project/3011044.02/analysis/coherence/source/subject';
freqbands = {'high-beta', 'gamma', 'high-gamma'};

%% SUBJECT AND VARIABLE LOOP

for i = 1:numel(indepvars)

    indepvar = indepvars{i};
    
    for h = 1:numel(freqbands)
        
        freqband = freqbands{h};
    
        for k = 1:numel(subjects)

            subject = subjects{k};

            inputargs = {'indepvar', indepvar, ...
                         'freqband', freqband, ...
                         'docontrast', 'no', ...
                         'shift', 0, ...
                         'word_selection', 'all', ...
                         'savedir', savedir, ...
                         'datadir', datadir};

            qsubfeval('streams_coherence_dics', subject, inputargs, ...
                                                                'memreq', 1024^3 * 16,...
                                                                'timreq', 45*60);
        end
        
    end
    
end
    