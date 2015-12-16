function [ spatial_prob ] = spatial_cost( gmm_l, gmm_a, object_placement, second_obj, object_dims, room_obj )
%This function computes the probability of the relative placement of the
%two given objects based on the trained GMM. (by Zeinab Sadeghipour)

room_diag = norm(max(room_obj.corners) - min(room_obj.corners));
first_obj_centroid = object_placement(1:3);
second_obj_centroid = mean(second_obj.corners); %( max(second_obj.corners) + min(second_obj.corners) ) /2;
% second_obj_dims = max(second_obj.corners) - min(second_obj.corners);
% distance = norm(first_obj_centroid - second_obj_centroid) ./ prod(second_obj_dims);
% xy_dist = norm(first_obj_centroid(1:2) - second_obj_centroid(1:2)) ./ prod(second_obj_dims(1:2));

first_obj_orient = object_placement(4:5);
% second_obj_angle = atan(second_obj.orientation(2) / second_obj.orientation(1));
second_obj_orient = second_obj.orientation(1:2);
cos_angle = dot(first_obj_orient, second_obj_orient) / (norm(first_obj_orient) * norm(second_obj_orient));
angle = acos( min(max(cos_angle, -1), 1) ); % for fixing the cases where the cos_angle = 1 or -1
angle = radtodeg(angle);
% angle = abs(first_obj_angle - second_obj_angle);

% r = convert_coordinates(first_obj_orient);
% second_obj_relative_centroid = second_obj_centroid * r' + first_obj_centroid;
cos_theta = first_obj_orient(2) / norm(first_obj_orient);
sin_theta = -first_obj_orient(1) / norm(first_obj_orient);
second_obj_relative_centroid = convert_coordinates(first_obj_centroid, cos_theta, sin_theta, second_obj_centroid);

displacement = (first_obj_centroid - second_obj_centroid) ./ room_diag;

% p = posterior(gmm, [distance angle]);
spatial_prob = pdf(gmm_l, second_obj_relative_centroid) + pdf(gmm_a, angle);
% spatial_prob = max(p,[],2);

end

