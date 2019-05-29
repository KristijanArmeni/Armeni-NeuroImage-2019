% This script is used to read in story and word data from .donders and
% .Textgrid files (via combine_donders_textgrid) and write the obtained .mat
% structures as csv files (all and words only). The words-only files is
% used as input to Subtlex database in order to get the word frequencies.

audiodir = '/project/3011044.02/lab/pilot/stim/audio';
stories = {'fn001078', 'fn001155', 'fn001172', 'fn001293', 'fn001294', 'fn001443', 'fn001481', 'fn001498'};
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
for i = 1:num_stories
    
    story = stories{i};

    dondersfile = fullfile(audiodir, story, [story, '.donders']);
    textgridfile = fullfile(audiodir, story, [story, '.TextGrid']);
    
    % read in the model output
    datatmp = combine_donders_textgrid(dondersfile, textgridfile);
    num_words = numel(datatmp);
    
    storymat = cell(num_words, 7);
    
    % word loop
    for k = 1:num_words
        
       storymat{k,1} = story;
       storymat{k,2} = datatmp(k).word{1}; % word string
       storymat{k,3} = i; % story index
       storymat{k,4} = datatmp(k).sent_;
       storymat{k,5} = datatmp(k).word_;
       storymat{k,6} = datatmp(k).entropy;
       storymat{k,7} = datatmp(k).perplexity;

    end
    
    data = vertcat(data, storymat);
    
end

%% write into w csv
fid = fopen('storydata.txt', 'w');

fprintf(fid, '%s\t', data{1,1:end-1});
fprintf(fid, '%s\t\n', data{1,end}) ;

formatspec = '%s\t %s\t %d\t %d\t %d\t %d\t %d\n';
[nrow, ~] = size(data);

% fileID = fopen('storydata.csv', 'w');
for row = 2:nrow

   fprintf(fid, formatspec, data{row,:});

end
fclose(fid);

% words only
fid = fopen('storydata_wordsonly.txt', 'w');
formatspec = '%s\n';
[nrow, ncol] = size(data);

% fileID = fopen('storydata.csv', 'w');
for row = 1:nrow

   fprintf(fid, formatspec, data{row, 2});

end
fclose(fid);
