function [ collided ] = check_collision( newobj_placement, newobj_dims, newobj_orient, scene )
%CHECK_COLLISION checks whether the new placement is colliding the
%placement of already placed objects.

thresh = 2.5;

newobj_center = newobj_placement(1:3);
% newobj_BB = [newobj_center - newobj_dims/2; newobj_center + newobj_dims/2];
corners_bnd = [-newobj_dims/2 newobj_dims/2];
local_corners = zeros(8,3);
newobj_corners = zeros(8,3);
local_corners(1,:) = corners_bnd(1:3);
local_corners(2,:) = [corners_bnd(4) corners_bnd(2) corners_bnd(3)];
local_corners(3,:) = [corners_bnd(4) corners_bnd(5) corners_bnd(3)];
local_corners(4,:) = [corners_bnd(1) corners_bnd(5) corners_bnd(3)];
local_corners(5:8,:) = [local_corners(1:4,1:2), repmat(corners_bnd(6), 4,1)];
for i = 1:8
    newobj_corners(i,:) = inv_convert_coordinates(-newobj_center, newobj_orient, local_corners(i,:));
end
% newobj_BB = [min(newobj_corners); max(newobj_corners)];
newobj_height = [min(newobj_corners(:,3)), max(newobj_corners(:,3))];
% newobj_xbnd = [min(newobj_corners(1:4,1)), max(newobj_corners(1:4,1))];
% newobj_ybnd = [min(newobj_corners(1:4,2)), max(newobj_corners(1:4,2))];
% newobj_rect = [newobj_xbnd(1)+thresh, newobj_ybnd(1)+thresh; ...
%     newobj_xbnd(2)-thresh, newobj_ybnd(1)+thresh; ...
%     newobj_xbnd(2)-thresh, newobj_ybnd(2)-thresh; ...
%     newobj_xbnd(1)+thresh, newobj_ybnd(2)-thresh];
newobj_rect = newobj_corners(1:4,1:2) - thresh;

epsilon = 0.00001;
collided = false;

plot(newobj_corners(1:5,1) - thresh, newobj_corners(1:5,2) - thresh, 'r');
hold on

for oid = 1:length(scene)
    pair = scene(oid);
%     pair_BB = [min(pair.corners); max(pair.corners)];
    
    if pair.obj_type == get_object_type_bedroom({'room'})
        continue
    end
    
%     rel_pair_corners = zeros(8,3);
%     cos_t = newobj_orient(2) / norm(newobj_orient);
%     sin_t = -newobj_orient(1) / norm(newobj_orient);
%     for i = 1:8
%         rel_pair_corners(i,:) = convert_coordinates(newobj_center, cos_t, sin_t, pair.corners(i,:));
%     end
%     pair_BB = [min(rel_pair_corners); max(rel_pair_corners)];
%     newobj_BB = [corners_bnd(1:3); corners_bnd(4:6)];
%     
%     %if in all 3 dimensions, two objects have intersection, it means
%     %they're colliding
%     x_intersect = range_intersection(newobj_BB(:,1), pair_BB(:,1));
%     y_intersect = range_intersection(newobj_BB(:,2), pair_BB(:,2));
%     z_intersect = range_intersection(newobj_BB(:,3), pair_BB(:,3));
%     
%     collided = ~isempty(x_intersect) && ~isempty(y_intersect) && ~isempty(z_intersect) && ...
%         abs(x_intersect(1) - x_intersect(2)) > epsilon && abs(y_intersect(1) - y_intersect(2)) > epsilon ...
%         && abs(z_intersect(1) - z_intersect(2)) > epsilon;

    pair_height = [min(pair.corners(:,3)), max(pair.corners(:,3))];
%     pair_xbnd = [min(pair.corners(1:4,1)), max(pair.corners(1:4,1))];
%     pair_ybnd = [min(pair.corners(1:4,2)), max(pair.corners(1:4,2))];
%     pair_rect = [pair_xbnd(1)+thresh, pair_ybnd(1)+thresh; ...
%                  pair_xbnd(2)-thresh, pair_ybnd(1)+thresh; ...
%                  pair_xbnd(2)-thresh, pair_ybnd(2)-thresh; ...
%                  pair_xbnd(1)+thresh, pair_ybnd(2)-thresh];
    pair_rect = pair.corners(1:4,1:2);
    z_intersect = range_intersection(newobj_height, pair_height);
    xy_intersect = RectIntersect(pair_rect, newobj_rect);
    
    collided = xy_intersect && ~isempty(z_intersect) && ...
        abs(z_intersect(1) - z_intersect(2)) > epsilon;
    
    %debug
    plot(pair.corners(1:5,1), pair.corners(1:5,2));
    hold off

    if collided
        break
    end
end

% hold off

end

