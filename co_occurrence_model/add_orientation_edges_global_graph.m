function [ edges, factors, orient_prob_avg, orient_count ] = add_orientation_edges_global_graph( scene_count, orientation_relations )
%ADD_ORIENTATION_EDGES_GLOBAL_GRAPH adds edges related to special
%orientations between objects to the global graph.

Consts;

edges = [];
factors = struct('variables', [], 'factor_type', [], 'potential_func', []);
orientation_thresh = floor(0.03 * scene_count);
orient_count = 0;
orient_prob = 0;

for oid = 1:length(orientation_relations)
    frequency = orientation_relations(oid).orient_freq;
    orient_type = orientation_relations(oid).orient_type;
    obj1 = orientation_relations(oid).first_obj_cat;
    obj2 = orientation_relations(oid).second_obj_cat;
    
    % discard the non-frequent ones or the same direction or if one object
    % is from category 'other'
    if frequency < orientation_thresh || orient_type == 3 || ...
            obj1 == 28 || obj2 == 28
        continue
    end
    
    if orient_type == 1
        edges = [edges; obj1 obj2 perpendicular];
        factor_type = perpendicular;
    else
        edges = [edges; obj1 obj2 facing];
        factor_type = facing;
    end
    
    orient_count = orient_count + 1;
    orient_prob = orient_prob + frequency / scene_count;

    variables = [obj1, obj2];

    %computing other cases of CPT, either obj1 or obj2 not present
%     obj1_rows = [structfind(orientation_relations, 'first_obj_cat', obj1); ...
%         structfind(orientation_relations, 'second_obj_cat', obj1)];
%     obj2_rows = [structfind(orientation_relations, 'first_obj_cat', obj2); ...
%         structfind(orientation_relations, 'second_obj_cat', obj2)];
%     other_rows = [structfind(orientation_relations, 'first_obj_cat', 28); ...
%         structfind(orientation_relations, 'second_obj_cat', 28)];
%     samedir_rows = structfind(orientation_relations, 'orient_type', 3);
%     obj1_rows = setdiff( setdiff(obj1_rows, other_rows), samedir_rows);
%     obj2_rows = setdiff( setdiff(obj2_rows, other_rows), samedir_rows);
%     
%     sum_obj1 = 0;
%     for rid = 1:length(obj1_rows)
%         row = obj1_rows(rid);
%         if row == oid || orientation_relations(row).orient_freq < orientation_thresh
%             continue
%         end
%         sum_obj1 = sum_obj1 + orientation_relations(row).orient_freq;
%     end
%     sum_obj2 = 0;
%     for rid = 1:length(obj2_rows)
%         row = obj2_rows(rid);
%         if row == oid || orientation_relations(row).orient_freq < orientation_thresh
%             continue
%         end
%         sum_obj2 = sum_obj2 + orientation_relations(row).orient_freq;
%     end

    pf = ones(2,2);
%     CPT(1,1) = 0;
    energy = -frequency / scene_count;
    pf(2,2) = exp(-energy);
%     CPT(2,1) = sum_obj1 / scene_count;
%     CPT(1,2) = sum_obj2 / scene_count;
    potential_func = struct('PF', pf);

    factors = [factors; struct('variables', variables, 'factor_type', factor_type, 'potential_func', potential_func)];
end

factors = factors(2:end);
orient_prob_avg = orient_prob / orient_count;

end

