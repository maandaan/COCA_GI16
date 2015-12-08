function [ symmetry_groups ] = gather_symmetric_relations( scene_type, mapping_file )
%GATHER_SYMMETRIC_RELATIONS checks for symmetric groups in the scene and
%also finds the object they are symmetric with respect to. (by Zeinab
%Sadeghipour)

% scene_type = 'bedroom';
% mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';

load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);

sunrgbdmeta_file = 'SUNRGBDMeta.mat';
load(sunrgbdmeta_file);

symm_group_count = 1;
symmetry_groups = struct('scene_index', [], 'symm_group_ind', [], 'symm_group_outside_obj_ind', []);

for mid = 1:total_size
    % check for the scene type
    if ~strcmp(map_scene_name_type(mid).sceneType, scene_type)
        continue
    end
    
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D)
        continue;
    end
    
    obj_labels = {gt3D(:).classname};
    obj_types = get_object_type_bedroom(obj_labels);
    [unique_types, all_to_unique, unique_to_all] = unique(obj_types);
    count_uniques = hist(unique_to_all, length(unique_types)); % count how many times each category is repeated
    
    for cid = 1:length(count_uniques)
        if count_uniques(cid) < 2 %only one instance of that category => no symmetry groups
            continue
        end
        
        potential_symm_group_ind = find(unique_to_all == cid);
        potential_symm_group_sizes = zeros(length(potential_symm_group_ind),3);
        %compute the sizes of objects in the potential symmetry group
        for sid = 1:length(potential_symm_group_ind)
            corners = get_corners_of_bb3d(gt3D(potential_symm_group_ind(sid)));
            potential_symm_group_sizes(sid, :) = [norm(corners(1,:) - corners(2,:)), ...
                                                  norm(corners(2,:) - corners(3,:)), ...
                                                  abs(corners(1,3) - corners(5,3))];
        end
        
        %check for approximately the same size
        median_size = median(potential_symm_group_sizes);
        thresh = 0.1;
        symm_group_ind = [];
        symm_group_sizes = [];
        for sid = 1:length(potential_symm_group_ind)
            if abs(potential_symm_group_sizes(sid,1) - median_size(1)) < thresh && ...
                    abs(potential_symm_group_sizes(sid,2) - median_size(2)) < thresh && ...
                    abs(potential_symm_group_sizes(sid,3) - median_size(3)) < thresh
                symm_group_ind = [symm_group_ind, potential_symm_group_ind(sid)];
                symm_group_sizes = [symm_group_sizes; potential_symm_group_sizes(sid,:)];
            end
        end
        
        if length(symm_group_ind) < 2
            continue
        end
        
        
        %check the outside objects to see which one is the center for symmetry
        symm_group_objs = gt3D(symm_group_ind);
        symm_group_outside_obj_ind = 0;
        for oid = 1:length(gt3D)
            if ~isempty(find(symm_group_ind == oid))
                continue
            end
            
            outside_obj = gt3D(oid);
            outside_corners = get_corners_of_bb3d(outside_obj);
            outside_size = [norm(outside_corners(1,:) - outside_corners(2,:)), ...
                            norm(outside_corners(2,:) - outside_corners(3,:)), ...
                            abs(outside_corners(1,3) - outside_corners(5,3))];
            
            distances = zeros(1,length(symm_group_ind));
            orientations = zeros(1,length(symm_group_ind));
            for gid = 1:length(symm_group_ind)
                distances(gid) = norm( outside_obj.centroid - symm_group_objs(gid).centroid ) / ...
                    ( norm(outside_size) + norm(symm_group_sizes(gid,:)) );
                cos_angle = dot(outside_obj.orientation, symm_group_objs(gid).orientation) / ...
                    (norm(outside_obj.orientation) * norm(symm_group_objs(gid).orientation));
                orientations(gid) = acos( min(max(cos_angle, -1), 1) ); % for fixing the cases where the cos_angle = 1 or -1
            end
            median_dist = median(distances);
            median_orient = median(orientations);
            thresh_dist = 0.1;
            thresh_orient = 0.05;
            if isempty(find(abs(median_dist - distances) > thresh_dist)) && isempty(find(abs(median_orient - orientations) > thresh_orient))
                symm_group_outside_obj_ind = oid;
            end
        end
        
        symmetry_groups(symm_group_count).scene_index = mid;
        symmetry_groups(symm_group_count).symm_group_ind = symm_group_ind;
        symmetry_groups(symm_group_count).symm_group_outside_obj_ind = symm_group_outside_obj_ind;
        symm_group_count = symm_group_count + 1;
    end
end

end

