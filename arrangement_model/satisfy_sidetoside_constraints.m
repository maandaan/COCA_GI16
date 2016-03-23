function [satisfied] = satisfy_sidetoside_constraints( centroid, object_dims, ...
    object_orient, object_type, holistic_scene, sidetoside_constraints )
%SATISFY_SIDETOSIDE_CONSTRAINTS checks whether all the side-to-side
%constraints can be satisfied for a new placement.

score = true;
satisfied = true;
epsilon = 1e-3;
% object_type = get_object_type_bedroom({object_cat});
object_rows = [structfind(sidetoside_constraints, 'first_type', object_type), ...
    structfind(sidetoside_constraints, 'second_type', object_type)];
if isempty(object_rows)
    return
end
constraints = sidetoside_constraints(object_rows);

%compute the global coordinates for the object's corners
corners_bnd = [-object_dims/2 object_dims/2];
local_corners = zeros(8,3);
newobj_corners = zeros(8,3);
local_corners(1,:) = corners_bnd(1:3);
local_corners(2,:) = [corners_bnd(4) corners_bnd(2) corners_bnd(3)];
local_corners(3,:) = [corners_bnd(4) corners_bnd(5) corners_bnd(3)];
local_corners(4,:) = [corners_bnd(1) corners_bnd(5) corners_bnd(3)];
local_corners(5:8,:) = [local_corners(1:4,1:2), repmat(corners_bnd(6), 4,1)];
for i = 1:8
    newobj_corners(i,:) = inv_convert_coordinates(-centroid, object_orient, local_corners(i,:));
end
object_rect = sorting_corners(newobj_corners, object_orient);
if isempty(object_rect)
    return;
end
object_height = newobj_corners(4:5,3);

%check that for each pair of objects in the scene, the side-to-side
%constraints (if any) are satisfied
dist_thresh = 3;
pushing_to_wall = true;
p_satisfied = 0; %for objects other than wall, if only one is satisfied it's ok!
for oid = 1:length(holistic_scene)
    pair = holistic_scene(oid);
    if pair.obj_type == object_type
        continue
    end
    
    if strcmp(pair.obj_category, 'room')
        if pair.obj_type == 29
            pair_type = 56;
        else
            pair_type = get_object_type_bedroom({'wall'});
        end
    else
        pair_type = pair.obj_type;
%         pair_type = get_object_type_bedroom({pair.obj_category});
        pair_height = pair.corners(4:5,3);
        %check whether they are at the same height
        z_intersect = range_intersection(sort(object_height), sort(pair_height));
        if isempty(z_intersect) || abs(z_intersect(1)-z_intersect(2)) < epsilon
            continue
        end
    end
    
    rows = [structfind(constraints, 'first_type', pair_type), ...
        structfind(constraints, 'second_type', pair_type)];
    if isempty(rows)
        continue
    end
    
    pair_rect = sorting_corners(pair.corners, pair.orientation);
    if isempty(pair_rect)
        continue
    end
    
    p_satisfied = true;
    
    if (pair.obj_type == 29 && pair_type == 56) || ...
            pair_type == get_object_type_bedroom({'wall'}) %if it's walls, we check for more frequent side
        max_freq = 0;
        for rid = 1:length(rows)
            c = constraints(rows(rid));
            if c.frequency > max_freq
                r = rid;
                max_freq = c.frequency;
            end
        end
        c = constraints(rows(r));
%         side1 = randi(4);
        side2 = c.second_side;
        
        rect1 = pair_rect;
        rect2 = object_rect;
        
        %debug
        for i = 1:length(holistic_scene)
            plot(holistic_scene(i).corners(1:5,1),holistic_scene(i).corners(1:5,2));
            hold on
        end
        plot([rect2(:,1);rect2(1,1)], [rect2(:,2);rect2(1,2)], 'r');
        hold off
        
        min_dist = 1000000;
        for side1 = 1:4
            dist = compute_sides_dist(rect1, rect2, side1, side2);
            if dist < min_dist
                min_dist = dist;
            end
        end
%         fprintf('dist: %f, avg_dist: %f\n', min_dist, c.avg_dist);
%         if abs(min_dist - c.avg_dist) > dist_thresh
        if min_dist > c.avg_dist + dist_thresh    
            pushing_to_wall = false;
            satisfied = false;
            break
        end   
    else
        touching_visited = false;
        for rid = 1:length(rows)
            c = constraints(rows(rid));
            side1 = c.first_side;
            side2 = c.second_side;
            
            if c.first_type == object_type
                rect1 = object_rect;
                rect2 = pair_rect;
            else
                rect1 = pair_rect;
                rect2 = object_rect;
            end
            
            if side1 == 2 && side2 == 4
                %debug
%                 for i = 1:length(holistic_scene)
%                     plot(holistic_scene(i).corners(1:5,1),holistic_scene(i).corners(1:5,2));
%                     hold on
%                 end
%                 plot([object_rect(:,1);object_rect(1,1)], [object_rect(:,2);object_rect(1,2)], 'r');
%                 hold off
                for i = rid+1:length(rows)
                    c2 = constraints(rows(i));
                    if c2.first_side == 4 && c2.second_side == 2
                        touching_visited = true;
                        dist24 = compute_sides_dist(rect1, rect2, 2, 4);
                        dist42 = compute_sides_dist(rect1, rect2, 4, 2);
                        p_satisfied = p_satisfied && ...
                            ((dist24>=0 && dist24 < c.avg_dist + dist_thresh) ...
                            || (dist42>=0 && dist42 < c2.avg_dist + dist_thresh));
%                         fprintf('dist24: %f, avg_dist24: %f\n', dist24, c.avg_dist);
%                         fprintf('dist42: %f, avg_dist42: %f\n', dist42, c2.avg_dist);
                    end
                end
            else
                %             for each pair, at least one side-to-side constraint should be
                %                 satisfied
                if side1 == 4 && side2 == 2 && touching_visited
                    continue
                end
                dist = compute_sides_dist(rect1, rect2, side1, side2);
%                 p_satisfied = p_satisfied && (abs(dist - c.avg_dist) < dist_thresh);
                p_satisfied = p_satisfied && (dist >= 0  && dist < c.avg_dist + dist_thresh);
            end
        end
        if ~p_satisfied
            satisfied = false;
            break
        end
    end
end

% score = p_satisfied + pushing_to_wall;

end


function dist = compute_sides_dist(rect1, rect2, side1, side2)
%computes the distance between two sides of the rectangles
rect1 = [rect1; rect1(1,:)];
rect2 = [rect2; rect2(1,:)];

q1 = rect1(side1,1:2);
q2 = rect1(side1+1,1:2);

p1 = rect2(side2,1:2);
p2 = rect2(side2+1,1:2);

dist1 = abs(det([q2-q1;p1-q1]))/norm(q2-q1);
dist2 = abs(det([q2-q1;p2-q1]))/norm(q2-q1);
dist = (dist1 + dist2) / 2;
end

