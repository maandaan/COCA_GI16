function [ object_placement ] = init_object_placement( sibling_list, parent, object )
%INIT_OBJECT_PLACEMENT initializes the placement of objects based on the
%other objects on the supporting surface (siblings), if there are not any
%siblings, we just randomly choose a corner for the object placement,
%otherwise, we come up with a location in the free space by mcmc sampling
%with largest possible distance with siblings.

object_dims = max(object.corners) - min(object.corners);
object_center = (max(object.corners) + min(object.corners)) / 2;
z = object_center(3);

parent_corners_bnd = [min(parent.corners) max(parent.corners)];
x_range = [parent_corners_bnd(1) + object_dims(1)/2, parent_corners_bnd(4) - object_dims(1)/2];
y_range = [parent_corners_bnd(2) + object_dims(2)/2, parent_corners_bnd(5) - object_dims(2)/2];

if isempty(sibling_list)
    corner = randi(4);
    switch corner
        case 1
            curr_x = x_range(1);
            curr_y = y_range(1);
        case 2
            curr_x = x_range(2);
            curr_y = y_range(1);
        case 3
            curr_x = x_range(1);
            curr_y = y_range(2);
        case 4
            curr_x = x_range(2);
            curr_y = y_range(2);
        otherwise
            fprintf('Wrong random!!!!\n');
    end
else
    curr_x = (x_range(2) - x_range(1)) * rand + x_range(1);
    curr_y = (y_range(2) - y_range(1)) * rand + y_range(1);
    collided = check_collision( [curr_x curr_y z], object_dims, [parent; sibling_list] );
    while collided
        curr_x = (x_range(2) - x_range(1)) * rand + x_range(1);
        curr_y = (y_range(2) - y_range(1)) * rand + y_range(1);
        collided = check_collision( [curr_x curr_y z], object_dims, [parent; sibling_list] );
    end
    
    %mcmc sampling, independent metropolis-hastings sampling
    for iter = 1:50
        
        %next state
        next_x = (x_range(2) - x_range(1)) * rand + x_range(1);
        next_y = (y_range(2) - y_range(1)) * rand + y_range(1);
        collided = check_collision( [next_x next_y z], object_dims, [parent; sibling_list] );
        while collided
            next_x = (x_range(2) - x_range(1)) * rand + x_range(1);
            next_y = (y_range(2) - y_range(1)) * rand + y_range(1);
            collided = check_collision( [next_x next_y z], object_dims, [parent; sibling_list] );
        end
        
        curr_config_score = compute_sampling_cost(curr_x, curr_y, sibling_list);
        next_config_score = compute_sampling_cost(next_x, next_y, sibling_list);
        alpha = min(1, next_config_score / curr_config_score);
        u = rand;
        if alpha > u
            curr_x = next_x;
            curr_y = next_y;
%             all_config(iter, :) = next_config;
%             all_score(iter) = next_config_score;
%         else
%             all_config(iter, :) = curr_config;
%             all_score(iter) = curr_config_score;
        end
    end
end

object_placement = [curr_x curr_y z object.orientation(1:2)];

end

function dist = compute_sampling_cost(x, y, sibling_list)

dist = 0;
for sid = 1:length(sibling_list)
    sibling = sibling_list(sid);
    sibling_center = (min(sibling.corners) + max(sibling.corners)) / 2;
    dist = dist + norm(sibling_center(1:2) - [x y]);
end

end