function pairwise_score = compute_pairwise_score( scene, obj, oid )
%COMPUTE_PAIRWISE_SCORE computes the score for the placement of an object
%based on the pairwise relations with other objects.

Consts_fisher;
% load(gmm_pairwise_file, 'gmm_matrix');
% load(gmm_weights_file, 'gmm_weights');
% load(gmm_pairwise_file_SUNRGBD, 'gmm_matrix');
load(gmm_location_file_SUNRGBD, 'gmm_matrix');
load(gmm_weights_file_SUNRGBD, 'gmm_weights');

obj_center = mean(obj.corners);
% obj_cos = obj.transform(1,1) / obj.scale;
% obj_sin = obj.transform(1,2) / obj.scale;
obj_orient = obj.orientation(1:2);
obj_cos = obj_orient(1) / norm(obj_orient);
obj_sin = obj_orient(2) / norm(obj_orient);

pairwise_score = 0;
for pid = 1:length(scene)
    pair = scene(pid);
    if pid == oid || isempty(gmm_matrix(pair.obj_type, obj.obj_type).gmm_location)
        continue
    end
    
    gmm_l = gmm_matrix(pair.obj_type, obj.obj_type).gmm_location;
    gmm_a = gmm_matrix(pair.obj_type, obj.obj_type).gmm_angle;
    gmm = gmm_matrix(pair.obj_type, obj.obj_type).gmm;
    pair_center = mean(pair.corners);
    pair_rel_center = convert_coordinates(obj_center, obj_cos, obj_sin, pair_center);
    pair_dims = pair.dims .* pair.scale;
    pair_rel_center = [pair_rel_center(1) / (pair_dims(1)/2), ...
                       pair_rel_center(2) / (pair_dims(2)/2), ...
                       pair_rel_center(3) / (pair_dims(3)/2)];
    
%     pair_orient = [pair.transform(1,2) / pair.scale, pair.transform(1,1) / pair.scale];
    pair_orient = pair.orientation(1:2);
    cos_angle = dot(obj_orient, pair_orient) / (norm(obj_orient) * norm(pair_orient));
    angle = acos( min(max(cos_angle, -1), 1) ); % for fixing the cases where the cos_angle = 1 or -1
    angle = radtodeg(angle);
    
    weight = gmm_weights(pair.obj_type, obj.obj_type).weight;
    location_score = pdf(gmm_l, pair_rel_center);
    angle_score = pdf(gmm_a, angle);
    gmm_score = pdf(gmm, [pair_rel_center angle]);
%     pairwise_score = pairwise_score + weight * (location_score + angle_score);
    pairwise_score = pairwise_score + weight * gmm_score;
end

if pairwise_score == 0 %there were no pairs
    pairwise_score = 1;
    fprintf('Pairwise score is zero for obj %s!\n', obj.identifier);
end

end

