function new_coordinates = inv_convert_coordinates( new_center, new_orient, point )
%INV_CONVERT_COORDINATES the inverse for function convert_coordinates.m

cos_theta = new_orient(2) / norm(new_orient);
sin_theta = new_orient(1) / norm(new_orient);
r = [cos_theta, sin_theta, 0; -sin_theta, cos_theta, 0; 0, 0, 1];

p_prime = r * point' - new_center';
new_coordinates = p_prime';


end

