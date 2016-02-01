function obj_rels_count = count_object_relations( scene, children )
%COUNT_OBJECT_RELATIONS counts the number of objects related to a specific
%object

obj_rels_count = zeros(length(children), 1);

for oid = 1:length(children)
    obj = scene(children(oid));
%     obj_rels = [];
    
    if isempty(obj.orientation_rels)
        if ~isempty(obj.symm_ref_id)
            obj_rels = [obj.symm_group_id'; {obj.symm_ref_id}];
        else
            obj_rels = obj.symm_group_id';
        end
    else
        if ~isempty(obj.symm_ref_id)
            obj_rels = [obj.symm_group_id'; {obj.symm_ref_id}; ...
                {obj.orientation_rels(:).pair_obj_id}'];
        else
            obj_rels = [obj.symm_group_id'; ...
                {obj.orientation_rels(:).pair_obj_id}'];
        end
    end
    
    if isempty(obj_rels)
        continue
    end
    first_element = obj_rels(1,:);
    if isempty(first_element{1})
        obj_rels = obj_rels(2:end,:);
    end
    try
        unique_ids = unique(obj_rels);
    catch
        fprintf('error occurred for this scene!!!\n');
    end
    
    if isempty(obj.symm_group_id)
        obj_rels_count(oid) = length(unique_ids);
    else
        obj_rels_count(oid) = length(unique_ids) - 1;
    end
end

end

