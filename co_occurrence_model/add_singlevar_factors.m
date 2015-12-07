function factors = add_singlevar_factors( scene_count, instances_freq, mapping_nodes_names, validnodes )
%ADD_SINGLEVAR_FACTORS updated version of
%add_singlevar_factors_global_graph with factor graph toolbox

Consts;
factors = [];

for nid = 1:length(validnodes)
    
    f.var = validnodes(nid);
    if f.var == 55 || f.var == 56 %floor or wall
        continue
    end
    f.card = 2;
    f.factor_type = occurrence;
    f.val = [0,0];
    
    nodelabel = mapping_nodes_names{f.var};
    nodelabel_split = strsplit(nodelabel, '_');
    obj_cat_str = nodelabel_split{1};
    obj_cat = get_object_type_bedroom({obj_cat_str});
    no_instance = str2double(nodelabel_split{2});
    freq = instances_freq(obj_cat).freq / scene_count;
    prob = sum(freq(no_instance:end));
        
    f = SetValueOfAssignment(f, 2, prob);
    f = SetValueOfAssignment(f, 1, 1 - prob);
    
    factors = [factors, f];
end
end

