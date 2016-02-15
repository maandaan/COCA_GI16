function [ all_valid_sizes ] = collect_size_info( all_valid_sizes, scene_type )
%COLLECT_SIZE_INFO collects size information from SUNRGBD dataset.

Consts;
load(sunrgbdmeta_file);
load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);

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
        if abs(room_dims(1) - 0) < epsilon || abs(room_dims(2) - 0) < epsilon
            continue
        end
        wl_ratio = room_dims(2) / room_dims(1);
        all_valid_sizes(obj_ind).max_wlratio = max(all_valid_sizes(obj_ind).max_wlratio, wl_ratio);
        all_valid_sizes(obj_ind).min_wlratio = min(all_valid_sizes(obj_ind).min_wlratio, wl_ratio);
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
        
        if abs(dims(1) - 0) < epsilon || abs(dims(2) - 0) < epsilon
            continue
        end
        wl_ratio = dims(2) / dims(1);
        all_valid_sizes(obj_ind).max_wlratio = max(all_valid_sizes(obj_ind).max_wlratio, wl_ratio);
        all_valid_sizes(obj_ind).min_wlratio = min(all_valid_sizes(obj_ind).min_wlratio, wl_ratio);
        
%         all_valid_sizes(obj_ind).diag_sum = all_valid_sizes(obj_ind).diag_sum + diag;
%         all_valid_sizes(obj_ind).instance_count = all_valid_sizes(obj_ind).instance_count + 1;
    end
end

end

