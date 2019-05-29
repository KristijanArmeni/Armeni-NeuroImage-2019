
clear all

if ~ft_hastoolbox('qsub',1)
    addpath /home/kriarm/git/fieldtrip/qsub;
end

subjects = strsplit(sprintf('s%.2d ', 11:12));
subjects = subjects(~cellfun(@isempty, subjects));

s6 = strcmp(subjects, 's06');
subjects(s6) = []; % s06 dataset does not exist, empty it to prevent errors

num_sub = numel(subjects);
display(subjects);

for i = 1:numel(subjects)
   
    subject = subjects{i};
    qsubfeval('streams_componentanalysis_fastica', subject, ...
                          'memreq', 1024^3 * 12,...
                          'timreq', 30*60);
    
end