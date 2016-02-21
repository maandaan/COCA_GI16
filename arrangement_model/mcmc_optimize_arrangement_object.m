function [ all_xy, all_angle, all_score, all_pid, all_collision, all_sidetoside_constraints ] = ...
    mcmc_optimize_arrangement_object( object, init_xy, pair_objects, ...
    holistic_scene, siblings, num_iter, use_hard_constraints )
%MCMC_ARRANGEMENT samples a location and angle for each object relative to
%it's pair objects. (The last input, use_hard_constraints indicates whether
%to apply the hard constraints after the sampling or not.)

Consts;
load(kmeans_file, 'kmeans_matrix');
load(pairwise_locations_file, 'pair_spatial_rels_location');
load(sidetoside_constraints_file, 'sidetoside_constraints');

obj_type = object.obj_type;

%choose one pair object to sample
% pairs_prob = compute_pair_probability(object, pair_objects, pair_spatial_rels_location);
% if isempty(find(pairs_prob, 1))
%     all_xy = [];
%     all_angle = [];
%     all_score = [];
%     all_pid = [];
%     return
% end

rng shuffle
% r = rand;
% pair_id = sum(r >= cumsum([0, pairs_prob']));

parent_id = object.supporter_id;
parent_row = structfind(pair_objects, 'identifier', parent_id);
if length(pair_objects) > 1 && ...
        pair_objects(parent_row).obj_type == get_object_type_bedroom({'room'})
    pair_id = 2;
else
    pair_id = parent_row;
end
% pair_id = 1;

% %choose one cluster from that pair to sample
[xy_clusters_prob, angle_clusters_prob] = compute_cluster_probability(object, pair_objects, kmeans_matrix);
% r = rand;
% xy_cluster_id = sum(r >= cumsum([0, xy_clusters_prob(pair_id).prob']));
% r = rand;
% angle_cluster_id = sum(r >= cumsum([0, angle_clusters_prob(pair_id).prob']));
%
% kmeans_xy = kmeans_matrix(pair_objects(pair_id).obj_type, obj_type).kmeans_xy;
% kmeans_angle = kmeans_matrix(pair_objects(pair_id).obj_type, obj_type).kmeans_angle;

%initial placement
% data = pair_spatial_rels_location(pair_objects(pair_id).obj_type, obj_type).spatial_rel;
% xy_cluster_ind = find(kmeans_xy.cluster_index == xy_cluster_id);
% angle_cluster_ind = find(kmeans_angle.cluster_index == angle_cluster_id);
% curr_xy = data( xy_cluster_ind( randi( length(xy_cluster_ind))),1:2);
% curr_angle = data( angle_cluster_ind( randi( length(angle_cluster_ind))),4);

support = pair_objects(1);
support_dims = support.dims .* support.scale;

ref = pair_objects(pair_id);
ref_dims = pair_objects(pair_id).dims .* pair_objects(pair_id).scale;
object_dims = object.dims .* object.scale;
% curr_xy = [-parent_dims(1)/2 + object_dims(1)/2 0];
% curr_xy = [0,0];
curr_xy = init_xy;
% curr_xy = [curr_xy(1)/(parent_dims(1)/2), curr_xy(2)/(parent_dims(2)/2)];
if ref.obj_type == get_object_type_bedroom({'room'})
    curr_angle = 90;
else
    curr_angle = 0;
end

curr_score = compute_arrangement_cost_kmeans(object, pair_objects, pair_id,...
    curr_xy, curr_angle, kmeans_matrix);
x = curr_xy(1);
y = curr_xy(2);
x = x .* (ref_dims(1) / 2);
y = y .* (ref_dims(2) / 2);
z = mean(object.corners(:,3));
global_xyz = inv_convert_coordinates(-mean(ref.corners), ref.orientation, [x y 0]);
theta = compute_theta_from_orientation(pair_objects(pair_id).orientation);

angle1 = theta + degtorad(curr_angle);
curr_angle_abs = angle1;
object_orient1 = [cos(angle1) sin(angle1) 0];
collided1 = check_collision( [global_xyz(1:2) z], object_dims, object_orient1, holistic_scene );
sidetoside_satisfied1 = satisfy_sidetoside_constraints ([global_xyz(1:2) z], object_dims, ...
    object_orient1, obj_type, siblings, sidetoside_constraints);

if collided1 || ~sidetoside_satisfied1
    angle2 = theta - degtorad(curr_angle);
    curr_angle_abs = angle2;
    object_orient2 = [cos(angle2) sin(angle2) 0];
    collided2 = check_collision( [global_xyz(1:2) z], object_dims, object_orient2, holistic_scene );
    sidetoside_satisfied2 = satisfy_sidetoside_constraints ([global_xyz(1:2) z], object_dims, ...
        object_orient2, obj_type, siblings, sidetoside_constraints);
    
    curr_collision = collided2;
    curr_sidetoside_constraints = sidetoside_satisfied2;
    
else
    curr_collision = collided1;
    curr_sidetoside_constraints = sidetoside_satisfied1;
end

if ~use_hard_constraints
    
    curr_score1 = curr_score * ~collided1 * sidetoside_satisfied1;
    
    if collided1 || ~sidetoside_satisfied1
        curr_score2 = curr_score * ~collided2 * sidetoside_satisfied2;
        curr_score = curr_score2;
    else
        curr_score = curr_score1;
    end
end

all_xy = zeros(num_iter, 2);
samples_xy = zeros(num_iter, 2);
all_angle = zeros(num_iter, 1);
samples_angle = zeros(num_iter, 1);
all_score = zeros(num_iter, 1);
all_pid = zeros(num_iter, 1);
all_collision = zeros(num_iter, 1);
all_sidetoside_constraints = zeros(num_iter, 1);

all_xy(1, :) = curr_xy;
all_angle(1) = curr_angle_abs;
all_score(1) = curr_score;
all_pid(1) = pair_id;
all_collision(1) = curr_collision;
all_sidetoside_constraints(1) = curr_sidetoside_constraints;

iter = 2;
% collision_count = 0;
% constraint_count = 0;
while iter <= num_iter
    %     && collision_count <= num_iter*2 ...
    %     && constraint_count <= num_iter*2
    %     % choose next sample
    %     r = rand;
    %     next_pair_id = sum(r >= cumsum([0, pairs_prob']));
    next_pair_id = pair_id;
    r = rand;
    next_xy_cluster_id = sum(r >= cumsum([0, xy_clusters_prob(next_pair_id).prob']));
    r = rand;
    next_angle_cluster_id = sum(r >= cumsum([0, angle_clusters_prob(next_pair_id).prob']));
    
    next_kmeans_xy = kmeans_matrix(pair_objects(next_pair_id).obj_type, obj_type).kmeans_xy;
    next_kmeans_angle = kmeans_matrix(pair_objects(next_pair_id).obj_type, obj_type).kmeans_angle;
    
    next_data = pair_spatial_rels_location(pair_objects(next_pair_id).obj_type, obj_type).spatial_rel;
    
    next_xy_cluster_ind = find(next_kmeans_xy.cluster_index == next_xy_cluster_id);
    next_angle_cluster_ind = find(next_kmeans_angle.cluster_index == next_angle_cluster_id);
    
    next_xy = next_data( next_xy_cluster_ind( randi( length(next_xy_cluster_ind))),1:2);
    next_angle = next_data( next_angle_cluster_ind( randi( length(next_angle_cluster_ind))),4);
    %     next_x = rand() * 2 - 1;
    %     next_y = rand() * 2 - 1;
    %     next_xy = [next_x, next_y];
    %     next_angle = rand() * 180;
    
    x = next_xy(1);
    y = next_xy(2);
    x = x .* (ref_dims(1) / 2);
    y = y .* (ref_dims(2) / 2);
    z = mean(object.corners(:,3));
    global_xyz = inv_convert_coordinates(-mean(ref.corners), ref.orientation, [x y 0]);
    theta = compute_theta_from_orientation(pair_objects(next_pair_id).orientation);
    angle1 = theta + degtorad(next_angle);
    next_angle_abs = angle1;
    object_orient1 = [cos(angle1) sin(angle1) 0];
    
    %check for availability on the support surface
    %     p = support_dims / 2;
    %     o = object_dims / 2;
    %     if x < -1 + o(1)/p(1) || x > 1 - o(1)/p(1) || ...
    %             y < -1 + o(2)/p(2) || y > 1 - o(2)/p(2)
    % %         fprintf('Not available space on the supporting surface!!\n');
    %         continue
    %     end
    x = global_xyz(1);
    y = global_xyz(2);
    support_bnd = [min(support.corners), max(support.corners)];
    if x - object_dims(1)/2 < support_bnd(1) || x + object_dims(1)/2 > support_bnd(4) ...
            || y - object_dims(2)/2 < support_bnd(2) || y + object_dims(2)/2 > support_bnd(5)
        continue
    end
    
    samples_xy(iter,:) = next_xy;
    samples_angle(iter) = next_angle;
    next_score_kmeans = compute_arrangement_cost_kmeans(object, pair_objects, next_pair_id,...
        next_xy, next_angle, kmeans_matrix);
    
    %check for collision
    collided1 = check_collision( [global_xyz(1:2) z], object_dims, object_orient1, holistic_scene );
    %     if check_collision( [global_xyz(1:2) z], object_dims, object_orient, holistic_scene )
    % %         fprintf('Collision occures for this placement!!\n');
    %         collision_count = collision_count + 1;
    %         continue
    %     end
    %     collision_count = 0;
    
    %check for side-to-side constraints
    sidetoside_satisfied1 = satisfy_sidetoside_constraints ([global_xyz(1:2) z], object_dims, ...
        object_orient1, obj_type, siblings, sidetoside_constraints);
    %     if ~satisfy_sidetoside_constraints ([global_xyz(1:2) z], object_dims, ...
    %             object_orient, obj_type, holistic_scene, sidetoside_constraints)
    % %         fprintf('Side-to-side constraints are not satisfied for this placement!!\n');
    %         constraint_count = constraint_count + 1;
    %         continue
    %     end
    %     constraint_count = 0;
    
    %since we have the relative angle in our knowledge, one solution is to
    %add the relative angle to the reference object orientation and another
    %solution is to subtract it, check for the second solution is the first
    %one does not lead to a plausible arrangement
    if collided1 || ~sidetoside_satisfied1
        angle2 = theta - degtorad(next_angle);
        next_angle_abs = angle2;
        object_orient2 = [cos(angle2) sin(angle2) 0];
        collided2 = check_collision( [global_xyz(1:2) z], object_dims, ...
            object_orient2, holistic_scene );
        sidetoside_satisfied2 = satisfy_sidetoside_constraints (...
            [global_xyz(1:2) z], object_dims, object_orient2, ...
            obj_type, siblings, sidetoside_constraints);
        
        next_collision = collided2;
        next_sidetoside_constraints = sidetoside_satisfied2;
    else
        next_collision = collided1;
        next_sidetoside_constraints = sidetoside_satisfied1;
    end
    
    
    if use_hard_constraints
        next_score = next_score_kmeans;
    else
        next_score = next_score_kmeans * ~collided1 * sidetoside_satisfied1;
        if collided1 || ~sidetoside_satisfied1
            next_score = next_score_kmeans * ~collided2 * sidetoside_satisfied2;
        end
    end
    
    %debug
%     fprintf('k-means score:%f, collided_1:%d, collided_2:%d, sidetoside_satisfied_1:%d, sidetoside_satisfied_2:%d\n',...
%         next_score_kmeans, collided1, collided2, sidetoside_satisfied1, sidetoside_satisfied2);
    
    %mcmc sampling
    if next_score == 0
        ratio_score = 0;
    elseif curr_score == 0 %some constraints are violeted
        ratio_score = 1;
    else
        ratio_score = curr_score / next_score;
    end
    alpha = min(1, ratio_score);
    u = rand;
    if alpha > u
        curr_xy = next_xy;
        curr_angle_abs = next_angle_abs;
        curr_score = next_score;
        pair_id = next_pair_id;
        curr_collision = next_collision;
        curr_sidetoside_constraints = next_sidetoside_constraints;
    end
    all_xy(iter, :) = curr_xy;
    all_angle(iter) = curr_angle_abs;
    all_score(iter) = curr_score;
    all_pid(iter) = pair_id;
    all_collision(iter) = curr_collision;
    all_sidetoside_constraints(iter) = curr_sidetoside_constraints;
    
    fprintf('iteration %d finished, curr_score: %f, next_score: %f, alpha: %f, u: %f\n',...
        iter, curr_score, next_score, alpha, u);
    iter = iter + 1;
end

% figure
% data = pair_spatial_rels_location(parent.obj_type, object.obj_type).spatial_rel;
% scatter(data(:,1), data(:,2));
% plot(data(:,4), 'o');

% figure
% scatter(samples_xy(:,1), samples_xy(:,2));
% plot(1:100, samples_angle(1:100));

% figure
% plot(1:iter-1, all_score);

end


function pairs_prob = compute_pair_probability(object, ...
    pair_objects, pair_spatial_rels_location)
%computes each pair probability based on the information from spatial
%relations

obj_type = object.obj_type;
pfreq = zeros(length(pair_objects),1);

for oid = 1:length(pair_objects)
    ptype = pair_objects(oid).obj_type;
    data = pair_spatial_rels_location(ptype, obj_type).spatial_rel;
    pfreq(oid) = size(data, 1);
end

if sum(pfreq) == 0
    pairs_prob = [];
    return
end
pairs_prob = pfreq ./ sum(pfreq);

end

function [xy_clusters_prob, angle_clusters_prob] = compute_cluster_probability(...
    object, pair_objects, kmeans_matrix)
% computes clusters probability for each pair for xy and angle, separately

obj_type = object.obj_type;

for oid = 1:length(pair_objects)
    ptype = pair_objects(oid).obj_type;
    kmeans_xy = kmeans_matrix(ptype, obj_type).kmeans_xy;
    kmeans_angle = kmeans_matrix(ptype, obj_type).kmeans_angle;
    
    if isempty(kmeans_xy) || isempty(kmeans_angle)
        continue
    end
    
    %find the probability of each cluster for this pair
    xy_freq = zeros(kmeans_xy.num_cluster,1);
    for i = 1:kmeans_xy.num_cluster
        xy_freq(i) = length( find(kmeans_xy.cluster_index == i) );
    end
    xy_prob = xy_freq ./ length(kmeans_xy.cluster_index);
    
    angle_freq = zeros(kmeans_angle.num_cluster,1);
    for i = 1:kmeans_angle.num_cluster
        angle_freq(i) = length( find(kmeans_angle.cluster_index == i) );
    end
    angle_prob = angle_freq ./ length(kmeans_angle.cluster_index);
    
    xy_clusters_prob(oid).prob = xy_prob;
    angle_clusters_prob(oid).prob = angle_prob;
end


end
