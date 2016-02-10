function gmm_weights = learn_weights_for_gmm
%LEARN_WEIGHTS_FOR_GMM computes the weights for the corresponding learned
%GMM distributions.

Consts_fisher;
load(fisher_scenes_file, 'fisher_scenes');

categories_count = 54; %from get_object_type_bedroom.m
gmm_weights = repmat(struct('frequency', 0, 'weight', 0), categories_count, categories_count);

for sid = 1:length(fisher_scenes)
    scene = fisher_scenes(sid).scene;
    
    for oid = 1:length(scene)
        obj = scene(oid);
        if isempty(obj.obj_type)
            continue
        end
        
        for ooid = 1:length(scene)
            pair = scene(ooid);
            if ooid == oid || isempty(pair.obj_type) ...
                    || pair.obj_type == get_object_type_bedroom({'room'})
                continue
            end
            
            curr_freq = gmm_weights(obj.obj_type, pair.obj_type).frequency;
            curr_freq = curr_freq + 1;
            gmm_weights(obj.obj_type, pair.obj_type).frequency = curr_freq;
        end
    end
end

for i = 1:size(gmm_weights,1)
    for j = 1:size(gmm_weights,2)
        gmm_weights(i,j).weight = gmm_weights(i,j).frequency / length(fisher_scenes);
    end
end

save(gmm_weights_file, 'gmm_weights');

end

