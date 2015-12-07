function [ ranking ] = rank_candidates( scene_labels, candidate_objs, instance_freq_file, co_occurrence_file )
% This function gets a scene composed of a set of object labels and also a
% list of candidate object categories and computes the ranking for
% candidates to appear in the scene based on the co-occurrence model. 
% input:    
%   scene_labels: nx1 cell array of object labels in the current scene
%   candidate_objs = mx1 cell array of candidate object labels
% output:
%   ranking: mx1 struct array of candidate labels, their ids, and their
%   probabilities, sorted
% (by Zeinab Sadeghipour)

% instance_freq_file =
% 'data/training/SUNRGBD/bedroom_instance_frequency.mat';
% co_occurrence_file = 'data/training/SUNRGBD/bedroom_co_occurrence.mat';

load(instance_freq_file, 'instances_freq');
load(co_occurrence_file, 'co_occurrence');

no_candidates = size(candidate_objs, 1);
probabilities = zeros(no_candidates, 1);

[unique_scene_labels, orig_unique_ind, unique_orig_ind] = unique(scene_labels);
count_uniques = hist(unique_orig_ind, length(unique_scene_labels));
no_objects = size(unique_scene_labels, 1);

%count the number of bedroom instances with 3D ground truth
mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';
scene_counts = count_annotated_scene_instances( 'bedroom', mapping_file );

for cid = 1:no_candidates
    candidate = candidate_objs{cid};
    candidate_typeid = get_object_type_bedroom({candidate});
    
    % check the current instances of the candidate category in the scene
    if isempty(find(strcmp(candidate, unique_scene_labels),1))
        no_instance = 1;
    else
        no_instance = count_uniques(find(strcmp(candidate, unique_scene_labels),1)) + 1;
    end
    
    % the probability of having the specific number of instances of the
    % candidate in the scene
    freq = instances_freq(candidate_typeid).freq;
    if length(freq) < no_instance
        prob_occur = 0;
    else
        prob_occur = freq(no_instance) ./ scene_counts;
    end
        
    prob_co_occur = 0;
    for oid = 1:no_objects
        co_occur_obj = unique_scene_labels{oid};
        co_occur_obj_type = get_object_type_bedroom({co_occur_obj});
        
        if strcmp(candidate, co_occur_obj)
            continue
        end
        
        %compute a conditional probability
        denominator = sum(instances_freq(co_occur_obj_type).freq);
        this_prob_co_occur = co_occurrence(co_occur_obj_type, candidate_typeid) ./ denominator;
        prob_co_occur = max(prob_co_occur, this_prob_co_occur);
    end
    
%     probabilities(cid,1) = max(min(prob_occur*2,1), prob_co_occur);
    probabilities(cid,1) = prob_occur * prob_co_occur;
end

[sorted_prob, I] = sort(probabilities, 'descend');
for i = 1:no_candidates
    ranking(i).label = candidate_objs{I(i)};
    ranking(i).type = get_object_type_bedroom({ranking(i).label});
    ranking(i).probability = sorted_prob(i);
end

end

