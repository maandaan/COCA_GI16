function objects_with_support = assign_support_surfaces(...
    sampled_objects, all_nodes, input_scene, factors, mapping_nodes_names)
%ASSIGN_SUPPORT_SURFACES checks whether each new object to be inserted in
%the scene has an available supporting surface or not.

Consts;
s = repmat(struct('identifier', [], 'obj_type',[], 'obj_category',[], ...
    'supporter_id', [], 'supporter', [], 'supporter_category', [], 'support_type', [], ...
    'symm_group_id', [], 'symm_ref_id', [], 'orientation_rels', [], 'modelname', [], ...
    'BB', [], 'dims', [], 'scale', [], 'children', [], 'corners', [], ...
    'orientation', [], 'transform',[], 'optimized_location', 0), length(sampled_objects), 1);

for oid = 1:length(sampled_objects)
    obj = sampled_objects(oid);
    max_prob = 0;
    support = 0;
    support_type = 0;
    
    % check whether the sample is the n-th instance (n!=1) of a category
    parent = 0;
    name = mapping_nodes_names{obj};
    name_split = strsplit(name, '_');
    category = [name_split{1:end-1}];
%     if obj > 56
%         parent = get_object_type_bedroom({category});
%     end
    
    for sid = 1:length(all_nodes)
        if all_nodes(sid) == obj
            continue
        end
        % if n-th instance of a category, the same support as one instace
        % of that category
%         if parent == 0
%             vars = [all_nodes(sid), obj];
%         else
%             vars = [all_nodes(sid), parent];
%         end
        
        vars = [all_nodes(sid), obj];
        row = structfind(factors, 'var', vars);
        supp_row = [structfind(factors, 'factor_type', suppedge_below), structfind(factors, 'factor_type', suppedge_behind)];
        row = intersect(row, supp_row);
        if isempty(row)
            continue
        end
        prob = GetValueOfAssignment(factors(row), [2 2]);
%         prob = factors(row).potential_func.CPT(4);
        if prob > max_prob
            max_prob = prob;
            support = all_nodes(sid);
            support_type = factors(row).factor_type;
        end
    end
    
    % no support found, assign floor as support
    if max_prob == 0
        support = length(mapping_nodes_names)-1;
        support_type = suppedge_below;
    end
    
    s(oid).obj_type = get_object_type_bedroom({category});
    s(oid).obj_category = category;
    s(oid).identifier = [category '_' num2str(randi(1000))];
    s(oid).supporter = support;
    s(oid).support_type = support_type;
%     if support == 55
%         s(oid).supporter_category = 'floor';
%     elseif support == 56
%         s(oid).supporter_category = 'wall';
%     else
        s(oid).supporter_category = get_object_type_bedroom(support);
%     end
end

all_obj = [input_scene; s];
for oid = 1:length(s)
    supporter_type = s(oid).supporter;
    if supporter_type >= get_object_type_bedroom({'floor'}) 
        supporter_type = get_object_type_bedroom({'room'});
    end
    ind = structfind(all_obj, 'obj_type', supporter_type);
    p_row = randi(length(ind));
    s(oid).supporter_id = all_obj(ind(p_row)).identifier;
end

objects_with_support = [input_scene; s];

end
