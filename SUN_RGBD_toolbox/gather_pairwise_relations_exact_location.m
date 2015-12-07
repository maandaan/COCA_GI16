function [ pair_spatial_rels_location ] = gather_pairwise_relations_exact_location
%GATHER_PAIRWISE_RELATIONS_EXACT_LOCATION collects pairwise spatial
%relations between objects including the angle and the relative location
%(the coordinates of an object center in another one's frame)

Consts;

load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);

load(sunrgbdmeta_file);

categories_count = 54; %from get_object_type_bedroom.m
%spatial_rel is a nx4 matrix with three columns for relative locations and 4th column:
%angle, in radians
pair_spatial_rels_location = repmat(struct('spatial_rel',[]), categories_count, categories_count);

valid_rooms = 0;

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
        abs(room_corners(3,1) - room_corners(3,5))] * 100;
    room_diag = norm(room_dims);
    
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D)
        continue;
    end
    
    no_objects = size(gt3D,2);
    for oid = 1:no_objects
        
        this_centroid = gt3D(oid).centroid .* 100;
        this_orient = gt3D(oid).orientation;
        this_type = get_object_type_bedroom({gt3D(oid).classname});
%         this_corners = get_corners_of_bb3d(gt3D(oid));
%         this_dims = max(this_corners) - min(this_corners);
%         this_vol = prod(this_dims);
%         this_area = this_dims(1) * this_dims(2);
        
%         rotation_mat = convert_coordinates(this_orient);
        
        for pid = oid+1:no_objects
            pair_centroid = gt3D(pid).centroid .* 100;
            pair_orient = gt3D(pid).orientation;
            pair_type = get_object_type_bedroom({gt3D(pid).classname});
%             pair_rotation_mat = convert_coordinates(pair_orient);
%             pair_corners = get_corners_of_bb3d(gt3D(pid));
%             pair_dims = max(pair_corners) - min(pair_corners);
%             pair_vol = prod(pair_dims);
%             pair_area = pair_dims(1) * pair_dims(2);
            
            pair_relative_centroid = convert_coordinates(this_centroid, this_orient, pair_centroid);
            this_relative_centroid = convert_coordinates(pair_centroid, pair_orient, this_centroid);

            displacement = (this_centroid - pair_centroid) ./ room_diag; 

            cos_angle = dot(this_orient, pair_orient) / (norm(this_orient) * norm(pair_orient));
            angle = acos( min(max(cos_angle, -1), 1) ); % for fixing the cases where the cos_angle = 1 or -1
            angle = radtodeg(angle);
            
            this_spatial_rel = pair_spatial_rels_location(this_type, pair_type).spatial_rel;
%             this_spatial_rel = [this_spatial_rel; displacement angle];
            this_spatial_rel = [this_spatial_rel; pair_relative_centroid angle];
            pair_spatial_rels_location(this_type, pair_type).spatial_rel = this_spatial_rel;
            
            pair_spatial_rel = pair_spatial_rels_location(pair_type, this_type).spatial_rel;
%             pair_spatial_rel = [pair_spatial_rel; -displacement angle];
            pair_spatial_rel = [pair_spatial_rel; this_relative_centroid angle];
            pair_spatial_rels_location(pair_type, this_type).spatial_rel = pair_spatial_rel;
                           
        end
    end
end
save(pairwise_locations_file, 'pair_spatial_rels_location')
end


