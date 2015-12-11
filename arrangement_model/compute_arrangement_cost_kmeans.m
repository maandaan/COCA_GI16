function score = compute_arrangement_cost_kmeans( object, pair_objects, pair_id,...
    curr_xy, curr_angle, kmeans_matrix )
%COMPUTE_ARRANGEMENT_COST_KMEANS computes the score for an arrangement
%according to the sum of distance of the point to cluster centroids for all
%pairs

orig_theta = compute_rotval_from_orientation(pair_objects(pair_id).orientation);
ref = pair_objects(pair_id);
ref_dims = ref.dims .* ref.scale;

score = 0;
for oid = 1:length(pair_objects)
%     if pair_objects(oid).obj_type == get_object_type_bedroom({'room'})
%         continue
%     end
        
    pair = pair_objects(oid);
    pair_dims = pair.dims .* pair.scale;
    if oid == pair_id
        rel_xy = curr_xy;
        rel_angle = curr_angle;
    else
%         this_theta = compute_rotval_from_orientation(pair.orientation);
%         cos_t = cos(this_theta - orig_theta);
%         sin_t = sin(this_theta - orig_theta);
        
        curr_xy = [curr_xy(1)*(ref_dims(1) / 2), curr_xy(2)*(ref_dims(2) / 2)];
    
        cos_t = pair.orientation(2) / norm(pair.orientation);
        sin_t = -pair.orientation(1) / norm(pair.orientation);
        ref = pair_objects(pair_id);
        %convert the current xy to global coordinates
        global_xyz = inv_convert_coordinates(-mean(ref.corners), ref.orientation, [curr_xy 0]);
        %convert from global coordinates to local frame
        rel_xyz = convert_coordinates(mean(pair.corners), cos_t, sin_t, global_xyz);
        rel_xy = rel_xyz(1:2);
        rel_xy = [rel_xy(1) / (pair_dims(1)/2), rel_xy(2) / (pair_dims(2)/2)];
        
        theta = radtodeg(compute_theta_from_orientation(ref.orientation));
        abs_angle = curr_angle + theta;
        new_orient = [cos(degtorad(abs_angle)) sin(degtorad(abs_angle)) 0];
        cos_angle = dot(new_orient, pair.orientation) / (norm(new_orient) * norm(pair.orientation));
        angle = acos( min(max(cos_angle, -1), 1) ); 
        rel_angle = radtodeg(angle);
    end
    
    kmeans_xy = kmeans_matrix(pair.obj_type, object.obj_type).kmeans_xy;
    kmeans_angle = kmeans_matrix(pair.obj_type, object.obj_type).kmeans_angle;
    xy_dist = compute_distance_from_clusters(rel_xy, kmeans_xy);
    angle_dist = compute_distance_from_clusters(rel_angle, kmeans_angle);
    
    score = score + xy_dist + angle_dist;
end

end

function theta = compute_rotval_from_orientation(orient)

if orient(2) == 0 && orient(1) < 0
    theta = pi/2;
    return
end

if orient(2) == 0 && orient(1) > 0
    theta = -pi/2;
    return
end

theta = atan(-orient(1) / orient(2));
if orient(2) < 0
    theta = theta + pi;
end

end

function dist = compute_distance_from_clusters(x, kmeans)

d = zeros(kmeans.num_cluster, 1);
for cid = 1:kmeans.num_cluster
    d(cid) = norm(x - kmeans.cluster_centroid(cid,:));
end
dist = min(d);

end

