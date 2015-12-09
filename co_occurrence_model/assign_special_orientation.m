function [ objects_with_orientation ] = assign_special_orientation( objects_with_symmetry, factors )
%ASSIGN_SPECIAL_ORIENTATION Summary of this function goes here
%   Detailed explanation goes here

Consts;
scene = objects_with_symmetry;
scene(1).orientation_rels = [];

%factors symmetry groups
orient_rows = [structfind(factors, 'factor_type', perpendicular), ...
    structfind(factors, 'factor_type', facing)];

for oid = 1:length(scene)
    
%     if ~isempty(scene(oid).symm_group_id)
%         continue
%     end
    obj_type = scene(oid).obj_type;
    orient_rels = [];
    
    for pid = 1:length(scene)
        if oid == pid
            continue
        end
        
        vars = [min(obj_type, scene(pid).obj_type), max(obj_type, scene(pid).obj_type)];
        pair_factor_row = structfind(factors, 'var', vars);
        pair_orient_factor_row = intersect(pair_factor_row, orient_rows);
        if isempty(pair_orient_factor_row)
            continue
        end
        
        %check if two types of special orientations are existing between
        %two objects, if yes select the max one
        max_prob = 0;
        max_factor_row = 0;
        for rid = 1:length(pair_orient_factor_row)
            factor = factors(pair_orient_factor_row(rid));
            v = GetValueOfAssignment(factor, factor.card);
%             pf = factors(pair_orient_factor_row(rid)).potential_func.PF;
            if v > max_prob
                max_prob = v;
                max_factor_row = pair_orient_factor_row(rid);
            end
        end
        
        orient_type = factors(max_factor_row).factor_type;
        orient_ins = struct('pair_obj_id', scene(pid).identifier, 'orient_type', orient_type);
        orient_rels = [orient_rels; orient_ins];
    end
    
    scene(oid).orientation_rels = orient_rels;
end

objects_with_orientation = scene;
end

