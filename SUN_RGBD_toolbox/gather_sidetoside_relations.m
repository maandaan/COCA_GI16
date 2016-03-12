function sidetoside_rels_matrix = gather_sidetoside_relations
%GATHER_TOUCHING_RELATIONS checks whether two objects have touching or
%near-touching sides and if they do, store that pair

Consts;

load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);
load(sunrgbdmeta_file);
epsilon = 0.001;

[dummy, categories_count] = get_object_type_bedroom('');
cat_count = categories_count + 2;
sidetoside_rels_matrix = repmat(struct('side_rels', []), cat_count, cat_count);
% relation_count = 0;
for mid = 1:total_size
    % check for the scene type
    if ~strcmp(map_scene_name_type(mid).sceneType, scene_type)
        continue
    end
    
    % compare with walls as an object
    room_corners = SUNRGBDMeta(:,mid).gtCorner3D .* 100;
    if isempty(room_corners)
        continue
    end
    room_size = size(room_corners,2) / 2;
    room_poly = room_corners(1:2,1:room_size)';
        
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D)
        continue;
    end
    
    no_objects = size(gt3D,2);
    for oid = 1:no_objects
        this_orient = gt3D(oid).orientation;
        this_type = get_object_type_bedroom({gt3D(oid).classname});
        this_corners = get_corners_of_bb3d(gt3D(oid)) .* 100;
%         [~, sorted_ind] = sort(this_corners(1:4,1));
%         this_rect_corners_ind = this_corners(sorted_ind, 1:2);
        this_rect = sorting_corners(this_corners, this_orient);
        if isempty(this_rect)
            continue
        end
        this_height = this_corners(4:5,3);
        
        for side = 1:room_size
            [dist1, dist2, rect2_side] = compute_dist(room_poly, this_rect, side);
            avg_dist = (dist1 + dist2) / 2;
            if avg_dist < 30
                r = sidetoside_rels_matrix(56, this_type).side_rels;
                r = [r; side rect2_side avg_dist];
%                 t = struct('firstobj_type', 56, 'secondobj_type', this_type, ...
%                     'firstobj_side', side, 'secondobj_side', rect2_side, 'distance', avg_dist);
%                 relation_count = relation_count + 1;
                sidetoside_rels_matrix(56, this_type).side_rels = r;
            end
        end
        
        for pid = oid+1:no_objects
            pair_orient = gt3D(pid).orientation;
            pair_type = get_object_type_bedroom({gt3D(pid).classname});
            pair_corners = get_corners_of_bb3d(gt3D(pid)) .* 100;
%             pair_rect = pair_corners(1:4,1:2);
%             [~, sorted_ind] = sort(pair_corners(1:4,1));
%             pair_rect_corners_ind = pair_corners(sorted_ind, 1:2);
            pair_rect = sorting_corners(pair_corners, pair_orient);
            if isempty(pair_rect)
                continue
            end
            pair_height = pair_corners(4:5,3);
            
            %check whether they are at the same height
            z_intersect = range_intersection(sort(this_height), sort(pair_height));
            if isempty(z_intersect) || abs(z_intersect(1)-z_intersect(2)) < epsilon
                continue
            end
            
            for side = 1:4
                [dist1, dist2, rect2_side] = compute_dist(this_rect, pair_rect, side);
                avg_dist = (dist1 + dist2) / 2;
                if avg_dist < 30
                    r = sidetoside_rels_matrix(this_type, pair_type).side_rels;
                    r = [r; side rect2_side avg_dist];
                    sidetoside_rels_matrix(this_type, pair_type).side_rels = r;
                    
                    if this_type ~= pair_type
                        r = sidetoside_rels_matrix(pair_type, this_type).side_rels;
                        r = [r; rect2_side side avg_dist];
                        sidetoside_rels_matrix(pair_type, this_type).side_rels = r;
                    end
%                     t = struct('firstobj_type', this_type, 'secondobj_type', pair_type, ...
%                         'firstobj_side', side, 'secondobj_side', rect2_side, 'distance', avg_dist);
%                     relation_count = relation_count + 1;
                    
                end
            end
        end
    end
end

save(sidetoside_relations_file_v2, 'sidetoside_rels_matrix');
end

function [min_dist_1, min_dist_2, rect2_side] = compute_dist(rect1, rect2, side)
%computes the min distance between side from rect1 and different sides of
%rect2

min_dist_1 = 1000000;
min_dist_2 = 1000000;
rect2_side = 0;
rect1 = [rect1; rect1(1,:)];
rect2 = [rect2; rect2(1,:)];

q1 = rect1(side,1:2);
q2 = rect1(side+1,1:2);

for i = 1:4
    p1 = rect2(i,1:2);
    p2 = rect2(i+1,1:2);
    dist1 = abs(det([q2-q1;p1-q1]))/norm(q2-q1);
    dist2 = abs(det([q2-q1;p2-q1]))/norm(q2-q1);
    dist_min = min(dist1, dist2);
    dist_max = max(dist1, dist2);
    if dist_min <= min_dist_1 && dist_max <= min_dist_2
        min_dist_1 = dist_min;
        min_dist_2 = dist_max;
        rect2_side = i;
    end
end

end

