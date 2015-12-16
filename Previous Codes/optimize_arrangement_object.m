function [ optimized_corners, optimized_orientation, final_cost ] = ...
    optimize_arrangement_object( object, local_scene, final_scene, sibling_list, room, scene_counts )
% This function implements the arrangement model. With an initial placement
% for the input object type in the given 3D scene, based on the GMMs
% learned from pairwise spatial relations and support relations, the
% optimized placement will be computed. (by Zeinab Sadeghipour)

%input: scene: an array of objects (including the room) with their
%category, corners and orientation

% gmm_file = 'data/training/SUNRGBD/bedroom_gmm_spatial_relations'
% support_file = 'data/training/SUNRGBD/bedroom_support_relations'
% co_occurrence_file = 'data/training/SUNRGBD/bedroom_co_occurrence'

Consts;

load(gmm_file, 'gmm_matrix');
% load(support_file, 'support_matrix');
load(co_occurrence_file, 'co_occurrence');

% room_obj_index = structfind(scene, 'type', 29);
% assumption: always the first object in the local_scene is the parent;
% i.e. the supporting surface
parent_obj = local_scene(1);
% parent_dims = max(parent_obj.corners) - min(parent_obj.corners);
parent_dims = parent_obj.dims .* parent_obj.scale;
parent_centroid = mean(parent_obj.corners); %(max(parent_obj.corners) + min(parent_obj.corners)) / 2;

%optimization by simulated annealing
object_centroid = mean(object.corners); %(max(object.corners) + min(object.corners)) / 2;
object_dims = object.dims .* object.scale; %max(object.corners) - min(object.corners);
% object_angle = atan(object.orientation(2) / object.orientation(1));
object_placement = [parent_centroid(1:2) object_centroid(3) object.orientation(1:2)];
% object_placement = init_object_placement(sibling_list, local_scene(1), object);

ObjectiveFunction = @(x) arrangement_cost(x, object.obj_type, object_dims, ...
    local_scene, final_scene, gmm_matrix, co_occurrence, scene_counts, room);

% 'PlotFcns', @saplotx,
options = saoptimset('AnnealingFcn', @possible_move, ...
    'InitialTemperature', min(parent_dims(1)/2, parent_dims(2)/2));
lbnd_xy = min(parent_obj.corners) + object_dims/2;
ubnd_xy = max(parent_obj.corners) - object_dims/2;
lbnd = [lbnd_xy(1:2) object_centroid(3) -Inf -Inf];
ubnd = [ubnd_xy(1:2) object_centroid(3) Inf Inf];
% plotobjective(ObjectiveFunction, [lbnd(1) ubnd(1); lbnd(2) ubnd(2)]);
% figure
% hold on
[x,final_cost] = simulannealbnd(ObjectiveFunction,object_placement,lbnd,ubnd, options);
% hold off

filename = 'moves.txt';
h = fopen(filename, 'a');
fprintf(h, '------------------------\n');
fclose(h);

optimized_center = x(1:3);
optimized_corners_bnd = [-object_dims/2 object_dims/2];
optimized_orientation = [x(4:5), 0];

% cos_angle_orig = object.orientation(1) ./ norm(object.orientation);
% if object.orientation(2) >= 0 % sin > 0
%     angle_orig = radtodeg(acos( min(max(cos_angle_orig, -1), 1) ));
% else
%     angle_orig = radtodeg(acos( min(max(cos_angle_orig, -1), 1) )) + 180;
% end
% 
% cos_angle_opt = optimized_orientation(1) ./ norm(optimized_orientation);
% if optimized_orientation(2) >= 0 % sin > 0
%     angle_opt = radtodeg(acos( min(max(cos_angle_opt, -1), 1) ));
% else
%     angle_opt = radtodeg(acos( min(max(cos_angle_opt, -1), 1) )) + 180;
% end
% 
% diff_angle = degtorad(angle_opt - angle_orig);
% r = [cos(diff_angle), sin(diff_angle), 0; -sin(diff_angle), cos(diff_angle), 0; 0,0,1];
% opt_corners_rot_bnd = [r \ optimized_corners_bnd(1:3)'; ...
%                        r \ optimized_corners_bnd(4:6)'];
local_corners = zeros(8,3);
global_corners_opt = zeros(8,3);
local_corners(1,:) = optimized_corners_bnd(1:3);
local_corners(2,:) = [optimized_corners_bnd(4) optimized_corners_bnd(2) optimized_corners_bnd(3)];
local_corners(3,:) = [optimized_corners_bnd(4) optimized_corners_bnd(5) optimized_corners_bnd(3)];
local_corners(4,:) = [optimized_corners_bnd(1) optimized_corners_bnd(5) optimized_corners_bnd(3)];
local_corners(5:8,:) = [local_corners(1:4,1:2), repmat(optimized_corners_bnd(6), 4,1)];
for i = 1:8
%     new_orient = [-optimized_orientation(1) optimized_orientation(2) 0];
    global_corners_opt(i,:) = inv_convert_coordinates(-optimized_center, optimized_orientation, local_corners(i,:));
%     global_corners_opt(i+4,:) = [global_corners_opt(i,1:2) optimized_corners_bnd(6)];
end

% align_ind = [1 2 3; 4 2 3; 4 5 3; 1 5 3; 1 2 6; 4 2 6; 4 5 6; 1 5 6];
% optimized_corners = [local_corners, [local_corners(1:2,:);repmat(optimized_corners_bnd(6), 1, 4)]]';
optimized_corners = global_corners_opt;
% optimized_angle = x(4);

end

function cost = arrangement_cost(object_placement, object_type, object_dims, scene, holistic_scene, gmm_matrix, co_occurrence, scene_counts, room)

num_objects = size(scene,1);
room_obj_index = structfind(holistic_scene, 'obj_type', 29);
room_obj = holistic_scene(room_obj_index);

collided = check_collision(object_placement, object_dims, holistic_scene);

if collided
    cost = 1;
else
    spatial_score = 0;
    % checking for the support
    % supp_surface_type = 0; %which category the surface is
    % max_freq = 0;
    for oid = 1:num_objects
        pair_obj = scene(oid);
        %     if pair_obj.type == 29 %room
        %         pair_support_freq = max(max(support_matrix(object.type,55:56,:))); % floor and walls
        %         ind = find(support_matrix(object.type,55:56,:) == pair_support_freq);
        %
        %         if ind < 3
        %             pair_type = 55;
        %         else
        %             pair_type = 56;
        %         end
        %
        %         if mod(ind,2) == 1
        %             pair_support_type = 1;
        %         else
        %             pair_support_type = 2;
        %         end
        %     else
        %         [pair_support_freq, pair_support_type] = max(support_matrix(object.type,pair_obj.type,:));
        %         pair_type = pair_obj.type;
        %     end
        %
        %     if pair_support_freq > max_freq
        %         max_freq = pair_support_freq;
        %         supp_surface_type = pair_type;
        %         support_type = pair_support_type;
        %     end
        
        if pair_obj.obj_type == 29
            continue
        end
        gmm_l = gmm_matrix(object_type, pair_obj.obj_type).gmm_location;
        gmm_a = gmm_matrix(object_type, pair_obj.obj_type).gmm_angle;
        if isempty(gmm_l)
            continue
        end
        prob = spatial_cost( gmm_l, gmm_a, object_placement, pair_obj, object_dims, room_obj );
        
        spatial_score = spatial_score + prob * (co_occurrence(object_type, pair_obj.obj_type) ./ scene_counts);
    end
    cost = -spatial_score;
end

filename = 'moves.txt';
h = fopen(filename, 'a');
fprintf(h, 'cost: %f\n', cost);
fclose(h);

end

function newx = possible_move(optimValues,problemData)

current_x = optimValues.x;
current_temp = optimValues.temperature;
sigma = [1,1,1,5]' .* current_temp(1:4);

% plot3(current_x(1), current_x(2), optimValues.fval,'o');

new_centroid = zeros(1,3);
new_centroid(1) = normrnd(0,sigma(1)) + current_x(1);
while new_centroid(1) < problemData.lb(1) || new_centroid(1) > problemData.ub(1)
    new_centroid(1) = normrnd(0,sigma(1)) + current_x(1);
end

new_centroid(2) = normrnd(0,sigma(2)) + current_x(2);
while new_centroid(2) < problemData.lb(2) || new_centroid(2) > problemData.ub(2)
    new_centroid(2) = normrnd(0,sigma(2)) + current_x(2);
end

new_centroid(3) = current_x(3); % do not change the z

% new_orient = zeros(1,2);
% new_orient(1) =  normrnd(0,sigma(4)) + current_x(4);
% new_orient(2) =  normrnd(0,sigma(5)) + current_x(5);

current_angle = radtodeg(atan(current_x(5) / current_x(4)));
if current_x(4) < 0 %2nd and 3rd quarter
    current_angle = current_angle + 180;
end
delta_angle = normrnd(0, sigma(4));
if delta_angle > 180
    delta_angle = 180;
end
new_angle = delta_angle + current_angle;
new_angle_rad = degtorad(new_angle);

newx = [new_centroid cos(new_angle_rad) sin(new_angle_rad)];

filename = 'moves.txt';
h = fopen(filename, 'a');
fprintf(h, 'temperature: %f, k: %f, delta_x: %f, new_z: %f\n', current_temp(1), optimValues.k(1), new_centroid(1)-current_x(1), new_centroid(3));
% fprintf(h, '%f, %f, %f, %f, ', sigma(1), sigma(2), sigma(3), sigma(4));
% fprintf(h, '%f, %f, %f, %f, %f, ', new_centroid(1), new_centroid(2), new_centroid(3), new_orient(1), new_orient(2));
fclose(h);

end

