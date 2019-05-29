function [ combineddataout ] = streams_combinedata_iscontent( combineddatain )
%streams_combinedata_iscontent() adds .iscontent field to the combineddata
% structure indicating whether or not the word is content or function word
% based on the Corpus Gesproken Dutch (CGN) POS tag system
% 
% CGN tag system reference:
% https://pdfs.semanticscholar.org/f3b4/676b6ce2f16883c3b8253b8b8cb312576db9.pdf

combineddataout = combineddatain;

% add content word field
% CGN tag system here: https://pdfs.semanticscholar.org/f3b4/676b6ce2f16883c3b8253b8b8cb312576db9.pdf

% WW  - werkworden    - verbs
% N   - substantieven - nouns
% ADJ - adjectieven   - adjectives
% BW  - bijworden     - adverbs
content = {'N', 'WW', 'ADJ', 'BW'}; 

% LET() - leestekens      - punctuation
% VG()  - voegworden      - conjunctions
% LID() - lidworden       - articles
% TSW() - tussenverpsels  - interjections
% VZ()  - voorzetsels     - prepositions
% TW()  - teelworden      - numerals
% VNW() - voornaamwoorden - pronouns
closed  = {'LET', 'VZ', 'LID', 'VG', 'TSW', 'TW', 'VNW', 'SPEC'};  

fulltags = {combineddatain(:).POS};                  % make a cell array from struct fields
wordPOS  = cellfun(@(x) strtok(x, '('), fulltags); % retain only the string before the parenthesis

classvec = num2cell(ismember(wordPOS, content)); % create a logical cell array

[combineddataout(1:end).iscontent] = classvec{:};

end

