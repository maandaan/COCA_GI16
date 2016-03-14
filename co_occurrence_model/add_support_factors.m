function factors = add_support_factors( support_matrix, mapping_nodes_names )
%ADD_SUPPORT_FACTORS has the same functionality as
%add_support_edges_global_graph with the updated use of Factor Graph
%Toolbox

Consts;
support_thresh = 0.05 * bedroom_support_scene_size;
factors = [];
support_rels_count = sum(sum(sum(support_matrix)));
temp = {mapping_nodes_names(:)};
cat_count = size(support_matrix,1);

for i = 1:size(support_matrix,1)
       
    [top_support, top_ind] = sort([support_matrix(i,:,1),support_matrix(i,:,2)],'descend');
    
%     if ismember(i, [3,8,13,28])
%         continue
%     end
    
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
            if supporter == cat_count-1 || supporter == cat_count %room generally
                support_prob(k) = support_matrix(i,supporter,r) / ( sum(sum(support_matrix(:,cat_count-1,:))) + sum(sum(support_matrix(:,cat_count,:))) );
            else
                support_prob(k) = support_matrix(i,supporter,r) / sum(sum(support_matrix(:,supporter,:)));
            end
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
            
%             if ismember(parent_ind, [3,8,13,28])
%                 continue
%             end
            
            %finding the corresponding node labels
            cat_str = get_object_type_bedroom(i);
            node_name = [cat_str{1} '_' num2str(1)]; 
            supporting_node = find(strcmp(temp{:}, node_name));
            
%             if parent_ind >= cat_count - 1
            parent_str = get_object_type_bedroom(parent_ind);
            node_name = [parent_str{1} '_' num2str(1)]; 
            parent_node = find(strcmp(temp{:}, node_name));
            
            if isempty(supporting_node) || isempty(parent_node)
                continue
            end
            
%             f.var = [parent_ind, i];
            f.var = [parent_node, supporting_node];
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

