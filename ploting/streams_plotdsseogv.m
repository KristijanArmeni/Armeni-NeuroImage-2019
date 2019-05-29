function streams_plotdsseogv(name, numcom)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

subj = streams_subjinfo(name);
hdr = ft_read_header(subj.dataset);
meglabel = ft_channelselection('MEG', hdr.label);
eogvdir = '/project/3011044.02/preproc/meg';

filename = fullfile(eogvdir, [name '_eogv.mat']);
load(filename);

comp.unmixing = unmixing;
comp.topo=mixing;
comp.topolabel=meglabel;

for k = 1:size(comp.topo,2)
  comp.label{k}=sprintf('component%0.2d',k);
end
comp.label=comp.label(:);

comp.trial{1} = avgcomp;
comp.time{1} = 1:size(avgcomp,2);
comp.time{1} = (1:126)./300;

cfg = [];
cfg.component = numcom;
cfg.title = 'auto';
cfg.layout = 'CTF275_helmet.mat';
ft_topoplotIC(cfg, comp);  

figure;
subplot(2, 1, 1);
plot(comp.time{1}, comp.trial{1}(numcom,:));
title([name ' comps']);
subplot(2, 1, 2);
plot(avgpre');
title([name ' avgpre']);

end

