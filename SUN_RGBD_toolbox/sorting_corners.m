function rect = sorting_corners(corners, orient)
%sorts the corners based on the ids for sides

rect = zeros(4,2);
cos_theta = orient(2) / norm(orient);
sin_theta = -orient(1) / norm(orient);
centroid = mean(corners);
local_corners = zeros(4,3);
for i = 1:4
    local_corners(i,:) = convert_coordinates(centroid, cos_theta, sin_theta, corners(i,:));
end

x_neg_ind = find(local_corners(:,1) < 0);
x_pos_ind = find(local_corners(:,1) > 0);
y_neg_ind = find(local_corners(:,2) < 0);
y_pos_ind = find(local_corners(:,2) > 0);

if isempty(x_neg_ind) || isempty(x_pos_ind) || ...
        isempty(y_neg_ind) || isempty(y_pos_ind)
    rect = [];
    return
end

nodes = zeros(1,4);
try
    nodes(1) = intersect(x_pos_ind, y_pos_ind);
    nodes(2) = intersect(x_neg_ind, y_pos_ind);
    nodes(3) = intersect(x_neg_ind, y_neg_ind);
    nodes(4) = intersect(x_pos_ind, y_neg_ind);
catch
    rect = [];
    return;
end

if ~isempty(find(nodes == 0))
    rect = [];
    return
end

for i = 1:4
    rect(i,:) = corners(nodes(i),1:2);
end

end

