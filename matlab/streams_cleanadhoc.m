function sel = streams_cleanadhoc(datain)
% streams_cleanadhoc() removes additional trials when at least five channels in the individual 
% trials's STD is exceeding 2, where the value of 2 is the STD of that chnnel's trial relative to the whole dataset
% 
% output: sel - selected trial indices to be used with ft_selectdata

% remove trials that, across the channel array, have high variance in the individual epochs
tmp = ft_channelnormalise([], datain);
S   = cellfun(@std,tmp.trial, repmat({[]},[1 numel(tmp.trial)]), repmat({2},[1 numel(tmp.trial)]), 'uniformoutput', false);
S   = cat(2,S{:});

sel = find(~(sum(S>2)>=5 | sum(S>3)>0)); % at least five channels for which the individual 
% trials's STD is exceeding 2, where the value of 2 is the relative STD of that chnnel's trial, relative to the whole dataset

clear tmp;
end


