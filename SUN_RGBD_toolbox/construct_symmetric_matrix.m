function [ symmetry_relations ] = construct_symmetric_matrix
%CONSTRUCT_SYMMETRIC_MATRIX constructs a struct array of symmetric
%relations. (by Zeinab Sadeghipour)

% scene_type = 'bedroom';
% mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';

Consts;
sunrgbdmeta_file = 'SUNRGBDMeta.mat';
load(sunrgbdmeta_file, 'SUNRGBDMeta');

symmetry_groups = gather_symmetric_relations( scene_type, mapping_file );
save('data/training/SUNRGBD/bedroom_symmetry_groups.mat', 'symmetry_groups');

symmetry_relations = struct('obj_cat', [], 'obj_cat_str', [], 'instance_count', [], ...
    'outside_obj_cat', [], 'outside_obj_str', [], 'outside_obj_freq', []);

for sgid = 1:length(symmetry_groups)
    sindex = symmetry_groups(sgid).scene_index;
    sg_ind = symmetry_groups(sgid).symm_group_ind;
    outside_obj_ind = symmetry_groups(sgid).symm_group_outside_obj_ind;
    
    gt3D = SUNRGBDMeta(:,sindex).groundtruth3DBB;
    obj_cat = get_object_type_bedroom({gt3D(sg_ind(1)).classname});
    obj_cat_str = get_object_type_bedroom(obj_cat);
    obj_cat_str = obj_cat_str{1};
    instance_count = length(sg_ind);
    if outside_obj_ind == 0
        outside_obj_cat = 0;
        outside_obj_str = '';
    else
        outside_obj_cat = get_object_type_bedroom({gt3D(outside_obj_ind).classname});
        outside_obj_str = get_object_type_bedroom(outside_obj_cat);
        outside_obj_str = outside_obj_str{1};
    end
    
    %search whether this category and number of instances was added or not
    cat_rows = structfind(symmetry_relations, 'obj_cat', obj_cat);
    instance_rows = structfind(symmetry_relations, 'instance_count', instance_count);
    outobj_rows = structfind(symmetry_relations, 'outside_obj_cat', outside_obj_cat);
    final_row = intersect( intersect(cat_rows, instance_rows), outobj_rows );
    
    if ~isempty(final_row)
        freq = symmetry_relations(final_row).outside_obj_freq;
        freq = freq + 1;
        symmetry_relations(final_row).outside_obj_freq = freq;
    else
        new_row = struct('obj_cat', obj_cat, 'obj_cat_str', obj_cat_str, 'instance_count', instance_count, ...
            'outside_obj_cat', outside_obj_cat, 'outside_obj_str', outside_obj_str, 'outside_obj_freq', 1);
        symmetry_relations = [symmetry_relations; new_row];
    end
end

symmetry_relations = symmetry_relations(2:end);
save('data/training/SUNRGBD/bedroom_symmetry_relations.mat', 'symmetry_relations');

end

