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
pair_spatial_rels_location = repmat(struct('spatial_rel',[], 'SUNRGBD_info',[], ...
    'SUNRGBDMeta_index', []), categories_count, categories_count);

valid_rooms = 0;

for mid = 9174:9174%total_size
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
    room_orient = [0, 1, 0];
    room_type = get_object_type_bedroom({'room'});
    room_centroid = (mean(room_corners,2)') .* 100;
    room_cos = room_orient(2);
    room_sin = -room_orient(1);
    
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D)
        continue;
    end
    
    no_objects = size(gt3D,2);
    for oid = 1:no_objects
        
        this_centroid = gt3D(oid).centroid .* 100;
        this_orient = gt3D(oid).orientation;
        this_type = get_object_type_bedroom({gt3D(oid).classname});
        this_corners = get_corners_of_bb3d(gt3D(oid));
        this_dims = [norm(this_corners(1,:) - this_corners(2,:)), ...
                     norm(this_corners(2,:) - this_corners(3,:)), ...
                     abs(this_corners(1,3) - this_corners(5,3))] * 100;

        % relative location to room
        obj_rel_centroid = convert_coordinates(room_centroid, room_cos, room_sin, this_centroid);
        %normalizing
        obj_rel_centroid = [obj_rel_centroid(1)/(room_dims(1)/2), ...
                            obj_rel_centroid(2)/(room_dims(2)/2), ...
                            obj_rel_centroid(3)/(room_dims(3)/2)];
                        
        cos_angle = dot(this_orient, room_orient) / (norm(this_orient) * norm(room_orient));
        angle = acos( min(max(cos_angle, -1), 1) ); % for fixing the cases where the cos_angle = 1 or -1
        angle = radtodeg(angle);
        if isempty(find(obj_rel_centroid == Inf)) && isempty(find(obj_rel_centroid == -Inf))
            temp = pair_spatial_rels_location(room_type, this_type).SUNRGBD_info;
            temp = [temp; SUNRGBDMeta(:,mid)];
            pair_spatial_rels_location(room_type, this_type).SUNRGBD_info = temp;
            
            temp = pair_spatial_rels_location(room_type, this_type).SUNRGBDMeta_index;
            temp = [temp; mid];
            pair_spatial_rels_location(room_type, this_type).SUNRGBDMeta_index = temp;
            
            room_spatial_rel = pair_spatial_rels_location(room_type, this_type).spatial_rel;
            room_spatial_rel = [room_spatial_rel; obj_rel_centroid angle];
            pair_spatial_rels_location(room_type, this_type).spatial_rel = room_spatial_rel;
        end

        for pid = oid+1:no_objects
            pair_centroid = gt3D(pid).centroid .* 100;
            pair_orient = gt3D(pid).orientation;
            pair_type = get_object_type_bedroom({gt3D(pid).classname});
            pair_corners = get_corners_of_bb3d(gt3D(pid));
            pair_dims = [norm(pair_corners(1,:) - pair_corners(2,:)), ...
                         norm(pair_corners(2,:) - pair_corners(3,:)), ...
                         abs(pair_corners(1,3) - pair_corners(5,3))] * 100;
            
            this_cos = this_orient(2) / norm(this_orient);
            this_sin = -this_orient(1) / norm(this_orient);
            pair_cos = pair_orient(2) / norm(pair_orient);
            pair_sin = -pair_orient(1) / norm(pair_orient);

            pair_relative_centroid = convert_coordinates(this_centroid, this_cos, this_sin, pair_centroid);
            this_relative_centroid = convert_coordinates(pair_centroid, pair_cos, pair_sin, this_centroid);
            
            %normalizing
            pair_relative_centroid = [pair_relative_centroid(1)/(this_dims(1)/2), ...
                                      pair_relative_centroid(2)/(this_dims(2)/2), ...
                                      pair_relative_centroid(3)/(this_dims(3)/2)];
            this_relative_centroid = [this_relative_centroid(1)/(pair_dims(1)/2), ...
                                      this_relative_centroid(2)/(pair_dims(2)/2), ...
                                      this_relative_centroid(3)/(pair_dims(3)/2)];

            displacement = (this_centroid - pair_centroid) ./ room_diag; 

            cos_angle = dot(this_orient, pair_orient) / (norm(this_orient) * norm(pair_orient));
            angle = acos( min(max(cos_angle, -1), 1) ); % for fixing the cases where the cos_angle = 1 or -1
            angle = radtodeg(angle);
            
            %this_type, pair_type
            temp = pair_spatial_rels_location(this_type, pair_type).SUNRGBD_info;
            temp = [temp; SUNRGBDMeta(:,mid)];
            pair_spatial_rels_location(this_type, pair_type).SUNRGBD_info = temp;
            
            temp = pair_spatial_rels_location(this_type, pair_type).SUNRGBDMeta_index;
            temp = [temp; mid];
            pair_spatial_rels_location(this_type, pair_type).SUNRGBDMeta_index = temp;
            
            this_spatial_rel = pair_spatial_rels_location(this_type, pair_type).spatial_rel;
            this_spatial_rel = [this_spatial_rel; pair_relative_centroid angle];
            pair_spatial_rels_location(this_type, pair_type).spatial_rel = this_spatial_rel;
            
            %pair_type, this_type
            temp = pair_spatial_rels_location(pair_type, this_type).SUNRGBD_info;
            temp = [temp; SUNRGBDMeta(:,mid)];
            pair_spatial_rels_location(pair_type, this_type).SUNRGBD_info = temp;
            
            temp = pair_spatial_rels_location(pair_type, this_type).SUNRGBDMeta_index;
            temp = [temp; mid];
            pair_spatial_rels_location(pair_type, this_type).SUNRGBDMeta_index = temp;
            
            pair_spatial_rel = pair_spatial_rels_location(pair_type, this_type).spatial_rel;
            pair_spatial_rel = [pair_spatial_rel; this_relative_centroid angle];
            pair_spatial_rels_location(pair_type, this_type).spatial_rel = pair_spatial_rel;
                           
        end
    end
end
% save(pairwise_locations_file, 'pair_spatial_rels_location')
end


