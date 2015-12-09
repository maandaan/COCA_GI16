function [ objects_with_symmetry ] = assign_symmetry_groups( objects_with_support, factors )
%ASSIGN_SYMMETRY_GROUPS Summary of this function goes here
%   Detailed explanation goes here

Consts;
scene = objects_with_support;
scene(1).symm_group_id = {};
scene(1).symm_ref_id = [];

%factors symmetry groups
symm_rows = [structfind(factors, 'factor_type', symm_g), ...
    structfind(factors, 'factor_type', symm_resp)];

for oid = 1:length(scene)
    
    if ~isempty(scene(oid).symm_group_id)
        continue
    end
    obj_type = scene(oid).obj_type;
    
    type_rows = structfind(scene, 'obj_type', obj_type);
    if length(type_rows) == 1 %there's only one instance of the category -> no symmetry
        continue
    end
    
    %check if there's a symmetry factor for this category
    symm_factor_rows = [];
    for rid = 1:length(symm_rows)
        vars = factors(symm_rows(rid)).var;
        if vars(1) == obj_type
            symm_factor_rows = [symm_factor_rows; symm_rows(rid)];
        end
    end
    
    %construct symmetry group
    if isempty(symm_factor_rows)
        continue
    end
    for rid = 1:length(type_rows)
        temp = {scene(type_rows).identifier};
        scene(type_rows(rid)).symm_group_id = temp;
    end
    
    %check whether the group can be symmetric with reference to another
    %object
    max_prob = 0;
    max_factor_row = 0;
    for rid = 1:length(symm_factor_rows)
        factor = factors(symm_factor_rows(rid));
        v = GetValueOfAssignment(factor, factor.card);
%         pf = factors(symm_factor_rows(rid)).potential_func.PF;
        if v > max_prob
            max_prob = v;
            max_factor_row = symm_factor_rows(rid);
        end
    end
    vars = factors(max_factor_row).var;
    if vars(end) > 56
        continue
    end
    ref_row = structfind(scene, 'obj_type', vars(end));
    if isempty(ref_row)
        continue
    end
    rand_ref_row = randi(length(ref_row));
    for rid = 1:length(type_rows)
        scene(type_rows(rid)).symm_ref_id = scene(ref_row(rand_ref_row)).identifier;
    end
    
end

objects_with_symmetry = scene;
end

