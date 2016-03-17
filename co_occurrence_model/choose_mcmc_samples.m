function [ sample_score, sample_objects ] = choose_mcmc_samples( ...
    all_score, nodes_sets, obj_count, sample_count, descending )
%CHOOSE_MCMC_SAMPLES picks top "sample_count" from MCMC generated samples.

% index = find(all_score == 0);
% if ~isempty(index)
%     all_score = all_score(1:index(1)-1);
% end
if descending
    [sorted_scores, sorted_ind] = sort(all_score, 'descend');
else
    [sorted_scores, sorted_ind] = sort(all_score);
end
sorted_nodes_sets = nodes_sets(sorted_ind);
count = 0;

sid = 0;
sample_score = [];
sample_objects = [];
obj_count = obj_count;

while count < sample_count && sid < length(sorted_nodes_sets) - 1
    sid = sid + 1;
    sample = sorted_nodes_sets(sid).nodes;
    
    if length(sample) ~= obj_count %not enough number of objects in the sample
        continue
    end
    
    if ~isempty(find(ismember([37:46,107:109,218], sample))) %door, window, cushion, other in the objects
        continue
    end
    
    if length(sample_objects) > 0 && ...
            ~isempty(structfind(sample_objects, 'nodes', sample)) %sample is already inserted in the scene
        continue
    end
    
    count = count + 1;
    sample_objects(count).nodes = sample;
    sample_score(count) = sorted_scores(sid);
end

end

