function factors = add_support_factors( support_matrix )
%ADD_SUPPORT_FACTORS has the same functionality as
%add_support_edges_global_graph with the updated use of Factor Graph
%Toolbox

Consts;
support_thresh = 0.1 * bedroom_support_scene_size;
factors = [];
support_rels_count = sum(sum(sum(support_matrix)));

for i = 1:size(support_matrix,1)
       
    [top_support, top_ind] = sort([support_matrix(i,:,1),support_matrix(i,:,2)],'descend');
    
    if i == 28
        continue
    end
    
    % precomputing the conditional probabilities relating to support, for
    % each possible supporter
    support_prob = zeros(1, 3);
    for k = 1:3
        if top_ind(k) > length(support_matrix(i,:,1)) %support from behind
            supporter = top_ind(k) - length(support_matrix(i,:,1));
            r = 2;
        else %support from below
            supporter = top_ind(k);
            r = 1;
        end
        
        if sum( sum(support_matrix(:,supporter,r))) == 0 || sum(support_matrix(:,supporter,r)) < support_thresh
            support_prob(k) = 0;
        else
%             support_prob(k) = support_matrix(i,supporter,r) / support_rels_count;
            support_prob(k) = support_matrix(i,supporter,r) / sum(support_matrix(:,supporter,r));
        end
    end
    
    for j = 1:3
        if top_support(j) > support_thresh % i is supported by j
            if top_ind(j) > length(support_matrix(i,:,1))
                parent_ind = top_ind(j) - length(support_matrix(i,:,1));
                factor_type = suppedge_behind;
            else
                parent_ind = top_ind(j);
                factor_type = suppedge_below;
            end
            
            if parent_ind == 28
                continue
            end
            
            f.var = [parent_ind, i];
            f.card = [2, 2];
            f.factor_type = factor_type;
            f.val = zeros(1,prod(f.card));
            
            f = SetValueOfAssignment(f, [2 2], support_prob(j)); % both variables equal to one
            f = SetValueOfAssignment(f, [2 1], 1 - support_prob(j));
            f = SetValueOfAssignment(f, [1 2], sum(support_prob) - support_prob(j));
%             (sum (top_support(1:3)) - top_support(j)) / sum(sum(support_matrix(i,:,:)));
            f = SetValueOfAssignment(f, [1 1], 1 - GetValueOfAssignment(f, [1 2]));
            
            factors = [factors, f];
        end
    end
end

end

