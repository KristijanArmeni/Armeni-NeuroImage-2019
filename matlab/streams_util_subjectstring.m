function [subjects, n] = streams_util_subjectstring(inpsubjects, excludesubjects)
%streams_util_subjectstring(inpsubjects, excludesubjects) creates a cell array of subject strings
% of the form 'sXX' from the input integer XX as given in argument <inpsubjects>. Excludesubjects must be given
%as a string of the from sYY.
% 
% example:
% 
% [subjects, n] = streams_util_subjectstring([1 2 3], 's02')
% returns:
% 
% subjects =
% 
%   1×2 cell array
% 
%     's01'    's03'
% 

subjects = strsplit(sprintf('s%.2d ', inpsubjects));
subjects = subjects(~cellfun(@isempty, subjects));

exclude = ismember(subjects, excludesubjects);
subjects(exclude) = [];

n = numel(subjects);
display(subjects);

end

