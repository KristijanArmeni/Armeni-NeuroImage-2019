%% Import data from text file.
% Script for importing data from the following text file:
%
%    /project/3011044.02/data/language/worddata_subtlex.txt
%
% The output is used in language_data.m to add the Subtlex frequencies to
% storydata

% Initialize variables.

savedir = '/project/3011044.02/data/language/';
filename = '/project/3011044.02/data/language/worddata_subtlex.txt';
headername = '/project/3011044.02/data/language/worddata_subtlex_header.txt';
delimiter = ';';
startRow = 2;

% Format for each line of text:

formatSpec = '%q%f%f%f%f%[^\n\r]';
headerSpec = '%s%s%s%s%s';

% Open the text file.

fileID = fopen(filename,'r');
fileIDheader = fopen(headername, 'r');

% Read columns of data according to the format

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
headerArray = textscan(fileIDheader, headerSpec, 'Delimiter', delimiter);

% Close the text file.
fclose(fileID);
fclose(fileIDheader);

% Create output variable
dataArray([2, 3, 4, 5]) = cellfun(@(x) num2cell(x), dataArray([2, 3, 4, 5]), 'UniformOutput', false);
subtlex_data = [dataArray{1:end-1}];

subtlex_firstrow = cellfun(@char, headerArray, 'UniformOutput', false);

% save output
save(fullfile(savedir, 'worddata_subtlex'), 'subtlex_data');
save(fullfile(savedir, 'worddata_subtlex_firstrow'), 'subtlex_firstrow');