clear all

if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = strsplit(sprintf('s%.2d ', 1:28));
subjects = subjects(~cellfun(@isempty, subjects));

s6 = strcmp(subjects, 's06');
subjects(s6) = []; % s06 dataset does not exist, empty it to prevent errors

num_sub = numel(subjects);
display(subjects);

pipeline = '2';

for j = 1:num_sub
        
        subject    = subjects{j};
        
        qsubfeval('check_headmovement', subject, ...
                          'memreq', 1024^3 * 5,...
                          'timreq', 30*60);


end