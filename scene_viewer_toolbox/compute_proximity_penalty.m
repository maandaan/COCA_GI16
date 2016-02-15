function proximity_penalty = compute_proximity_penalty( scene, obj, oid )
%COMPUTE_PROXIMITY_PENALTY computes the proximity penalty which is used to
%prevent multiple instances of a category from being concentrated around
%the same mode.

Consts_fisher;
% load(pairwise_relations_file, 'pairwise_relations');
load(pairwise_relations_file_SUNRGBD, 'pairwise_relations');
proximity_penalty = 1;

type = obj.obj_type;
obj_center = mean(obj.corners);
data = pairwise_relations(type, type).relations;
avg_dist = 0;
count = 0;
if ~isempty(data)
    for i = 1:size(data,1)
        avg_dist = avg_dist + norm(data(i,1:3));
        count = count + 1;
    end
    avg_dist = avg_dist / count;
end

if avg_dist == 0 %no data available for multiple instances of this category
    return
end

for pid = 1:length(scene)
    if pid == oid 
        continue
    end
    
    pair = scene(pid);
    if pair.obj_type ~= type
        continue
    end
    
    pair_center = mean(pair.corners);
    this_dist = norm(pair_center - obj_center);
    proximity_penalty = 1 - exp(-((this_dist^2) / (2* avg_dist^2)));
end

end

