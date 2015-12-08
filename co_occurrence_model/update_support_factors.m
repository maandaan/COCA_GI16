function extra_factors = update_support_factors( support_matrix, singlevar_factors, supp_factors, mapping_nodes_names )
%UPDATE_SUPPORT_FACTORS Summary of this function goes here
%   Detailed explanation goes here

Consts;
factors = supp_factors;

cat_count = size(support_matrix, 1);
support_rels_count = sum(sum(sum(support_matrix)));

for fid = 1:length(singlevar_factors)
    var = singlevar_factors(fid).var;
    cat_split = strsplit(mapping_nodes_names{var}, '_');
    category = cat_split{1};
    objtype = get_object_type_bedroom({category});
    
    continue_flag = 0;
    for sfid = 1:length(factors)
        vars = factors(sfid).var;
        if vars(2) == objtype
            continue_flag = 1;
            
            %multiple instances of a category
            if var > cat_count
                f.var = [vars(1), var];
                f.factor_type = factors(sfid).factor_type;
                f.card = [2,2];
                f.val = factors(sfid).val;
                factors = [factors, f];
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
%     supp_prob = top_support(1) / support_rels_count;
    supp_prob = top_support(1) / sum(support_matrix(:,supporter,r));
    f.var = [supporter, objtype];
    f.card = [2,2];
    f.factor_type = r + 1;
    f.val = zeros(1,prod(f.card));
    
    f = SetValueOfAssignment(f,[2,2], supp_prob);
    f = SetValueOfAssignment(f,[2,1], 1 - supp_prob);
    f = SetValueOfAssignment(f,[1,2], sum(top_support(2:end)) / sum(top_support));
%     f = SetValueOfAssignment(f,[1,2], sum(top_support(2:end)) / support_rels_count);
    f = SetValueOfAssignment(f,[1,1], 1 - GetValueOfAssignment(f, [1,2]));
    
%     CPT = ones(2,2);
%     CPT(2,2) = supp_prob; % both variables equal to one
%     CPT(2,1) = 1 - CPT(2,2); % supporter = 1, supported = 0
%     % supporter = 0, supported = 1, all the other supporting relations for supported object, but not by this supporting surface
%     CPT(1,2) = sum(top_support(2:end)) / sum(top_support);
%     CPT(1,1) = 1 - CPT(1,2); % both variables equal to zero

%     energy = -support_matrix(objtype, supporter, r) / sum(sum(sum(support_matrix)));
%     CPT(end) = exp(-energy);
%     
%     cpt_struct = struct('CPT', CPT);
    factors = [factors, f];
%     edges = [edges; supporter objtype factor_type];
end

orig_factors_length = length(supp_factors);
extra_factors = factors(orig_factors_length+1:end);

end

