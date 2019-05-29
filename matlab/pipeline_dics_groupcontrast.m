
ivars  = {'entropy', 'perplexity'};
fois   = {'10'};

%% Analysis for separate freq bands
datadir = '/project/3011044.02/analysis/freqanalysis/source/subject3';
savedir = '/project/3011044.02/analysis/freqanalysis/source/group4';

for i = 1:numel(ivars)
    
    ivar = ivars{i};
    
    for ii = 1:numel(fois)
        
        foi = fois{ii};
                        
        opt = {'ivar', ivar, ...
               'foi', foi, ...
               'savedir', savedir, ...
               'datadir', datadir};

        qsubfeval('streams_dics_groupcontrast', opt, ...
                  'memreq', 1024^3 * 5,...
                  'timreq', 45*60, ...
                  'matlabcmd', 'matlab2016b');

        
    end
    
end

%% Analysis across frequency bands, set fixed randomseed

datadir = '/project/3011044.02/analysis/freqanalysis/source/subject3';
savedir = '/project/3011044.02/analysis/freqanalysis/source/group4-combinedfreq';

ivars   = {'entropy', 'perplexity'};
fois    = {'6', '10', '16', '25', '45', '75'};

state = rng;

for i = 1:numel(ivars)
    
    ivar = ivars{i};
    
     for ii = 1:numel(fois)
        
        foi = fois{ii};
                        
        opt = {'ivar', ivar, ...
               'foi', foi, ...           % take all frequency bands
               'setseed', state.State, ...
               'savedir', savedir, ...
               'datadir', datadir};

        qsubfeval('streams_dics_groupcontrast_combined', opt, ...
                  'memreq', 1024^3 * 5,...
                  'timreq', 45*60, ...
                  'matlabcmd', 'matlab2016b');

     end
    
end

%% Analysis with onset locked timings

datadir = '/project/3011085.04/streams/analysis/freqanalysis/source/subject3/onset_lock_minoverlap';
savedir = '/project/3011085.04/streams/analysis/freqanalysis/source/group4-combinedfreq/onset_lock_minoverlap';

ivars   = {'entropy', 'perplexity'};
fois    = {'6', '10', '16', '25', '45', '75'};

state = rng;

for i = 1:numel(ivars)
    
    ivar = ivars{i};
    
     for ii = 1:numel(fois)
        
        foi = fois{ii};
                        
        opt = {'ivar', ivar, ...
               'foi', foi, ...           % take all frequency bands
               'setseed', state.State, ...
               'savedir', savedir, ...
               'datadir', datadir};

        qsubfeval('streams_dics_groupcontrast_combined', opt, ...
                  'memreq', 1024^3 * 5,...
                  'timreq', 45*60, ...
                  'matlabcmd', 'matlab2016b');

     end
    
end

