function [ all_xy, all_angle, all_score, all_pid ] = ...
    mcmc_optimize_arrangement_object( object, pair_objects, num_iter )
%MCMC_ARRANGEMENT samples a location and angle for each object relative to
%it's pair objects.

Consts;
load(kmeans_file, 'kmeans_matrix');
load(pairwise_locations_file, 'pair_spatial_rels_location');

obj_type = object.obj_type;

%choose one pair object to sample
pairs_prob = compute_pair_probability(object, pair_objects, pair_spatial_rels_location);
if isempty(find(pairs_prob, 1))
    all_xy = [];
    all_angle = [];
    all_score = [];
    all_pid = [];
    return
end

rng shuffle
r = rand;
pair_id = sum(r >= cumsum([0, pairs_prob']));

%choose one cluster from that pair to sample
[xy_clusters_prob, angle_clusters_prob] = compute_cluster_probability(object, pair_objects, kmeans_matrix);
r = rand;
xy_cluster_id = sum(r >= cumsum([0, xy_clusters_prob(pair_id).prob']));
r = rand;
angle_cluster_id = sum(r >= cumsum([0, angle_clusters_prob(pair_id).prob']));

kmeans_xy = kmeans_matrix(pair_objects(pair_id).obj_type, obj_type).kmeans_xy;
kmeans_angle = kmeans_matrix(pair_objects(pair_id).obj_type, obj_type).kmeans_angle;

%initial placement
data = pair_spatial_rels_location(pair_objects(pair_id).obj_type, obj_type).spatial_rel;
xy_cluster_ind = find(kmeans_xy.cluster_index == xy_cluster_id);
angle_cluster_ind = find(kmeans_angle.cluster_index == angle_cluster_id);
curr_xy = data( xy_cluster_ind( randi( length(xy_cluster_ind))),1:2);
curr_angle = data( angle_cluster_ind( randi( length(angle_cluster_ind))),4);

curr_score = compute_arrangement_cost_kmeans(object, pair_objects, pair_id,...
    curr_xy, curr_angle, kmeans_matrix);

all_xy = zeros(num_iter, 2);
all_angle = zeros(num_iter, 1);
all_score = zeros(num_iter, 1);
all_pid = zeros(num_iter, 1);

for iter = 1:num_iter
    
    % choose next sample
    r = rand;
    next_pair_id = sum(r >= cumsum([0, pairs_prob']));
    r = rand;
    next_xy_cluster_id = sum(r >= cumsum([0, xy_clusters_prob(next_pair_id).prob']));
    r = rand;
    next_angle_cluster_id = sum(r >= cumsum([0, angle_clusters_prob(next_pair_id).prob']));
    
    next_kmeans_xy = kmeans_matrix(pair_objects(next_pair_id).obj_type, obj_type).kmeans_xy;
    next_kmeans_angle = kmeans_matrix(pair_objects(next_pair_id).obj_type, obj_type).kmeans_angle;
    
    next_data = pair_spatial_rels_location(pair_objects(next_pair_id).obj_type, obj_type).spatial_rel;
    
    next_xy_cluster_ind = find(next_kmeans_xy.cluster_index == next_xy_cluster_id);
    next_angle_cluster_ind = find(next_kmeans_angle.cluster_index == next_angle_cluster_id);
    
    %debug
    if length(next_xy_cluster_ind) < 1
        fprintf('How?\n');
    end
    
    next_xy = next_data( next_xy_cluster_ind( randi( length(next_xy_cluster_ind))),1:2);
    next_angle = next_data( next_angle_cluster_ind( randi( length(next_angle_cluster_ind))),4);
  
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
end

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
