function f = set_value_proximity_factors( f, fid, updated_focals, ...
    SUNRGBDMeta, valid_scene_type_indices, mapping_nodes_names )
%SET_VALUE_PROXIMITY_FACTORS updated version of compute_pf_focals with
%Factor graph toolbox.

Consts;
f.val = zeros(1,prod(f.card));
focal = updated_focals.subgraphs{fid};
supporters = updated_focals.supporter_set(fid).supporters;
variables = f.var;

node_count = length(f.var); 
scene_count = length(valid_scene_type_indices);

%scenes not supporting this focal
supporter_set_complement_ind = setdiff(1:scene_count, supporters);
supporter_set_complement = valid_scene_type_indices(supporter_set_complement_ind);

for i = 1:length(f.val)-1
    bin = dec2bin(i-1, node_count);
    node_present = fliplr(double(bin == '1'));
    assignment = node_present + 1;
    
    continue_flag = 0;
    for nid = 2:node_count
        var = variables(nid);
        node_name = mapping_nodes_names{var};
        node_split = strsplit(node_name, '_');
        instance_count = str2num(node_split{end});
        if node_present(nid) && instance_count > 1 && ~node_present(nid-1) %multiple instance of one object category
            continue_flag = 1;
            break;
        end
    end
    if continue_flag
        f = SetValueOfAssignment(f, assignment, 0);
        continue;
    end
    
    count = 0;
    for sid = 1:length(supporter_set_complement)
        gt3D = SUNRGBDMeta(:,supporter_set_complement(sid)).groundtruth3DBB;
        obj_labels = {gt3D(:).classname};
        obj_types = get_object_type_bedroom(obj_labels);
        desired_scene = true;
        for nid = 1:node_count
%             if variables(nid) < 57
%                 desired_scene = desired_scene && ~xor( node_present(nid), ~isempty(find(obj_types == variables(nid),1)));
%             else
%                 cat_count = 0;
                node_split = strsplit(mapping_nodes_names{variables(nid)}, '_');
                cat_count = str2num(node_split{end});
                category = get_object_type_bedroom({[node_split{1:end-1}]});
%                 while node_split{2} > 1 && nid > cat_count + 1 %variables(nid - cat_count) > 56
%                     cat_count = cat_count + 1;
%                     node_split = strsplit(mapping_nodes_names{variables(nid-cat_count)}, '_');
%                 end
                try
                    desired_scene = desired_scene && ~xor( node_present(nid), ...
                        length(find(obj_types == category)) >= cat_count); %the exact number of instances of that category
                catch
                    fprintf('Oops!!\n')
                end
%             end
        end
        if desired_scene
            count = count + 1;
        end
    end
    f = SetValueOfAssignment(f, assignment, count / scene_count);
%     CPT(i+1) = count / scene_count;
end

% CPT(end) = updated_focals.prob(fid);
f = SetValueOfAssignment(f, f.card, updated_focals.prob(fid));

end

