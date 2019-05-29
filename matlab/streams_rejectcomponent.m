function [data] = streams_rejectcomponent(subject)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

subjectfull = streams_subjinfo(subject);
datadir = '/project/3011044.02/preproc/meg';

datafile = fullfile(datadir, [subject '_meg.mat']);
compfile = fullfile(datadir, [subject '_comp.mat']);

load(datafile);
load(compfile);

selcomp = subjectfull.eogv.badcomps;

if ~isempty(selcomp)
    cfg = [];
    cfg.component = selcomp;
    data = ft_rejectcomponent(cfg, comp, data);
end

savename = fullfile(datadir, [subject '_meg-clean']);
save(savename, 'data');
end

