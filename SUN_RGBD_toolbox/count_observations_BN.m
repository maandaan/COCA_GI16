function [ mapping_nodes_names, variable_obs ] = count_observations_BN( scene_type, mapping_file )
% This function is to count the observations for variables which are going
% to be used to learn the Bayesian Network, nodes are #instances of each
% object category in the scenes. (by Zeinab Sadeghipour)

% scene_type = 'bedroom';
% mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';

load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);

sunrgbdmeta_file = '../SUNRGBD/code/SUNRGBDtoolbox/Metadata/SUNRGBDMeta.mat';
load(sunrgbdmeta_file);

nodes_count = 54; %from get_object_type_bedroom.m
for nid = 1:nodes_count
    category = get_object_type_bedroom(nid);
    mapping_nodes_names{nid} = [category{1} '_1'];
end
nodes_count = nodes_count + 2; %one for floor, one for wall
mapping_nodes_names{nodes_count -1} = 'floor_1';
floor_node_id = nodes_count - 1;
mapping_nodes_names{nodes_count} = 'wall_1';
wall_node_id = nodes_count;

annotated_scene_counts = count_annotated_scene_instances( scene_type, mapping_file );
variable_obs = zeros(nodes_count, annotated_scene_counts);

annotated_count = 0;
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
    annotated_count = annotated_count + 1;
    %we assume that in each scene, there are the floor and the walls
    variable_obs(floor_node_id, annotated_count) = 1;
    variable_obs(wall_node_id, annotated_count) = 1;
    
    obj_labels = {gt3D(:).classname};
    obj_types = get_object_type_bedroom(obj_labels);
    [unique_types, b, c] = unique(obj_types); % have a unique vector of names for counting co-occurrence
    count_uniques = hist(c, length(unique_types)); % count how many times each category is repeated
    
    for lid = 1:size(unique_types, 1)
        type = unique_types(lid);
        label_count = count_uniques(lid);
        variable_obs(type, annotated_count) = label_count;
    end
end

end

