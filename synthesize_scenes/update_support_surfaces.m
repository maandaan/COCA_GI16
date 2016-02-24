function scene = update_support_surfaces( scene )
%UPDATE_SUPPORT_SURFACES updates the supporting surface of objects in the
%case of removing their parents; consequently, updates their z coordinates

Consts;
load(mapping_nodes_names_file, 'mapping_nodes_names');
load(global_factor_graph_file, 'factors', 'all_vars');

for oid = 1:length(scene)
    if ~isempty(scene(oid).supporter)
        continue
    end
    
    max_prob = 0;
    support_type = 0;
    obj = scene(oid);
            
    for sid = 1:length(scene)
        if sid == oid
            continue
        end
        
        %rows containing this pair in factors
        if strcmp(scene(sid).obj_category, 'room')
            vars_1 = [55, obj.obj_type];
            vars_2 = [56, obj.obj_type];
            row = [structfind(factors, 'var', vars_1), structfind(factors, 'var', vars_2)];
        else
            vars = [scene(sid).obj_type, obj.obj_type];
            row = structfind(factors, 'var', vars);
        end
        
        supp_row = [structfind(factors, 'factor_type', suppedge_below), structfind(factors, 'factor_type', suppedge_behind)];
        row = intersect(row, supp_row); %check whether this pair can be a support pair or not
        if isempty(row)
            continue
        end
        prob = GetValueOfAssignment(factors(row), [2 2]);
        if prob > max_prob
            max_prob = prob;
            supporter_id = scene(sid).identifier;
            support_type = factors(row).factor_type;
        end
    end
    
    % no support found, remove this object too
    if max_prob == 0
%         supporter_id = scene(1).identifier;
%         support_type = suppedge_below;
        continue
    end
    
    scene(oid).supporter_id = supporter_id;
    parent_row = structfind(scene, 'identifier', supporter_id);
    if parent_row == 1 %room is the support
        if support_type == suppedge_below
            scene(oid).supporter = 55;
            scene(oid).supporter_category = 'floor';
        else
            scene(oid).supporter = 56;
            scene(oid).supporter_category = 'wall';
        end
    else
        scene(oid).supporter = scene(parent_row).obj_type;
        scene(oid).supporter_category = scene(parent_row).obj_category;
    end
    
    scene(oid).support_type = support_type;
    
    %update height
    orig_height = max(scene(oid).corners(:,3)) - min(scene(oid).corners(:,3));
    if parent_row == 1
        scene(oid).corners(1:4,3) = min(scene(parent_row).corners(:,3));
        scene(oid).corners(5:8,3) = min(scene(parent_row).corners(:,3)) + orig_height;
    else
        scene(oid).corners(1:4,3) = max(scene(parent_row).corners(:,3));
        scene(oid).corners(5:8,3) = max(scene(parent_row).corners(:,3)) + orig_height;
    end
end


end

