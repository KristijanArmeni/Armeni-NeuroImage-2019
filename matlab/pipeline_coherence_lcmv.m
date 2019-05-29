
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06', 's09'});

datadir   = '/project/3011044.02/preproc/';
savedir   = '/project/3011044.02/analysis/coherence/source/subject';

%% SUBJECT AND VARIABLE LOOP (ba42)
    
for k = 1:numel(subjects)

    subject = subjects{k};

    inputargs = {'savedir', savedir, ...
                 'datadir', datadir, ...
                 'roi', {'_42'}};

    qsubfeval('streams_coherence_lcmv', subject, inputargs, ...
                                                        'memreq', 1024^3 * 16,...
                                                        'timreq', 45*60);
end
        

%% COHERENCE FOR UPPER AND LOWER BANKS 

[subjects, num_sub] = streams_util_subjectstring([13:20, 22], {'s06', 's09'});

for k = 1:numel(subjects)

    subject = subjects{k};

    inputargs = {'savedir', savedir, ...
                 'datadir', datadir, ...
                 'roi', {'_40', '_42', '_43'}};

    qsubfeval('streams_coherence_lcmv', subject, inputargs, ...
                                                        'memreq', 1024^3 * 30,...
                                                        'timreq', 75*60);
end

    
%% COHERENCE FOR MAXIMAL DICS COHERENCE LOCATIONS

[subjects, num_sub] = streams_util_subjectstring([2:28], {'s06', 's09'});

for k = 1:numel(subjects)

    subject = subjects{k};

    inputargs = {'savedir', savedir, ...
                 'datadir', datadir, ...
                 'roi', {'dicsmax'}};

    qsubfeval('streams_coherence_lcmv', subject, inputargs, ...
                                                        'memreq', 1024^3 * 30,...
                                                        'timreq', 75*60);
end