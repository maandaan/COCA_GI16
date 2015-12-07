function [ final_config, final_score, final_scene ] = mcmc_optimize_scene_config( ...
    input_scene, num_iter, epsilon, num_prev_iter )
%MCMC_OPTIMIZE_SCENE_CONFIG implements MCMC with Metropolis-Hastings
%algorithm to find the set of objects which optimize the scene
%configuration.

% input: num_iter: max number of iterations to run MCMC sampling (1000);
%        epsilon: if the score does not increase more than epsilon, end
%        optimization (0.0005);
%        num_prev_iter: number of previous iterations to check the
%        stability (150);

Consts;
load(global_factor_graph_file, 'factors', 'all_vars')
load(mapping_nodes_names_file, 'mapping_nodes_names')

% input_scene = (scene(:).obj)
% floor_ind = find(strcmp(input_scene, 'floor'));
% if ~isempty(floor_ind)
%     obj_types = [obj_types, 55];
%     input_scene = {input_scene{1:floor_ind-1}, input_scene{floor_ind+1:end}};
% end
% 
% wall_ind = find(strcmp(input_scene, 'wall'));
% if ~isempty(wall_ind)
%     obj_types = [obj_types, 56];
%     input_scene = {input_scene{1:wall_ind-1}, input_scene{wall_ind+1:end}};
% end
% 
% if isempty(input_scene)
%     other_objs = [];
% else
%     other_objs = get_object_type_bedroom(input_scene);
% end

constraint_nodes = find_constrained_nodes( input_scene, all_vars, mapping_nodes_names );
constraint_nodes_ind = find(constraint_nodes);

% factors = global_scene_graph.factors;
factors = factors(64:96);
num_factors = length(factors);
supp_rows = [structfind(factors, 'factor_type', suppedge_below), structfind(factors, 'factor_type', suppedge_behind)];

curr_config = constraint_nodes;
% active_factors = union(randi(num_factors, 1, 5), 20);
active_factors = randi(23, 1, 5);
inactive_factors = setdiff(1:num_factors, active_factors);
for fid = 1:length(active_factors)
    factor = factors(active_factors(fid));
    for vid = 1:length(factor.var)
        ind = find(all_vars == factor.var(vid));
        curr_config(ind) = 1;
    end
end
% active_factors = [];
% inactive_factors = 1:num_factors;

all_config = zeros(num_iter, length(all_vars));
inter_config = zeros(num_iter, length(all_vars));
all_score = zeros(num_iter, 1);
all_config(1,:) = curr_config;
inter_config(1,:) = curr_config;
all_score(1) = compute_config_score(factors, all_vars(constraint_nodes_ind));

prob_add = 0.35;
prob_del = 0.35;
prob_swap = 0.3;

numobj_lb = 10;
numobj_ub = 10;

iter = 2;
while iter < num_iter
    % randomly choose a factor
%     factor_ind = randi(num_factors);
%     nodes = factors(factor_ind).variables;
%     factor_nodes_constrained = intersect(constraint_nodes_ind, nodes);
%     
%     while length(factor_nodes_constrained) == length(nodes) %we should not change any nodes in this factor
%         factor_ind = randi(num_factors);
%         nodes = factors(factor_ind).variables;
%         factor_nodes_constrained = intersect(constraint_nodes_ind, nodes);
%     end
%     
%     % move: if the set of new nodes are already present, remove them and
%     % vice versa.
%     new_nodes = setdiff(nodes, factor_nodes_constrained);
%     next_config = curr_config;
% %     next_config(new_nodes) = ~curr_config(new_nodes);
%     next_config(new_nodes) = 1;
    fprintf('iteration %d\n', iter);
    
    curr_present_nodes = find(curr_config);
    curr_numobj = length(curr_present_nodes);
    if curr_numobj < numobj_lb
        prob_add = 1;
        prob_del = 0;
        prob_swap = 0;
    elseif curr_numobj > numobj_ub
        prob_add = 0;
        prob_del = 1;
        prob_swap = 0;
    else
        prob_add = 0;
        prob_del = 0;
        prob_swap = 1;
    end
    
    [next_config, next_active_factors, next_inactive_factors] = possible_move(...
        prob_add, prob_del, prob_swap, active_factors, inactive_factors, ...
        factors, constraint_nodes, all_vars);

    next_present_nodes = find(next_config);
    multi_instance = find(all_vars(next_present_nodes) > 56);
    % check that if e.g. cushion_2 is going to be inserted, cushion_1
    % should be there as well
    break_flag = 0;
    for i = 1:length(multi_instance)
        n = next_present_nodes(multi_instance(i));
        nodelabel = mapping_nodes_names{all_vars(n)};
        nodelabel_split = strsplit(nodelabel, '_');
        obj_cat_str = nodelabel_split{1};
        no_instance = str2double(nodelabel_split{2});
        parent_str = [obj_cat_str '_' num2str(no_instance-1)];
        parent_ind = find(strcmp(mapping_nodes_names, parent_str));
        if isempty(find(all_vars(next_present_nodes) == parent_ind, 1))
            break_flag = 1;
            break;
        end
    end
    
    if break_flag
%         iter = iter - 1;
        continue
    end
    
    % check that the support for all the objects are present
%     break_flag = 1;
%     for nid = 1:length(next_present_nodes)
%         n = all_vars(next_present_nodes(nid));
%         if n == 55 || n == 56 
%             continue
%         end
%         valid_node = 0;
%         for rid = 1:length(supp_rows)
%             vars = factors(supp_rows(rid)).var;
%             if vars(2) == n && ismember(vars(1), all_vars(next_present_nodes))
%                 valid_node = 1;
%                 break
%             end
%         end
%         if ~valid_node
%             break_flag = 1;
%             break
%         end
%     end
%     if break_flag
%         continue
%     end
    
    inter_config(iter,:) = next_config; 
    
    %mcmc sampling, independent metropolis-hastings sampling
    curr_config_score = compute_config_score(factors, all_vars(curr_present_nodes));
    next_config_score = compute_config_score(factors, all_vars(next_present_nodes));
    alpha = min(1, next_config_score / curr_config_score);
    u = rand;
    if alpha > u
        curr_config = next_config;
        all_config(iter, :) = next_config;
        all_score(iter) = next_config_score;
        active_factors = next_active_factors;
        inactive_factors = next_inactive_factors;
    else
        all_config(iter, :) = curr_config;
        all_score(iter) = curr_config_score;
    end
    
    %check for convergence
    if iter > num_prev_iter
%         stable = true;
        sum_change = 0;
        count = 0;
        for piter = iter - num_prev_iter+1:iter-1
            if all_score(piter) == 0
                continue
            end
            sum_change = sum_change + abs(all_score(piter+1) - all_score(piter));
            count = count + 1;
        end
        avg = sum_change / count;
        
        if avg < epsilon %it converged
            break
        end
    end
    
    iter = iter + 1;
end

nodes_sets = repmat(struct('nodes',[]), iter, 1);
inter_nodes_sets = repmat(struct('nodes',[]), iter, 1);
for i = 1:iter
    nodes = find(all_config(i,:));
    nodes_sets(i).nodes = nodes;
    nodes = find(inter_config(i,:));
    inter_nodes_sets(i).nodes = all_vars(nodes);
end

figure
plot(10:iter, all_score(10:iter));

final_config = curr_config;
all_nodes = find(final_config);
final_score = compute_config_score(global_scene_graph, all_nodes);
nodes = setdiff(all_nodes, constraint_nodes_ind);
objects_with_support = assign_support_surfaces(nodes, all_nodes, input_scene, factors, mapping_nodes_names);
objects_with_symmetry = assign_symmetry_groups(objects_with_support, factors);
objects_with_orientation = assign_special_orientation(objects_with_symmetry, factors);

final_scene = objects_with_orientation;

end

function [next_config, active_factors, inactive_factors] = possible_move(...
    prob_add, prob_del, prob_swap, active_factors, inactive_factors, ...
    factors, constraint_nodes, all_vars)

r = rand;
prob = [prob_add, prob_del, prob_swap];
x = sum(r >= cumsum([0, prob]));

if length(active_factors) == 1
    x = 1;
end

switch x
    case 1 %turn on a factor
        fid = randi(length(inactive_factors));
        active_factors = [active_factors, inactive_factors(fid)];
        inactive_factors = [inactive_factors(1:fid-1), inactive_factors(fid+1:end)];
        
    case 2 %turn off a factor
        fid = randi(length(active_factors));
        inactive_factors = [inactive_factors, active_factors(fid)];
        active_factors = [active_factors(1:fid-1), active_factors(fid+1:end)];
        
    case 3 %swap two factors
        fid_add = randi(length(inactive_factors));
        fid_del = randi(length(active_factors));
%         active_copy = active_factors;
        
        inactive_factors = [inactive_factors, active_factors(fid_del)];
        active_factors = [active_factors(1:fid_del-1), active_factors(fid_del+1:end)];
        
        active_factors = [active_factors, inactive_factors(fid_add)];
        inactive_factors = [inactive_factors(1:fid_add-1), inactive_factors(fid_add+1:end)];
end

next_config = constraint_nodes;
for fid = 1:length(active_factors)
    factor = factors(active_factors(fid));
    for vid = 1:length(factor.var)
        ind = find(all_vars == factor.var(vid));
        next_config(ind) = 1;
    end
%     next_config(factor.var) = 1;
end

end
