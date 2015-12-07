function factors = add_orientation_factors( scene_count, orientation_relations )
%ADD_ORIENTATION_FACTORS updated version of
%add_orientation_edges_global_graph with factor graph toolbox

Consts;
factors = [];
orientation_thresh = floor(0.03 * scene_count);

all_rows = 1:length(orientation_relations);
other_rows = [structfind(orientation_relations, 'first_obj_cat', 28); ...
    structfind(orientation_relations, 'second_obj_cat', 28)];
samedir_rows = structfind(orientation_relations, 'orient_type', 3);
valid_rows = setdiff( setdiff(all_rows, other_rows), samedir_rows);
orient_rels_count = sum([orientation_relations(valid_rows).orient_freq]);

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
        factor_type = perpendicular;
    else
        factor_type = facing;
    end

    f.var = [obj1, obj2];
    f.card = [2,2];
    f.factor_type = factor_type;
    f.val = zeros(1,prod(f.card));

    %computing other cases of CPT, either obj1 or obj2 not present
    obj1_rows = [structfind(orientation_relations, 'first_obj_cat', obj1); ...
        structfind(orientation_relations, 'second_obj_cat', obj1)];
    obj1_rows = setdiff( setdiff(obj1_rows, other_rows), samedir_rows);
    
    obj2_rows = [structfind(orientation_relations, 'first_obj_cat', obj2); ...
        structfind(orientation_relations, 'second_obj_cat', obj2)];
    obj2_rows = setdiff( setdiff(obj2_rows, other_rows), samedir_rows);
    
    neither_rows = setdiff (setdiff(valid_rows, obj1_rows), obj2_rows);
    
    sum_obj1 = 0;
    for rid = 1:length(obj1_rows)
        row = obj1_rows(rid);
        if row == oid || orientation_relations(row).orient_freq < orientation_thresh
            continue
        end
        sum_obj1 = sum_obj1 + orientation_relations(row).orient_freq;
    end
    
    sum_obj2 = 0;
    for rid = 1:length(obj2_rows)
        row = obj2_rows(rid);
        if row == oid || orientation_relations(row).orient_freq < orientation_thresh
            continue
        end
        sum_obj2 = sum_obj2 + orientation_relations(row).orient_freq;
    end
    
    sum_neither = 0;
    for rid = 1:length(neither_rows)
        row = neither_rows(rid);
        if orientation_relations(row).orient_freq < orientation_thresh
            continue
        end
        sum_neither = sum_neither + orientation_relations(row).orient_freq;
    end
    
    f = SetValueOfAssignment(f, [2,2], frequency / orient_rels_count);
    f = SetValueOfAssignment(f, [2,1], sum_obj1 / orient_rels_count);
    f = SetValueOfAssignment(f, [1,2], sum_obj2 / orient_rels_count);
    f = SetValueOfAssignment(f, [1,1], sum_neither / orient_rels_count); %not sure to use sum_neither

%     pf = ones(2,2);
% %     CPT(1,1) = 0;
%     energy = -frequency / scene_count;
%     pf(2,2) = exp(-energy);
% %     CPT(2,1) = sum_obj1 / scene_count;
% %     CPT(1,2) = sum_obj2 / scene_count;
%     potential_func = struct('PF', pf);

    factors = [factors, f];
end

end

