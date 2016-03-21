function [ final_scene, missed_obj, temp_scenes, temp_scenes_2 ] ...
    = place_objects( scene, max_arrangement_opt_iter )
%PLACE_OBJECTS tries to produce a plausible arrangement of objects and
%repeats the process if the sampling fails, with different initialization
%for new objects or all the objects in the scene

iter = 1;
[ final_scene, missed_obj, temp_scenes ] = optimize_arrangement_scene( scene, '' );

while isempty(final_scene) && iter <= max_arrangement_opt_iter
    %the arrangement failed, should be restarted
    fprintf('Optimization Failed! Restarting...\n');
    [final_scene, missed_obj, temp_scenes] = optimize_arrangement_scene( scene, '' );
    iter = iter + 1;
end

%% comparing mcmc sampling with hill climbing in fisher's paper
%     for tsid = 1:length(temp_scenes)
%         temp_scene = fix_3D_models(temp_scenes(tsid).scene);
%         temp_scene = compute_transform(temp_scene);
%         scene3d_objects = prepare_data_to_write_file(temp_scene);
%         modelcount = length(scene3d_objects);
%         scene3d = struct('modelcount', modelcount, 'objects', scene3d_objects);
%         % scene3d.objects = scene3d_objects;
%         out_file = [scenes_dir, results_filename, '_', num2str(sample_id), '_mcmceval_first_', num2str(tsid) '.txt'];
%         write_scene_to_file( scene3d, out_file );
%     end

%%
%in the case of previously populted scenes, we might need to repeat the
%optimization for present objects as well (total restart)
% iter = 1;
temp_scenes_2 = [];
% while isempty(final_scene) && iter <= max_arrangement_opt_iter
%     fprintf('Optimization Failed! Restarting...\n');
%     for object_id = 2:length(scene)
%         scene(object_id).optimized_location = 0;
%     end
%     [final_scene, ~, temp_scenes_2] = optimize_arrangement_scene( scene, '' );
%     iter = iter + 1;
% end

%% comparing mcmc sampling with hill climbing in fisher's paper
%     for tsid = 1:length(temp_scenes_2)
%         temp_scene = fix_3D_models(temp_scenes_2(tsid).scene);
%         temp_scene = compute_transform(temp_scene);
%         scene3d_objects = prepare_data_to_write_file(temp_scene);
%         modelcount = length(scene3d_objects);
%         scene3d = struct('modelcount', modelcount, 'objects', scene3d_objects);
%         % scene3d.objects = scene3d_objects;
%         out_file = [scenes_dir, results_filename, '_', num2str(sample_id), '_mcmceval_second_', num2str(tsid) '.txt'];
%         write_scene_to_file( scene3d, out_file );
%     end

%%

end

