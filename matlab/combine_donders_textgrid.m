function [ combined_data ] = combine_donders_textgrid( donders_path, textgrid_path )

% COMBINE_DONDERS_TEXTGRID combines the data from the .donders file, which
% contains the outputs of linguistic parsers with the timing information
% from the textgrid data.
%
% Use as
%   [combined_data] = combine_donders_textgrid(filename_d, filename_t)
%
% Input arguments:
%   filename_d = string, filename pointing to a *.donders file
%   filename_t = string, filename pointing to the corresponding *.textgrid
%                 file
%
% Output argument:
%   combined_data = struct-array that contains the combined data, i.e. the
%                    donders-file based struct-array with the timing
%                    information added.

if nargin<2,
  % only a 'fnXXXXX' is given, make a smart guess
  [p,f,e] = fileparts(donders_path);
  if isempty(p)
    p = fullfile('/project/3011044.02/lab/pilot/stim/audio',f);
  end
  
  textgrid_path = fullfile(p,[f,'.TextGrid']);
  donders_path  = fullfile(p,[f,'.donders']);
end
  
[~,f1,e] = fileparts(textgrid_path);
[~,f2,e] = fileparts(donders_path);
if ~strcmp(f1,f2)
  error('the filenames of the textgrid data and the donders data are different, and probably refer to different audio files');
end

textgrid_data = read_textgrid(textgrid_path);
donders_data  = read_donders(donders_path);
combined_data = donders_data;


%for each word, get the start time from the textgrid file and add it to the
% the new field in the combined data structure.
words1 = textgrid_data(1).words;
for i=1:numel(words1)
  words1{i} = strrep(words1{i},'"','');
end
words2 = [donders_data.word]';

sel = 0;
for i=1:numel(words2)
  % select the matching words, exclude '.'
  %if strcmp(words2{i},'.')
  %  continue;
  %end
  tmp = strcmp(words2{i}, words1);
  tmp(1:sel) = false;
  sel = find(tmp,1,'first');
  
  combined_data(i).start_time = textgrid_data(1).times(sel, 1);
  combined_data(i).end_time   = textgrid_data(1).times(sel, 2);
end
