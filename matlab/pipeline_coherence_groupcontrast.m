
indepvars = {'entropy'};
datadir   = '/project/3011044.02/analysis/coherence/source/subject';
savedir   = '/project/3011044.02/analysis/coherence/source/group';
suffix    = '2';
sep       = '_';

%% SUBJECT AND VARIABLE LOOP

for i = 1:numel(indepvars)

    indepvar = indepvars{i};
    
    fname = [indepvar sep suffix];
    qsubfeval('streams_coherence_groupcontrast', fname, datadir, savedir, ...
                                           'memreq', 1024^3 * 16, ...
                                           'timreq', 45*60);

end
    