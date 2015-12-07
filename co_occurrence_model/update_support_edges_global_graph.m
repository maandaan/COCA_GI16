function [ edges, factors, support_count ] = update_support_edges_global_graph ...
    ( support_matrix, singlevar_factors, supp_factors, mapping_nodes_names )
%UPDATE_SUPPORT_EDGES_GLOBAL_GRAPH adds support factors for singlevar_factors which don't have support already

Consts;

edges = [];
factors = supp_factors;
% support_thresh = 0.1 * bedroom_support_scene_size;
% support_thresh_sum = 0;
% all_support_count = sum(sum(sum(support_matrix)));
cat_count = size(support_matrix, 1);

for fid = 1:length(singlevar_factors)
    var = singlevar_factors(fid).variables;
    cat_split = strsplit(mapping_nodes_names{var}, '_');
    category = cat_split{1};
    objtype = get_object_type_bedroom({category});
    
    continue_flag = 0;
    for sfid = 1:length(factors)
        vars = factors(sfid).variables;
        if vars(2) == objtype
            continue_flag = 1;
            
            %multiple instances of a category
            if var > cat_count
                variables = [vars(1), var];
                factor_type = factors(sfid).factor_type;
                potential_func = factors(sfid).potential_func;
                factors = [factors; struct('variables', variables, ...
                    'factor_type', factor_type, 'potential_func', potential_func)];
                edges = [edges; vars(1) var factor_type];
            end
        end
    end
    
    if continue_flag
        continue
    end
    
    [top_support, top_ind] = sort([support_matrix(objtype,:,1),support_matrix(objtype,:,2)],'descend');
    %detect support type
    if top_ind(1) > length(support_matrix(objtype,:,1))
        supporter = top_ind(1) - length(support_matrix(objtype,:,1));
        r = 2;
    else
        supporter = top_ind(1);
        r = 1;
    end
    supp_prob = top_support(1) / sum(support_matrix(:,supporter,r));
    variables = [supporter, objtype];
    factor_type = r + 1;
    
    CPT = ones(2,2);
%     CPT(2,2) = supp_prob; % both variables equal to one
%     CPT(2,1) = 1 - CPT(2,2); % supporter = 1, supported = 0
%     % supporter = 0, supported = 1, all the other supporting relations for supported object, but not by this supporting surface
%     CPT(1,2) = sum(top_support(2:end)) / sum(top_support);
%     CPT(1,1) = 1 - CPT(1,2); % both variables equal to zero

    energy = -support_matrix(objtype, supporter, r) / sum(sum(sum(support_matrix)));
    CPT(end) = exp(-energy);
    
    cpt_struct = struct('CPT', CPT);
    factors = [factors; struct('variables', variables, ...
        'factor_type', factor_type, 'potential_func', cpt_struct)];
    edges = [edges; supporter objtype factor_type];
end

support_count = size(edges, 1);


end

