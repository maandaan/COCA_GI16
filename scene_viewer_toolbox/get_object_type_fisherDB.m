function fisher_scenes = get_object_type_fisherDB
%GET_OBJECT_TYPE_FISHERDB extracts the object categories for 3D models used
%in Fisher's scenes. 

Consts_fisher;
scenes_list = dir([scenes_dir, '*.txt']);
load(mapping_model_categories_file, 'model_categories');

fisher_scenes = struct('scene',[]);

scene_count = 1;
for lid = 1:length(scenes_list)
    filename = scenes_list(lid).name;
    pattern = 'scene\d{5}\.txt';
    if isempty(regexp(filename, pattern, 'match')) %filter synthesized scenes by myself
        continue
    end
    
    fisher_scenes(scene_count).filename = filename;
    scene3d = read_scene_txt( [scenes_dir, filename] );
    objects = scene3d.objects;
    
%     hold on
    for oid = 1:length(objects)
        modelname = objects(oid).mid;
        row_ind = structfind(model_categories, 'modelname', modelname);
        if isempty(row_ind) %the model is already inserted
            continue
        end
        
        scene3d.objects(oid).obj_type = model_categories(row_ind).obj_category_num;
        scene3d.objects(oid).obj_category = model_categories(row_ind).obj_category_str;
        
        %compute the corners
        filename = objects(oid).mid;
        model = read_wobj([models_dir filename '.obj']);
%         plot3(model.vertices(:,1),model.vertices(:,2),model.vertices(:,3),'o')
        orig_bnd = [min(model.vertices,[],1), max(model.vertices,[],1)];
        align_ind = [1 2 3; 4 2 3; 4 5 3; 1 5 3; 1 2 6; 4 2 6; 4 5 6; 1 5 6];
        orig_corners = orig_bnd(align_ind);
        orig_corners_augmented = [orig_corners'; repmat(1,1,8)];
        corners = objects(oid).transform' * orig_corners_augmented;
        scene3d.objects(oid).corners = corners(1:3,:)';
            
        %debug
%         plot(corners(1,1:5),corners(2,1:5));
    end
    
    fisher_scenes(scene_count).scene = scene3d.objects;
    scene_count = scene_count + 1;
%     hold off
end

save(fisher_scenes_file, 'fisher_scenes')

end

