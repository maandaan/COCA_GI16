function [ factors, single_node_focals ] = add_proximity_factors( mapping_nodes_names, updated_focals )
%ADD_PROXIMITY_FACTORS the updated version of
%add_proximity_edges_global_graph.m with Factor Graph Toolbox.

Consts;
load(sunrgbdmeta_file, 'SUNRGBDMeta');
load(valid_scene_indices, 'valid_scene_type_indices');

temp = {mapping_nodes_names(:)};
single_node_focals = [];
factors = [];

for fid = 1:length(updated_focals.subgraphs)
    focal = updated_focals.subgraphs{fid};
    if isempty(focal.edges)
        if ~ismember(focal.nodelabels, [3,8,13,28])
            single_node_focals = [single_node_focals, focal.nodelabels];
        end
        continue
    end
    
    if ~isempty(find(ismember([3,8,13,28], focal.nodelabels),1))
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
        if count_uniques(nid) > 1
            category = get_object_type_bedroom(unique_nodes(nid));
            for cid = 2:count_uniques(nid)
               node_name = [category{1} '_' num2str(cid)]; 
               node_ind = find(strcmp(temp{:}, node_name));
               variables = [variables, node_ind];
            end
        end
        
%         if nid == length(unique_nodes) && nid == 2 && count_uniques(nid) == 1
%             break;
%         elseif nid == length(unique_nodes)
%             next = 1;
%         else
%             next = nid+1;
%         end
%         
%         if count_uniques(nid) == 1
%             edges = [edges; unique_nodes(nid) unique_nodes(next) pedge];
%         else
%             category = get_object_type_bedroom(unique_nodes(nid));
%             for cid = 1:count_uniques(nid)-1 
%                 node_name = [category{1} '_' num2str(cid)];
%                 start_node = find(strcmp(temp{:}, node_name));
%                 
%                 node_name = [category{1} '_' num2str(cid+1)];
%                 end_node = find(strcmp(temp{:}, node_name));
%                 edges = [edges; start_node end_node pedge];
%                 variables = [variables, end_node];
%             end
%             % add the last edge
%             node_name = [category{1} '_' num2str( count_uniques(nid) )];
%             start_node = find(strcmp(temp{:}, node_name));
%             edges = [edges; start_node unique_nodes(next) pedge];
%         end
    end
    
    f.var = variables;
    f.card = repmat(2, 1, length(variables));
    f.factor_type = pedge;
    f = set_value_proximity_factors(f, fid, updated_focals, SUNRGBDMeta, valid_scene_type_indices);
    
%     factor_type = pedge;
%     cpt_struct = compute_cpt_focals(fid, updated_focals, SUNRGBDMeta, valid_scene_type_indices, variables);
%     potential_func = compute_pf_focals(fid, updated_focals, SUNRGBDMeta, valid_scene_type_indices, variables);
%     CPT = cpt_struct.CPT;
    
    factors = [factors, f];
end


end

