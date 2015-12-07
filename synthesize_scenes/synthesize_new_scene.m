% This script starts synthesizing a new scene from scratch to the point of
% viewing it with fisher scene_viewer.

Consts;
% load(global_scene_graph_file, 'global_scene_graph');
% load(size_data_file, 'all_valid_sizes');
% 
% % empty_scene = {'floor', 'wall'};
% identifier = ['room_' num2str(randi(1000))];
% empty_scene = struct('identifier', identifier, 'obj_type', 29, 'obj_category', 'room', ...
%     'supporter_id', -1, 'supporter', -1, 'supporter_category', [], 'support_type', -1);
% [ final_config, final_score, scene ] = mcmc_optimize_scene_config(empty_scene, 5000, 0.01, 100);
% 
% % room = select_room(models_dir); %randomly select a layout
% scene = select_models(modelnames_file, scene, global_scene_graph);
% scene = prune_models(scene);
% %remember to manually check the models
% 
% scene = compute_model_BB(scene, models_dir);
% scene = scale_models(scene, all_valid_sizes);
% 
% scene = init_models_to_insert(scene);
% 
% %optimize the placement
% [ final_scene ] = optimize_arrangement_scene( scene );

final_scene = compute_transform(final_scene);
% 
scene3d_objects = prepare_data_to_write_file(final_scene);
modelcount = length(scene3d_objects);
scene3d = struct('modelcount', modelcount, 'objects', scene3d_objects);
% scene3d.objects = scene3d_objects;

out_file = [scenes_dir 'synth_scene_20_relative_location.txt'];
write_scene_to_file( scene3d, out_file )

