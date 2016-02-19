function gmm_weights = learn_weights_for_gmm_SUNRGBD
%LEARN_WEIGHTS_FOR_GMM_SUNRGBD Summary of this function goes here
%   Detailed explanation goes here

Consts_fisher;
load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);

load(sunrgbdmeta_file);

categories_count = 54; %from get_object_type_bedroom.m
gmm_weights = repmat(struct('frequency', 0, 'weight', 0), categories_count, categories_count);

room_type = get_object_type_bedroom({'room'});

valid_rooms = 0;
for mid = 1:total_size
    % check for the scene type
    if ~strcmp(map_scene_name_type(mid).sceneType, scene_type)
        continue
    end
    
    % get the object labels in each scene
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D)
        continue;
    end
    valid_rooms = valid_rooms + 1;
    
    obj_labels = {gt3D(:).classname};
    obj_types = get_object_type_bedroom(obj_labels);
    
    for oid = 1:length(obj_types)
        %the pair with room
        
        curr_freq = gmm_weights(room_type, obj_types(oid)).frequency;
        curr_freq = curr_freq + 1;
        gmm_weights(room_type, obj_types(oid)).frequency = curr_freq;
            
        for ooid = 1:length(obj_types)
            if ooid == oid || obj_types(ooid) == room_type
                continue
            end
            
            curr_freq = gmm_weights(obj_types(oid), obj_types(ooid)).frequency;
            curr_freq = curr_freq + 1;
            gmm_weights(obj_types(oid), obj_types(ooid)).frequency = curr_freq;
        end
    end
end

for i = 1:size(gmm_weights,1)
    for j = 1:size(gmm_weights,2)
        gmm_weights(i,j).weight = (gmm_weights(i,j).frequency) .^ (30/valid_rooms);
    end
end

save(gmm_weights_file_SUNRGBD, 'gmm_weights');

end

