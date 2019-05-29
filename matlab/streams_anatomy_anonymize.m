function streams_anatomy_anonymize(inpath, outpath)

% USE AS:
%
% streams_anonymyze_anatomy(inpath, outpath)
%
% INPUTS:
% 
% inpath:  string, path to where source and headmodel files are
% outpath: string, path to location for saving new files

suffix = {'_sourcemodel.mat', '_headmodel.mat'};

for i = 1:numel(suffix)

    filenames = dir(fullfile(inpath, ['*' suffix{i}]));
    filenames = filenames(~[filenames(:).isdir]);

    fprintf('Found %d %s files\n', numel(filenames), suffix{i})

    for j = 1:numel(filenames)

        % load in the file
        load(fullfile(filenames(j).folder, filenames(j).name))

        % Remove the .cfg (could contain pointers to MRIs)
        if exist('sourcemodel', 'var')

            if isfield(sourcemodel, 'cfg')
                sourcemodel = rmfield(sourcemodel, 'cfg');
                fprintf('Saving %s', fullfile(outpath, filenames(j).name))
                save(fullfile(outpath, filenames(j).name, 'sourcemodel')) 
            else
                fprintf('Cfg removal not needed for %s\n', filenames(j).name)
            end

        clear sourcemodel

        end

        if exist('headmodel', 'var')

            if isfield(headmodel, 'cfg')
                headmodel = rmfield(headmodel, 'cfg');
                fprintf('Saving %s\n', fullfile(outpath, filenames(j).name))
                save(fullfile(outpath, filenames(j).name), 'headmodel') 
            else
                fprintf('Cfg removal not needed for %s\n', filenames(j).name)
            end

        clear headmodel

        end

    end
        
end
    
end

        