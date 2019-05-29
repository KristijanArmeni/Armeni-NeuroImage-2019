
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06'});

for j = 1:num_sub

    subject    = streams_subjinfo(subjects{j});
    audiofile = 'all';
    optarg = {'fsample', 300};

    qsubfeval('pipeline_preprocessing_broadband_qsub', subject, audiofile, optarg, ...
                      'memreq', 1024^3 * 12,...
                      'timreq', 240*60,...
                      'batchid', 'streams_preproc');


end

