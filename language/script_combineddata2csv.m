% This script reads in .donders and .TextGrid datafiles and creates
% stimuli_table.txt which is used as datafile for analyses in
% stimulus_info.R and figure_2.R (this script does same thing as
% language_combineddata2csv.m, but was created later as it adds .iscontent
% via streams_combinedata_iscontent.m to the table.
%
% written by: Kristijan Armeni

stories  = streams_util_stories();
audiodir = '/project/3011044.02/lab/pilot/stim/audio';
savedir  = '/project/3011044.02/raw/stimuli/stimuli_table.txt';

cbdat = struct('combineddata', 0);

for i = 1:numel(stories)

    f = stories{i};

    % create combineddata data structure
    dondersfile  = fullfile(audiodir, f, [f,'.donders']);
    textgridfile = fullfile(audiodir, f, [f,'.TextGrid']);
    combineddata = combine_donders_textgrid(dondersfile, textgridfile);

    % create story field
    storymat = repmat({f}, [numel(combineddata), 1]);
    [combineddata.story] = storymat{:};

    cbdat(i).combineddata = streams_combinedata_iscontent(combineddata);

end

joint = vertcat(cbdat(:).combineddata);

% create table
t = struct2table(joint);
writetable(t, savedir)
