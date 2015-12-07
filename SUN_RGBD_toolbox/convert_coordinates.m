function new_coordinates = convert_coordinates(new_center, new_orient, point)

% if this_orient(1) * this_orient(2) > 0
%     e_u = [this_orient(2); -this_orient(1); 0] ./ norm(this_orient);
% else
%     e_u = [this_orient(2); -this_orient(1); 0] ./ norm(this_orient);
% end

% e_u = [this_orient(2); -this_orient(1); 0] ./ norm(this_orient);
% e_v = [this_orient(1); this_orient(2); 0] ./ norm(this_orient);
% e_w = [0; 0; 1];
% 
% e_x = [1; 0; 0];
% e_y = [0; 1; 0];
% e_z = [0; 0; 1];
% 
% % rotation_mat = e_u * e_x' + e_v * e_y' + e_w * e_z';
% new_coordinates = [e_u'; e_v'; e_w'];

cos_theta = new_orient(2) / norm(new_orient);
sin_theta = -new_orient(1) / norm(new_orient);
r = [cos_theta, sin_theta, 0; -sin_theta, cos_theta, 0; 0, 0, 1];

p_prime = r * (point - new_center)';
new_coordinates = p_prime';

end