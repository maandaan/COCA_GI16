function [ edges, factors, single_node_focals, focal_count ] = ...
    add_proximity_edges_global_graph( mapping_nodes_names, updated_focals )
%ADD_PROXIMITY_EDGES_GLOBAL_GRAPH adds proximity edges and groups to the
%global scene graph.

Consts;
load(sunrgbdmeta_file, 'SUNRGBDMeta');
load(valid_scene_indices, 'valid_scene_type_indices')

%proximity edges from focals (if there are more than one instance of a
%category, e.g. 3 chairs and a bed, the edges would be: bed_1 -> chair_1 ->
%chair_2 -> chair_3 -> bed_1
edges = [];
temp = {mapping_nodes_names(:)};
single_node_focals = [];
factors = struct('variables', [], 'factor_type', [], 'potential_func', []);

for fid = 1:length(updated_focals.subgraphs)
    focal = updated_focals.subgraphs{fid};
    if isempty(focal.edges)
        single_node_focals = [single_node_focals, focal.nodelabels];
        continue
    end
    
    [unique_nodes, ~, c] = unique(focal.nodelabels); 
    count_uniques = hist(c, length(unique_nodes));
    if length(unique_nodes) < 2
        continue
    end
    
    variables = [];
    for nid = 1:length(unique_nodes)
        
        variables = [variables, unique_nodes(nid)];
        if nid == length(unique_nodes) && nid == 2 && count_uniques(nid) == 1
            break;
        elseif nid == length(unique_nodes)
            next = 1;
        else
            next = nid+1;
        end
        
        if count_uniques(nid) == 1
            edges = [edges; unique_nodes(nid) unique_nodes(next) pedge];
        else
            category = get_object_type_bedroom(unique_nodes(nid));
            for cid = 1:count_uniques(nid)-1 
                node_name = [category{1} '_' num2str(cid)];
                start_node = find(strcmp(temp{:}, node_name));
                
                node_name = [category{1} '_' num2str(cid+1)];
                end_node = find(strcmp(temp{:}, node_name));
                edges = [edges; start_node end_node pedge];
                variables = [variables, end_node];
            end
            % add the last edge
            node_name = [category{1} '_' num2str( count_uniques(nid) )];
            start_node = find(strcmp(temp{:}, node_name));
            edges = [edges; start_node unique_nodes(next) pedge];
        end
    end
    
    factor_type = pedge;
%     cpt_struct = compute_cpt_focals(fid, updated_focals, SUNRGBDMeta, valid_scene_type_indices, variables);
    potential_func = compute_pf_focals(fid, updated_focals, SUNRGBDMeta, valid_scene_type_indices, variables);
%     CPT = cpt_struct.CPT;
    
    
    factors = [factors; struct('variables', variables, 'factor_type', factor_type, 'potential_func', potential_func)];
end

factors = factors(2:end);
focal_count = length(updated_focals.subgraphs);

end

