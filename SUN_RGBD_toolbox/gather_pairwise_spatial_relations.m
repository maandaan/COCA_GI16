function [ co_spatial_relations, special_orientations ] = gather_pairwise_spatial_relations
% This function gathers data required to learn the pairwise spatial
% relations for co-occurring categories. (by Zeinab Sadeghipour)

% scene_type = 'bedroom';
% mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';

Consts;
load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);

sunrgbdmeta_file = 'SUNRGBDMeta.mat';
load(sunrgbdmeta_file);

[dummy, categories_count] = get_object_type_bedroom('');
%spatial_rel is a nx2 matrix with one column for distance and 2nd column:
%angle, in radians
co_spatial_relations = repmat(struct('spatial_rel',[]), categories_count, categories_count);

valid_rooms = 0;

% special orientations 
special_orient_count = 1;
special_orientations = struct('scene_index',[], 'first_obj_index',[],'first_obj_classname',[],...
    'second_obj_index',[],'second_obj_classname',[],'orient_type',[]);

for mid = 1:total_size
    % check for the scene type
    if ~strcmp(map_scene_name_type(mid).sceneType, scene_type)
        continue
    end
    
    % get the room diagonal for normalizing distances
    room_corners = SUNRGBDMeta(:,mid).gtCorner3D;
    if isempty(room_corners)
        continue
    end
    room_dims = [norm(room_corners(:,1) - room_corners(:,2)), ...
        norm(room_corners(:,2) - room_corners(:,3)), ...
        abs(room_corners(3,1) - room_corners(3,5))];
    room_diag = norm(room_dims);
    
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D)
        continue;
    end
    
    no_objects = size(gt3D,2);
    for oid = 1:no_objects
        
        this_centroid = gt3D(oid).centroid;
        this_orient = gt3D(oid).orientation;
        this_type = get_object_type_bedroom({gt3D(oid).classname});
        this_corners = get_corners_of_bb3d(gt3D(oid));
        this_dims = [norm(this_corners(1,:) - this_corners(2,:)), ...
                norm(this_corners(2,:) - this_corners(3,:)), ...
                abs(this_corners(1,3) - this_corners(5,3))];
        this_vol = prod(this_dims);
        this_area = this_dims(1) * this_dims(2);
        
        for pid = oid+1:no_objects
            pair_centroid = gt3D(pid).centroid;
            pair_orient = gt3D(pid).orientation;
            pair_type = get_object_type_bedroom({gt3D(pid).classname});
            pair_corners = get_corners_of_bb3d(gt3D(pid));
            pair_dims = [norm(pair_corners(1,:) - pair_corners(2,:)), ...
                norm(pair_corners(2,:) - pair_corners(3,:)), ...
                abs(pair_corners(1,3) - pair_corners(5,3))];
            pair_vol = prod(pair_dims);
            pair_area = pair_dims(1) * pair_dims(2);
            
            this_distance = norm(this_centroid - pair_centroid) ./ this_vol;
            pair_distance = norm(this_centroid - pair_centroid) ./ pair_vol;
            
            this_xy_dist = norm(this_centroid(1:2) - pair_centroid(1:2)) / this_area;
            pair_xy_dist = norm(this_centroid(1:2) - pair_centroid(1:2)) / pair_area;
            
            cos_angle = dot(this_orient, pair_orient) / (norm(this_orient) * norm(pair_orient));
            angle = acos( min(max(cos_angle, -1), 1) ); % for fixing the cases where the cos_angle = 1 or -1
            
            this_spatial_rel = co_spatial_relations(this_type, pair_type).spatial_rel;
            this_spatial_rel = [this_spatial_rel; this_distance this_xy_dist angle];
            co_spatial_relations(this_type, pair_type).spatial_rel = this_spatial_rel;
            
            pair_spatial_rel = co_spatial_relations(pair_type, this_type).spatial_rel;
            pair_spatial_rel = [pair_spatial_rel; pair_distance pair_xy_dist angle];
            co_spatial_relations(pair_type, this_type).spatial_rel = pair_spatial_rel;
            
            orient_type = 0;
            if abs(cos_angle) < 0.17 %80-100 degree
                orient_type = 1;
            elseif cos_angle < -0.98 %170-180 degree
                orient_type = 2;
            elseif cos_angle > 0.98 % 0-10 degree
                orient_type = 3;
            end
            
            if orient_type ~= 0
                special_orientations(special_orient_count).scene_index = mid;
                special_orientations(special_orient_count).first_obj_index = oid;
                special_orientations(special_orient_count).first_obj_classname = gt3D(oid).classname;
                special_orientations(special_orient_count).second_obj_index = pid;
                special_orientations(special_orient_count).second_obj_classname = gt3D(pid).classname;
                special_orientations(special_orient_count).orient_type = orient_type;
                special_orient_count = special_orient_count + 1;
            end
                
        end
    end
    
    valid_rooms = valid_rooms + 1;
end

save('data/training/SUNRGBD/bedroom_special_orientations_v2.mat', 'special_orientations');
valid_rooms
end

