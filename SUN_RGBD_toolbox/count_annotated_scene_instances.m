function [ scene_counts, avg_obj_counts ] = count_annotated_scene_instances( scene_type, mapping_file )
%This function counts the number of scenes of the specific type which have
%3D ground truth. (by Zeinab Sadeghipour)

% scene_type = 'bedroom';
% mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';

scene_counts = 0;
obj_counts = 0;
load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);
sunrgbdmeta_file = 'SUNRGBDMeta.mat';
load(sunrgbdmeta_file);

for mid = 1:total_size
    % check for the scene type
    if ~strcmp(map_scene_name_type(mid).sceneType, scene_type)
        continue
    end
    
    % check for having 3D ground truth
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D)
        continue;
    end
    
    scene_counts = scene_counts + 1;
    
    obj_labels = {gt3D(:).classname};
    obj_counts = obj_counts + length(obj_labels);
end

avg_obj_counts = obj_counts / scene_counts;

end

