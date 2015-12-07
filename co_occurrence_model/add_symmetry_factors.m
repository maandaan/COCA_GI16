function factors = add_symmetry_factors( scene_count, symmetry_relations, mapping_nodes_names )
%ADD_SYMMETRY_FACTORS updated version of add_symmetry_edges_global_graph
%with factor graph toolbox

Consts;
factors = [];
symmetry_thresh = floor(0.005 * scene_count);

temp = {mapping_nodes_names(:)};

for sid = 1:length(symmetry_relations)
    
    if symmetry_relations(sid).outside_obj_freq < symmetry_thresh || ...
          symmetry_relations(sid).obj_cat == 28 || ...
          symmetry_relations(sid).outside_obj_cat == 28
        continue
    end
    
    category = get_object_type_bedroom( symmetry_relations(sid).obj_cat );
    no_instance = symmetry_relations(sid).instance_count;
    outside_obj = symmetry_relations(sid).outside_obj_cat;
    
    variables = [];
    for icid = 1:no_instance
        %add symmetric w.r.t edges, if any
        node_name = [category{1} '_' num2str(icid)];
        node_ind = find(strcmp(temp{:}, node_name));
        variables = [variables, node_ind];
    end
    
    if outside_obj ~= 0
        factor_type = symm_resp;
        variables = [variables, outside_obj];
    else
        factor_type = symm_g;
    end
    
    f.var = variables;
    f.card = repmat(2,1,length(f.var));
    f.factor_type = factor_type;
    f.val = zeros(1,prod(f.card));
    f = set_value_symmetry_factors(f, symmetry_relations, sid, symmetry_thresh, scene_count);
    
%     cpt_struct = compute_cpt_symmetry(variables, symmetry_relations, sid, symmetry_thresh, scene_count);
%     pf = ones(2^length(variables), 1);
%     dims = repmat(2,1,length(variables));
%     pf = reshape(pf, dims);
%     
%     energy = -symmetry_relations(sid).outside_obj_freq / scene_count;
%     pf(end) = exp(-energy);
%     potential_func = struct('PF', pf);
    
    factors = [factors, f];
end

end

function f = set_value_symmetry_factors(f, symmetry_relations, sid, symmetry_thresh, scene_count)

variables = f.var;
node_count = length(variables);
outside_obj = symmetry_relations(sid).outside_obj_cat;

% if there's a reference object for symmetry, some rows will be non-zero
if outside_obj ~= 0
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
    f = SetValueOfAssignment(f, [f.card(1:end-1), 1], count / scene_count);
end

f = SetValueOfAssignment(f, f.card, symmetry_relations(sid).outside_obj_freq / scene_count);

end


