
[subjects, num_sub] = streams_util_subjectstring(2:28, {'s06'});

for i = 1:num_sub
    
    subject = subjects{i};
    qsubfeval('streams_rejectcomponent', subject, ...)
                          'memreq', 1024^3 * 5,...
                          'timreq', 30*60);

end