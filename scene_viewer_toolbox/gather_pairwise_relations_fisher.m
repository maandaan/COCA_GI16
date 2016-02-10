function pairwise_relations = gather_pairwise_relations_fisher
%GATHER_PAIRWISE_RELATIONS_FISHER collects pairwise spatial
%relations between objects including the angle and the relative location
%(the coordinates of an object center in another one's frame)

Consts_fisher;
load(fisher_scenes_file, 'fisher_scenes');

categories_count = 54; %from get_object_type_bedroom.m
%spatial_rel is a nx4 matrix with three columns for relative locations and 4th column:
%angle, in degrees
pairwise_relations = repmat(struct('relations',[]), categories_count, categories_count);

for sid = 1:length(fisher_scenes)
    scene = fisher_scenes(sid).scene;
    
    for oid = 1:length(scene)
        obj = scene(oid);
        if isempty(obj.obj_type)
            continue
        end
        
        obj_cos = obj.transform(1,1) / obj.scale;
        obj_sin = obj.transform(1,2) / obj.scale;
        obj_center = mean(obj.corners);
        obj_orient = [obj_sin, obj_cos];
        
        for ooid = 1:length(scene)
            pair = scene(ooid);
            if ooid == oid || isempty(pair.obj_type) ...
                    || pair.obj_type == get_object_type_bedroom({'room'})
                continue
            end
            
            pair_center = mean(pair.corners);
            pair_rel_center = convert_coordinates(obj_center, obj_cos, obj_sin, pair_center);
            
            pair_orient = [pair.transform(1,2) / pair.scale, pair.transform(1,1) / pair.scale];
            cos_angle = dot(obj_orient, pair_orient) / (norm(obj_orient) * norm(pair_orient));
            angle = acos( min(max(cos_angle, -1), 1) ); % for fixing the cases where the cos_angle = 1 or -1
            angle = radtodeg(angle);
            
            this_rel = pairwise_relations(obj.obj_type, pair.obj_type).relations;
            this_rel = [this_rel; pair_rel_center angle];
            pairwise_relations(obj.obj_type, pair.obj_type).relations = this_rel;
            
        end
    end
    
    fprintf('Finished scene %d:\n', sid);
end

%jitter the data to have enough samples to learn GMMs
no_samples = 200;
for r = 1:size(pairwise_relations, 1)
    for c = 1:size(pairwise_relations, 2)
        data = pairwise_relations(r,c).relations;
        if isempty(data)
            continue
        end
        
        center_samples = normrnd(0,25, no_samples,3);
        angle_samples = normrnd(0,5,1, no_samples);
                
        for i = 1:no_samples
%             new_pair_center = pair_center + center_samples(i,:);
%             new_pair_rel_center = convert_coordinates(...
%                 obj_center, obj_cos, obj_sin, new_pair_center);
            
            row_ind = randi(size(data,1));
            new_pair_rel_center = data(row_ind,1:3) + center_samples(i,:);
            new_angle = data(row_ind,4) + angle_samples(i);
            
            this_rel = pairwise_relations(r, c).relations;
            this_rel = [this_rel; new_pair_rel_center new_angle];
            pairwise_relations(r, c).relations = this_rel;
        end
    end
end

save(pairwise_relations_file, 'pairwise_relations');

end

