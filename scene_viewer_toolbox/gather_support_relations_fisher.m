function support_relations = gather_support_relations_fisher
%GATHER_SUPPORT_RELATIONS_FISHER computes and collects surface descriptors
%for support relations.

Consts_fisher;
load(fisher_scenes_file, 'fisher_scenes');

categories_count = 54; %from get_object_type_bedroom.m
%the surface descriptor is: surface area and the height above the ground
support_relations = repmat(struct('descriptor',[]), categories_count, 1);

for sid = 1:length(fisher_scenes)
    scene = fisher_scenes(sid).scene;
    for oid = 1:length(scene)
        parent = scene(oid);
        children = parent.children;
        if isempty(children)
            continue
        end
        
        x_rng = max(parent.corners(1:4,1)) - min(parent.corners(1:4,1));
        y_rng = max(parent.corners(1:4,2)) - min(parent.corners(1:4,2));
        area = sqrt(x_rng * y_rng);
        
        for cid = 1:length(children)
            row_ind = structfind(scene, 'mindex', children(cid));
            if isempty(row_ind) || isempty(scene(row_ind).obj_type)
                continue
            end
            
            child = scene(row_ind);
            height = min(child.corners(:,3));
            
            this_rel = support_relations(child.obj_type).descriptor;
            this_rel = [this_rel; area height];
            support_relations(child.obj_type).descriptor = this_rel;
        end
    end
end

save(support_relations_file, 'support_relations');

end

