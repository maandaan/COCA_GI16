function pairwise_score = compute_pairwise_score( scene, obj, oid )
%COMPUTE_PAIRWISE_SCORE computes the score for the placement of an object
%based on the pairwise relations with other objects.

Consts_fisher;
load(gmm_pairwise_file, 'gmm_matrix');
load(gmm_weights_file, 'gmm_weights');

obj_center = mean(obj.corners);
obj_cos = obj.transform(1,1) / obj.scale;
obj_sin = obj.transform(1,2) / obj.scale;
obj_orient = [obj_sin, obj_cos];

pairwise_score = 0;
for pid = 1:length(scene)
    pair = scene(pid);
    if pid == oid || isempty(gmm_matrix(obj.obj_type,pair.obj_type).gmm_location)
        continue
    end
    
    gmm_l = gmm_matrix(obj.obj_type, pair.obj_type).gmm_location;
    gmm_a = gmm_matrix(obj.obj_type, pair.obj_type).gmm_angle;
    pair_center = mean(pair.corners);
    pair_rel_center = convert_coordinates(obj_center, obj_cos, obj_sin, pair_center);
    
    pair_orient = [pair.transform(1,2) / pair.scale, pair.transform(1,1) / pair.scale];
    cos_angle = dot(obj_orient, pair_orient) / (norm(obj_orient) * norm(pair_orient));
    angle = acos( min(max(cos_angle, -1), 1) ); % for fixing the cases where the cos_angle = 1 or -1
    angle = radtodeg(angle);
    
    weight = gmm_weights(obj.obj_type, pair.obj_type).weight;
    location_score = pdf(gmm_l, pair_rel_center);
    angle_score = pdf(gmm_a, angle);
    pairwise_score = pairwise_score + weight * (location_score + angle_score);
end

end

