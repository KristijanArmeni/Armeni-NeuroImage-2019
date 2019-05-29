
datadir = '/project/3011044.02/raw/stimuli/';

subtlex_table_filename    = fullfile(datadir, 'worddata_subtlex.mat');
subtlex_firstrow_filename = fullfile(datadir, 'worddata_subtlex_firstrow.mat');
load(subtlex_table_filename);
load(subtlex_firstrow_filename);

audiodir = '/project/3011044.02/lab/pilot/stim/audio';
stories  = streams_util_stories();
num_stories = numel(stories);

data = cell(1, 7);
data{1, 1} = 'story_ID';
data{1, 2} = 'word';
data{1, 3} = 'story_nr';
data{1, 4} = 'sentence_nr';
data{1, 5} = 'word_nr';
data{1, 6} = 'entropy';
data{1, 7} = 'perplexity';

%% story loop

sprintf('Creating data cell array via donders_combine_textgrid() for %d stories ...\n', num_stories)

for i = 1:num_stories
    
    story = stories{i};

    dondersfile = fullfile(audiodir, story, [story, '.donders']);
    textgridfile = fullfile(audiodir, story, [story, '.TextGrid']);
    
    % read in the model output
    datatmp   = combine_donders_textgrid(dondersfile, textgridfile);
    num_words = numel(datatmp);
    
    storytable = cell(num_words, 7);
    
    storytable(:, 1) = {story};           % story label string
    storytable(:, 2) = [datatmp(:).word]; % word string
    storytable(:, 3) = {i};               % story index
    storytable(:, 4) = {datatmp(:).sent_};               % sentence index
    storytable(:, 5) = {datatmp(:).word_};
    storytable(:, 6) = {datatmp(:).entropy};
    storytable(:, 7) = {datatmp(:).perplexity};
    
    % Append current story table rows to data table
    data = vertcat(data, storytable);
    
end

% % log transform perplexity values
% perplexity_col = find(strcmp(data(1, :), 'perplexity'));
% data(2: end, 7) = cellfun(@log10, data(2:end, perplexity_col), 'UniformOutput', 0);
% 
% data(1, perplexity_col) = {'lg10perp'};
data(1, 8) = {'lg10wf'}; % create the column for subtlex wordfrequencies
data(1, 9) = {'nchar'};

%% LOOK UP WORD FREQUENCIES AND NUMBER OF CHARACTERS IN SUBTLEX DATA

sprintf('Adding word frequencies and word length via add_subtlex() for %d stories and %d words in total...\n', num_stories, size(data, 1) - 1)
data = add_subtlex(data, subtlex_data, subtlex_firstrow);

%% SAVING

sprintf('saving \n %s \n %s \n %s \n', fullfile(datadir, 'language_data.mat'), fullfile(datadir, 'language_data.txt'), fullfile(datadir, 'language_data-noheader.txt'))

data_table = cell2table(data(2:end,:), 'VariableNames', data(1, :));
save(fullfile(datadir, 'language_data.mat'), 'data_table');
writetable(data_table, fullfile(datadir, 'language_data.txt'),'Delimiter', ',');
writetable(data_table, fullfile(datadir, 'language_data-noheader.txt'),'Delimiter', ',', 'WriteVariableNames', 0);

%% SUBFUNCTION
function [data] = add_subtlex(data, subtlex_data, subtlex_firstrow)

num_words = size(data, 1); % because the first row is header
data_word_column = find(strcmp(data(1,:), 'word')); % find where story words are

% check subtlex header for correct colums
subtlex_word_column = find(strcmp(subtlex_firstrow, 'spelling'));
subtlex_wlen_column = find(strcmp(subtlex_firstrow, 'nchar'));
subtlex_frequency_column = find(strcmp(subtlex_firstrow, 'Lg10WF'));

subtlex_words = subtlex_data(:, subtlex_word_column);
    
    % WORD LOOP
    for j = 2:num_words

        word = data(j, data_word_column);
        word = word{1};
        
        % find the row index in subtlex data table
        row = find(strcmp(subtlex_words, word)); 

        if ~isempty(row) 
             % lookup the according frequency values
             data{j, 8} = subtlex_data{row, subtlex_frequency_column}; 
             data{j, 9} = subtlex_data{row, subtlex_wlen_column};
             
        else % if it is a punctuation mark or a proper name etc., write nan (punctuation marks etc. do not appear in the subtlex table)
            
            data{j, 8} = nan; 
            data{j, 9} = nan;
            
        end

    end
    
end
