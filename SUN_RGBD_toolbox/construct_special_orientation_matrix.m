function [ orientation_relations ] = construct_special_orientation_matrix( special_orientation_file )
%CONSTRUCT_SPECIAL_ORIENTATION_MATRIX constructs a struct array of special
%orientation relations. (by Zeinab Sadeghipour)

% special_orientation_file = 'data/training/SUNRGBD/bedroom_special_orientations.mat'

% sunrgbdmeta_file = '../SUNRGBD/code/SUNRGBDtoolbox/Metadata/SUNRGBDMeta.mat';
% load(sunrgbdmeta_file, 'SUNRGBDMeta');
load(special_orientation_file, 'special_orientations');

orientation_relations = struct('first_obj_cat', [], 'first_obj_str', [], ...
    'second_obj_cat', [], 'second_obj_str', [], 'orient_type', [], 'orient_freq', []);

for soid = 1:length(special_orientations)
    first_obj_class = special_orientations(soid).first_obj_classname;
    second_obj_class = special_orientations(soid).second_obj_classname;
    orient_type = special_orientations(soid).orient_type;
    
    first_obj_cat = get_object_type_bedroom({first_obj_class});
    second_obj_cat = get_object_type_bedroom({second_obj_class});
    if first_obj_cat > second_obj_cat
        temp = first_obj_cat;
        first_obj_cat = second_obj_cat;
        second_obj_cat = temp;
    end
    
    first_obj_str = get_object_type_bedroom(first_obj_cat);
    first_obj_str = first_obj_str{1};
    second_obj_str = get_object_type_bedroom(second_obj_cat);
    second_obj_str = second_obj_str{1};
    
    first_rows = structfind(orientation_relations, 'first_obj_cat', first_obj_cat);
    second_rows = structfind(orientation_relations, 'second_obj_cat', second_obj_cat);
    type_rows = structfind(orientation_relations, 'orient_type', orient_type);
    final_row = intersect( intersect(first_rows, second_rows), type_rows);
    
    if ~isempty(final_row)
        freq = orientation_relations(final_row).orient_freq;
        freq = freq + 1;
        orientation_relations(final_row).orient_freq = freq;
    else
        new_row = struct('first_obj_cat', first_obj_cat, 'first_obj_str', first_obj_str, ...
            'second_obj_cat', second_obj_cat, 'second_obj_str', second_obj_str, ...
            'orient_type', orient_type, 'orient_freq', 1);
        orientation_relations = [orientation_relations; new_row];
    end
    
    fprintf('terminated row %d\n', soid);
end

orientation_relations = orientation_relations(2:end);
save('data/training/SUNRGBD/bedroom_special_orientation_relations.mat', 'orientation_relations');

end

