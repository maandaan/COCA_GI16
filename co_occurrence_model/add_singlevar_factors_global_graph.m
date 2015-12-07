function [ factors ] = add_singlevar_factors_global_graph( scene_count, instances_freq, mapping_nodes_names, validnodes )
%ADD_SINGLEVAR_FACTORS_GLOBAL_GRAPH adds factors with one variable relating
%of the occurrence probability of that node (variable).

Consts;
factors = struct('variables', [], 'factor_type', [], 'potential_func', []);

count = 1;
for nid = 1:length(validnodes)
    node = validnodes(nid);
    pf = zeros(2,1);
    if node == 55 || node == 56 %floor or wall
        continue
    end
    
    nodelabel = mapping_nodes_names{node};
    nodelabel_split = strsplit(nodelabel, '_');
    obj_cat_str = nodelabel_split{1};
    obj_cat = get_object_type_bedroom({obj_cat_str});
    no_instance = str2double(nodelabel_split{2});
    
    freq = instances_freq(obj_cat).freq / scene_count;
    energy = -freq(no_instance);
    pf(2) = exp(-energy);
    pf(1) = 1;
    
    
    potential_func = struct('PF', pf);
    factors(count,1).variables = validnodes(nid);
    factors(count,1).factor_type = occurrence;
    factors(count,1).potential_func = potential_func;
    count = count + 1;
end

% factors = factors(2:end);

end

