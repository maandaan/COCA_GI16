function [ cpt_struct ] = compute_cpt_focals( fid, updated_focals, SUNRGBDMeta, valid_scene_type_indices, variables )
%COMPUTE_CPT_FOCALS computes the CPT for the fid-th focal.

Consts;
focal = updated_focals.subgraphs{fid};
supporters = updated_focals.supporter_set(fid).supporters;
CPT = zeros(2^length(variables), 1 );
dims = repmat(2, 1, length(variables));
CPT = reshape(CPT, dims);
node_count = length(variables); 
scene_count = length(valid_scene_type_indices);

%scenes not supporting this focal
supporter_set_complement_ind = setdiff(1:scene_count, supporters);
supporter_set_complement = valid_scene_type_indices(supporter_set_complement_ind);

for i = 0:2^node_count -2
    bin = dec2bin(i, node_count);
    node_present = fliplr(double(bin == '1'));
    
    continue_flag = 0;
    for nid = 2:node_count
        if node_present(nid) && variables(nid) > 56 && ~node_present(nid-1) %multiple instance of one object category
            continue_flag = 1;
            break;
        end
    end
    if continue_flag
        CPT(i+1) = 0;
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
                cat_count = 0;
                while variables(nid - cat_count) > 56
                    cat_count = cat_count + 1;
                end
                desired_scene = desired_scene && ~xor( node_present(nid), ...
                    length(find(obj_types == variables(nid - cat_count))) > cat_count); %the exact number of instances of that category
%             end
        end
        if desired_scene
            count = count + 1;
        end
    end
    CPT(i+1) = count / scene_count;
end
CPT(end) = updated_focals.prob(fid);

cpt_struct = struct('CPT', CPT);
end

