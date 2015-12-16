function [ edges, factors, support_thresh_avg, support_count ] = add_support_edges_global_graph( support_matrix )
%ADD_SUPPORT_EDGES_GLOBAL_GRAPH adds salient support relations to the
%global scene graph

Consts;

edges = [];
factors = struct('variables', [], 'factor_type', [], 'potential_func', []);
support_thresh = 0.1 * bedroom_support_scene_size;
support_thresh_sum = 0;
% all_support_count = sum(sum(sum(support_matrix)));

for i = 1:size(support_matrix,1)
       
    [top_support, top_ind] = sort([support_matrix(i,:,1),support_matrix(i,:,2)],'descend');
    % precomputing the conditional probabilities relating to support, for
    % each possible supporter
    support_prob = zeros(1, 3);
    for k = 1:3
        if top_ind(k) > length(support_matrix(i,:,1))
            supporter = top_ind(k) - length(support_matrix(i,:,1));
            r = 2;
        else
            supporter = top_ind(k);
            r = 1;
        end
        
        if sum( sum(support_matrix(:,supporter,r))) == 0 || sum(support_matrix(:,supporter,r)) < support_thresh
            support_prob(k) = 0;
        else
            support_prob(k) = support_matrix(i,supporter,r) / sum(support_matrix(:,supporter,r));
        end
    end
    
    for j = 1:3
        if top_support(j) > support_thresh % i is supported by j
            if top_ind(j) > length(support_matrix(i,:,1))
                parent_ind = top_ind(j) - length(support_matrix(i,:,1));
                edge_type = suppedge_behind;
            else
                parent_ind = top_ind(j);
                edge_type = suppedge_below;
            end
            
            new_edge = [parent_ind i edge_type];
            edges = [edges; new_edge];
            support_thresh_sum = support_thresh_sum + top_support(j);
            
            variables = [parent_ind, i];
            factor_type = edge_type;
            
%             supporter_index = parent_ind;
            CPT = ones(length(variables), length(variables));
%             CPT(2,2) = support_prob(j); % both variables equal to one
%             CPT(2,1) = 1 - CPT(2,2); % supporter = 1, supported = 0
%             % supporter = 0, supported = 1, all the other supporting relations for supported object, but not by this supporting surface
% %             CPT(1,2) = sum (support_prob) - support_prob(j);
%             CPT(1,2) = (sum (top_support(1:3)) - top_support(j)) / sum(sum(support_matrix(i,:,:)));
%             CPT(1,1) = 1 - CPT(1,2); % both variables equal to zero
            energy = -support_matrix(i, parent_ind, edge_type-1) / sum(sum(sum(support_matrix)));
            CPT(end) = exp(-energy);
            cpt_struct = struct('CPT', CPT);
            
            factors = [factors; struct('variables', variables, 'factor_type', factor_type, 'potential_func', cpt_struct)];
        end
    end
end
factors = factors(2:end);
support_thresh_avg = support_thresh_sum ./ size(edges, 1);
support_count = size(edges, 1);

end

