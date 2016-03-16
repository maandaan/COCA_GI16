function sample_sizes = collect_sample_sizes
%The size information is collected from SUNRGBD dataset (the fisherDB_dims
%is just for being consistent with previous versions)
Consts;
load(sunrgbdmeta_file);
load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);

cat_count = get_object_type_bedroom({'other'}) - 1;
sample_sizes = repmat(struct('objtype',[], 'objtype_str',[], 'fisherDB_dims',[]), cat_count, 1);

for i = 1:cat_count
    sample_sizes(i).objtype = i;
    sample_sizes(i).objtype_str = get_object_type_bedroom(i);
end

room_ind = get_object_type_bedroom({'room'});
% sample_sizes(room_ind).fisherDB_dims = [300, 300, 135];

mid = 0;
while mid < total_size && ~check_all_sizes(sample_sizes)
   
    mid = mid + 1;
    % check for the scene type
    if ~strcmp(map_scene_name_type(mid).sceneType, scene_type)
        continue
    end
    
    if isempty(sample_sizes(room_ind).fisherDB_dims)
        room_corners = SUNRGBDMeta(:,mid).gtCorner3D;
        if ~isempty(room_corners)
            room_dims = [norm(room_corners(:,1) - room_corners(:,2)), ...
                norm(room_corners(:,2) - room_corners(:,3)), ...
                abs(room_corners(3,1) - room_corners(3,5))] * 100;
            sample_sizes(room_ind).fisherDB_dims = room_dims;
        end
    end
        
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D)
        continue;
    end
    
    no_objects = size(gt3D,2);
    for oid = 1:no_objects
        objtype = get_object_type_bedroom({gt3D(oid).classname});
        if objtype > cat_count || ~isempty(sample_sizes(objtype).fisherDB_dims)
            continue
        end
        
        corners = get_corners_of_bb3d(gt3D(oid));
        dims = [norm(corners(1,:) - corners(2,:)), ...
            norm(corners(2,:) - corners(3,:)), ...
            abs(corners(1,3) - corners(5,3))] * 100;
        sample_sizes(objtype).fisherDB_dims = dims;
    end
    
end

save(sample_size_fisher_file_v2, 'sample_sizes')
end

function undefined_sizes = check_all_sizes(sample_sizes)
undefined_sizes = true;
for i = 1:length(sample_sizes)
    undefined_sizes = undefined_sizes && ~isempty(sample_sizes(i).fisherDB_dims);
    if ~undefined_sizes
        break
    end
end
end
