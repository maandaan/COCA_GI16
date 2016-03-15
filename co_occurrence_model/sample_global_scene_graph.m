function [ sampled_obj_with_support, sampled_objects, all_nodes, all_scores, all_samples ] = sample_global_scene_graph( input_scene )
%SAMPLE_GLOBAL_SCENE_GRAPH samples one or multiple objects to insert in the
%input scene (which can be empty or cluttered) based on the present object
%and factors in the global scene graph. 'input_scene' is just a list of
%object labels. (NOTE: This is the first version for sampling objects from
%the global scene graph which does exhaustive search to find the best
%configuration)

Consts;
load(global_scene_graph_file, 'global_scene_graph')
load(mapping_nodes_names_file, 'mapping_nodes_names')

obj_types = [];
floor_ind = find(strcmp(input_scene, 'floor'));
if ~isempty(floor_ind)
    obj_types = [obj_types, 55];
    input_scene = {input_scene{1:floor_ind-1}, input_scene{floor_ind+1:end}};
end

wall_ind = find(strcmp(input_scene, 'wall'));
if ~isempty(wall_ind)
    obj_types = [obj_types, 56];
    input_scene = {input_scene{1:wall_ind-1}, input_scene{wall_ind+1:end}};
end

if isempty(input_scene)
    other_objs = [];
else
    other_objs = get_object_type_bedroom(input_scene);
end

% check for multiple instances of a category
[unique_types, ~, c] = unique(other_objs); 
count_uniques = hist(c, length(unique_types));
for tid = 1:length(unique_types)
    if count_uniques(tid) == 1
        obj_types = [obj_types, unique_types(tid)];
        continue
    end
    
    count = 1;
    category = get_object_type_bedroom(unique_types(tid));
    while count <= count_uniques(tid)
        name = [category{1} '_' num2str(count)];
        ind = find(strcmp(mapping_nodes_names, name));
        obj_types = [obj_types, ind];
        count = count + 1;
    end
end

% obj_types = [obj_types, other_objs'];
present_nodes = zeros(1, length(global_scene_graph.nodes));
present_nodes(obj_types) = 1;
curr_pres_nodes = find(present_nodes);
factors = global_scene_graph.factors;
num_factors = length(factors);

max_config_score = 0;
all_scores = [];
all_samples = [];
count = 1;
for fid = 1:num_factors
    nodes = factors(fid).variables;
    factor_nodes_pres = intersect(curr_pres_nodes, nodes);
    if length(factor_nodes_pres) == length(nodes) %all corresponding nodes are already in the scene
        continue
    end
    
    new_nodes = setdiff(nodes, factor_nodes_pres);
    all_present_nodes = [new_nodes, curr_pres_nodes];
    all_present_nodes = sort(all_present_nodes);
    multi_instance = find(all_present_nodes > 56);
    % check that if e.g. cushion_2 is going to be inserted, cushion_1
    % should be there as well
    break_flag = 0;
    for i = 1:length(multi_instance)
        n = all_present_nodes(multi_instance(i));
        nodelabel = mapping_nodes_names{n};
        nodelabel_split = strsplit(nodelabel, '_');
        obj_cat_str = [nodelabel_split{1:end-1}];
        no_instance = str2double(nodelabel_split{end});
        parent_str = [obj_cat_str '_' num2str(no_instance-1)];
        parent_ind = find(strcmp(mapping_nodes_names, parent_str));
        if isempty(find(all_present_nodes == parent_ind))
            break_flag = 1;
            break;
        end
    end
    
    if break_flag
        continue
    end
    
    config_score = compute_config_score(global_scene_graph, all_present_nodes); 
    all_scores = [all_scores; config_score];
    temp = mapping_nodes_names(new_nodes);
    all_samples(count).nodes = temp;
    count = count + 1;
    
    if config_score > max_config_score
        max_config_score = config_score;
        sampled_objects = new_nodes;
        all_nodes = all_present_nodes;
    end
end

sampled_obj_with_support = assign_support_surfaces(sampled_objects, all_nodes, factors, mapping_nodes_names);

end



