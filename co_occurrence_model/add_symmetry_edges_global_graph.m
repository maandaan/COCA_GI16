function [ edges, factors, symm_prob_avg, symm_count ] = add_symmetry_edges_global_graph( scene_count, symmetry_relations, mapping_nodes_names )
%ADD_SYMMETRY_EDGES_GLOBAL_GRAPH adds symmetry groups and edges to the
%global graph.

Consts;

%add symmetry edges, e.g. for a group of 2 bedsides symmetric w.r.t a bed,
%a symm_g edge between bedside_1 and bedside_2 and two symm_resp edges
%between bedside_1 and bed_1, bedside_2 and bed_2
symmetry_thresh = floor(0.005 * scene_count);
symm_count = 0;
symm_prob = 0;
edges = [];factors = struct('variables', [], 'factor_type', [], 'potential_func', []);
temp = {mapping_nodes_names(:)};

for sid = 1:length(symmetry_relations)
    if symmetry_relations(sid).outside_obj_freq < symmetry_thresh
        continue
    end
    
    category = get_object_type_bedroom( symmetry_relations(sid).obj_cat );
    no_instance = symmetry_relations(sid).instance_count;
    outside_obj = symmetry_relations(sid).outside_obj_cat;
    
    variables = [];
    for icid = 1:no_instance
        %add symmetric w.r.t edges, if any
        node_name = [category{1} '_' num2str(icid)];
        start_node = find(strcmp(temp{:}, node_name));
        variables = [variables, start_node];
        if outside_obj ~= 0
            edges = [edges; start_node outside_obj symm_resp];
        end
        
        %if this is the last instance, there's no need to add new edges
        if icid == no_instance
            break
        end
        %add symmetry edges between bedside_1 and bedside_2, bedside_2 and
        %bedside_3
        node_name = [category{1} '_' num2str(icid+1)];
        end_node = find(strcmp(temp{:}, node_name));
        
        edges = [edges; start_node end_node symm_g];    
    end
    
    symm_count = symm_count + 1;
    symm_prob = symm_prob + symmetry_relations(sid).outside_obj_freq / scene_count;

    if outside_obj ~= 0
        factor_type = symm_resp;
        variables = [variables, outside_obj];
    else
        factor_type = symm_g;
    end
%     cpt_struct = compute_cpt_symmetry(variables, symmetry_relations, sid, symmetry_thresh, scene_count);
    pf = ones(2^length(variables), 1);
    dims = repmat(2,1,length(variables));
    pf = reshape(pf, dims);
    
    energy = -symmetry_relations(sid).outside_obj_freq / scene_count;
    pf(end) = exp(-energy);
    potential_func = struct('PF', pf);
    
    factors = [factors; struct('variables', variables, 'factor_type', factor_type, 'potential_func', potential_func)];
end

factors = factors(2:end);
symm_prob_avg = symm_prob / symm_count;

end

function cpt_struct = compute_cpt_symmetry(variables, symmetry_relations, sid, symmetry_thresh, scene_count)
% computes CPT for a symmetry group
node_count = length(variables);
CPT = zeros(2^node_count, 1 );
dims = repmat(2, 1, node_count);
CPT = reshape(CPT, dims);
outside_obj = symmetry_relations(sid).outside_obj_cat;

% if there's a reference object for symmetry, some rows will be non-zero
if outside_obj ~= 0
    ind = 2^(node_count-1);
    other_rows = structfind(symmetry_relations, 'obj_cat', symmetry_relations(sid).obj_cat);
    other_rows = intersect(other_rows, structfind(symmetry_relations, 'instance_count', symmetry_relations(sid).instance_count));
    count = 0;
    for rid = 1:length(other_rows)
        row = other_rows(rid);
        if symmetry_relations(row).outside_obj_freq < symmetry_thresh || row == sid
            continue
        end
        count = count + symmetry_relations(row).outside_obj_freq;
    end
    CPT(ind) = count / scene_count;
end

CPT(end) = symmetry_relations(sid).outside_obj_freq / scene_count;
cpt_struct = struct('CPT', CPT);
end

