function [ map_object_category_id ] = get_mapping_object_category_id( scene_type, scene_mapping_file )
% This function assigns each object category an id. (by Zeinab Sadeghipour)

% scene_type = 'bedroom'
% scene_mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';

load(scene_mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);

sunrgbdmeta_file = 'SUNRGBDMeta.mat';
load(sunrgbdmeta_file);

map_object_category_id = struct('category_name',[], 'category_id',[]);
count_mapping = 1;

for mid = 1:total_size
    % check for the scene type
    if ~strcmp(map_scene_name_type(mid).sceneType, scene_type)
        continue
    end
    
    mid
    % get the object labels in each scene
    gt = SUNRGBDMeta(:,mid);
    gt3D = gt.groundtruth3DBB;
    if isempty(gt3D)
        continue
    end
    
    obj_labels = {gt3D(:).classname};
    unique_labels = unique(obj_labels); % have a unique vector of names for counting co-occurrence
    
    for lid = 1:size(unique_labels, 2)
        label = unique_labels{lid};
        
        % get a mapping between object categories name and id
        if isempty(find(strcmp(label, {map_object_category_id(:).category_name}),1)) % if the category is not assigned an id yet
            map_object_category_id(count_mapping).category_name = label;
            map_object_category_id(count_mapping).category_id = count_mapping;
            count_mapping = count_mapping + 1;
        end
    end
end

end

