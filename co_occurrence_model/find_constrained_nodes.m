function constraint_nodes = find_constrained_nodes( input_scene, all_vars, mapping_nodes_names )
%FIND_CONSTRAINED_NODES finds the constrained nodes which should be present
%in every config since they are in the input scene

floor_node = find(strcmp(mapping_nodes_names, 'floor_1'));
wall_node = find(strcmp(mapping_nodes_names, 'wall_1'));

obj_types = [];
other_objs = [input_scene(:).obj_type];
room_ind = find(other_objs == get_object_type_bedroom({'room'}));
if ~isempty(room_ind)
    other_objs = [other_objs(1:room_ind-1), other_objs(room_ind+1:end)];
    obj_types = [obj_types, floor_node, wall_node]; %floor and wall
end

% check for multiple instances of a category
[unique_types, ~, c] = unique(other_objs); 
count_uniques = hist(c, length(unique_types));
for tid = 1:length(unique_types)
%     if count_uniques(tid) == 1
%         obj_types = [obj_types, unique_types(tid)];
%         continue
%     end
    
    count = 1;
    category = get_object_type_bedroom(unique_types(tid));
    while count <= count_uniques(tid)
        name = [category{1} '_' num2str(count)];
        ind = find(strcmp(mapping_nodes_names, name));
        obj_types = [obj_types, ind];
        count = count + 1;
    end
end

% nodes that always should be in the solution
constraint_nodes = zeros(1, length(all_vars));
for oid = 1:length(obj_types)
    
    ind = find(all_vars == obj_types(oid), 1);
    if isempty(ind)
        fprintf('Warning! This object is not in the model!!\n');
        continue
    end
    constraint_nodes(ind) = 1;
end

end

