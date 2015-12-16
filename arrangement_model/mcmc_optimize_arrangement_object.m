function [ all_xy, all_angle, all_score, all_pid ] = ...
    mcmc_optimize_arrangement_object( object, pair_objects, holistic_scene, num_iter )
%MCMC_ARRANGEMENT samples a location and angle for each object relative to
%it's pair objects.

Consts;
load(kmeans_file, 'kmeans_matrix');
load(pairwise_locations_file, 'pair_spatial_rels_location');

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

%assumption: the first object in the local scene is always the supporting
%surface (parent)
pair_id = 1;

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

parent = pair_objects(pair_id);
parent_dims = pair_objects(pair_id).dims .* pair_objects(pair_id).scale;
object_dims = object.dims .* object.scale;
curr_xy = [-parent_dims(1)/2 + object_dims(1)/2 0];
curr_xy = [curr_xy(1)/(parent_dims(1)/2), curr_xy(2)/(parent_dims(2)/2)];
if parent.obj_type == get_object_type_bedroom({'room'})
    curr_angle = 90;
else
    curr_angle = 0;
end

curr_score = compute_arrangement_cost_kmeans(object, pair_objects, pair_id,...
    curr_xy, curr_angle, kmeans_matrix);

all_xy = zeros(num_iter, 2);
samples_xy = zeros(num_iter, 2);
all_angle = zeros(num_iter, 1);
samples_angle = zeros(num_iter, 1);
all_score = zeros(num_iter, 1);
all_pid = zeros(num_iter, 1);

iter = 1;
collision_count = 0;
while iter <= num_iter && collision_count <= num_iter/2
    
    % choose next sample
%     r = rand;
%     next_pair_id = sum(r >= cumsum([0, pairs_prob']));
    next_pair_id = 1;
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
    
    %check for availability on the support surface
    x = next_xy(1);
    y = next_xy(2);
    p = parent_dims / 2;
    o = object_dims / 2;
    if x < -1 + o(1)/p(1) || x > 1 - o(1)/p(1) || ...
            y < -1 + o(2)/p(2) || y > 1 - o(2)/p(2)
        fprintf('Not available space on the supporting surface!!\n');
        continue
    end
    
    %check for collision
    x = x .* (parent_dims(1) / 2);
    y = y .* (parent_dims(2) / 2);
    z = mean(object.corners(:,3));
    global_xyz = inv_convert_coordinates(-mean(parent.corners), parent.orientation, [x y 0]);
    theta = compute_theta_from_orientation(pair_objects(next_pair_id).orientation);
    angle = theta + degtorad(next_angle);
    object_orient = [cos(angle) sin(angle) 0];
    if check_collision( [global_xyz(1:2) z], object_dims, object_orient, holistic_scene )
        fprintf('Collision occures for this placement!!\n');
        collision_count = collision_count + 1;
        continue
    end
    collision_count = 0;
  
    samples_xy(iter,:) = next_xy;
    samples_angle(iter) = next_angle;
    next_score = compute_arrangement_cost_kmeans(object, pair_objects, next_pair_id,...
        next_xy, next_angle, kmeans_matrix);
    
    %mcmc sampling
    ratio_score = curr_score / next_score;
    alpha = min(1, ratio_score);
    u = rand;
    if alpha > u
        curr_xy = next_xy;
        curr_angle = next_angle;
        curr_score = next_score;
        pair_id = next_pair_id;
    end
    all_xy(iter, :) = curr_xy;
    all_angle(iter) = curr_angle;
    all_score(iter) = curr_score;
    all_pid(iter) = pair_id;
    
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
% plot(1:iter, all_score);

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
