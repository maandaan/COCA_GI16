function [ all_valid_sizes ] = collect_size_info( all_valid_sizes, scene_type )
%COLLECT_SIZE_INFO collects size information from SUNRGBD dataset.

Consts;
load(sunrgbdmeta_file);
load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);
% load(sample_size_fisher_file, 'sample_sizes');
% room_sample_size = sample_sizes(get_object_type_bedroom({'room'})).fisherDB_dims;

epsilon = 1;

for mid = 1:total_size
    % check for the scene type
    if ~strcmp(map_scene_name_type(mid).sceneType, scene_type)
        continue
    end
    
    % get the room diagonal
    room_corners = SUNRGBDMeta(:,mid).gtCorner3D;
    if ~isempty(room_corners)
        room_dims = [norm(room_corners(:,1) - room_corners(:,2)), ...
                     norm(room_corners(:,2) - room_corners(:,3)), ...
                     abs(room_corners(3,1) - room_corners(3,5))] * 100;
        room_diag = norm(room_dims);
        obj_ind = get_object_type_bedroom({'room'});
%         all_valid_sizes(obj_ind).diag_sum = all_valid_sizes(obj_ind).diag_sum + room_diag;
%         all_valid_sizes(obj_ind).instance_count = all_valid_sizes(obj_ind).instance_count + 1;
%         all_valid_sizes(obj_ind).max_w = max(all_valid_sizes(obj_ind).max_w, room_dims(1));
%         all_valid_sizes(obj_ind).min_w = min(all_valid_sizes(obj_ind).min_w, room_dims(1));
%         
%         all_valid_sizes(obj_ind).max_l = max(all_valid_sizes(obj_ind).max_l, room_dims(2));
%         all_valid_sizes(obj_ind).min_l = min(all_valid_sizes(obj_ind).min_l, room_dims(2));
%         
%         all_valid_sizes(obj_ind).max_h = max(all_valid_sizes(obj_ind).max_h, room_dims(3));
%         all_valid_sizes(obj_ind).min_h = min(all_valid_sizes(obj_ind).min_h, room_dims(3));
%         
        if ~(abs(room_dims(1) - 0) < epsilon || abs(room_dims(2) - 0) < epsilon)
            if room_dims(1) > room_dims(2)
                aspect_ratio = room_dims(1) / room_dims(2);
            else
                aspect_ratio = room_dims(2) / room_dims(1);
            end
            all_valid_sizes(obj_ind).max_aspectratio = max(all_valid_sizes(obj_ind).max_aspectratio, aspect_ratio);
            all_valid_sizes(obj_ind).min_aspectratio = min(all_valid_sizes(obj_ind).min_aspectratio, aspect_ratio);
        end
    end
    
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D)
        continue;
    end
    
    no_objects = size(gt3D,2);
    for oid = 1:no_objects
        corners = get_corners_of_bb3d(gt3D(oid));
        dims = [norm(corners(1,:) - corners(2,:)), ...
                norm(corners(2,:) - corners(3,:)), ...
                abs(corners(1,3) - corners(5,3))] * 100;
        diag = norm(dims);
        if isnan(diag)
            continue
        end
        obj_ind = get_object_type_bedroom({gt3D(oid).classname});
%         all_valid_sizes(obj_ind).max_w = max(all_valid_sizes(obj_ind).max_w, dims(1));
%         all_valid_sizes(obj_ind).min_w = min(all_valid_sizes(obj_ind).min_w, dims(1));
%         
%         all_valid_sizes(obj_ind).max_l = max(all_valid_sizes(obj_ind).max_l, dims(2));
%         all_valid_sizes(obj_ind).min_l = min(all_valid_sizes(obj_ind).min_l, dims(2));
%         
%         all_valid_sizes(obj_ind).max_h = max(all_valid_sizes(obj_ind).max_h, dims(3));
%         all_valid_sizes(obj_ind).min_h = min(all_valid_sizes(obj_ind).min_h, dims(3));
        
%         obj_sample_size = sample_sizes(obj_ind).fisherDB_dims;
        if abs(dims(1) - 0) < epsilon || abs(dims(2) - 0) < epsilon
            continue
        end
        if dims(1) > dims(2)
            aspect_ratio = dims(1) / dims(2);
        else
            aspect_ratio = dims(2) / dims(1);
        end
        all_valid_sizes(obj_ind).max_aspectratio = max(all_valid_sizes(obj_ind).max_aspectratio, aspect_ratio);
        all_valid_sizes(obj_ind).min_aspectratio = min(all_valid_sizes(obj_ind).min_aspectratio, aspect_ratio);
        
%         all_valid_sizes(obj_ind).diag_sum = all_valid_sizes(obj_ind).diag_sum + diag;
%         all_valid_sizes(obj_ind).instance_count = all_valid_sizes(obj_ind).instance_count + 1;
    end
end

end

