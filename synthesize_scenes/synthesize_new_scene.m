% This script starts synthesizing a new scene from scratch or from a
% populated scene loaded from a file, to the point of viewing it with 
% fisher scene_viewer.

Consts;
% load(global_scene_graph_file, 'global_scene_graph');
% load(size_data_file, 'all_valid_sizes');

load(global_factor_graph_file, 'factors', 'all_vars');
load(sample_size_fisher_file, 'sample_sizes');

% new_obj_count = 5;
% empty_scene = true;
% if empty_scene
%     identifier = ['room_' num2str(randi(1000))];
%     input_scene = struct('identifier', identifier, 'obj_type', 29, 'obj_category', 'room', ...
%         'supporter_id', -1, 'supporter', -1, 'supporter_category', [], 'support_type', -1, ...
%         'symm_group_id', [], 'symm_ref_id', [], 'orientation_rels', [], 'modelname', [], ...
%         'BB', [], 'dims', [], 'scale', [], 'children', [], 'corners', [], ...
%         'orientation', [], 'transform',[], 'optimized_location', 1);
%     pres_obj_count = 2;
% else
%     load('data/Synthesized Scenes/scene_zeinab_009.mat', 'final_scene');
%     input_scene = final_scene;
%     pres_obj_count = length(final_scene) + 1;
% end
% 
% 
% [ all_config, all_score, nodes_sets ] = mcmc_optimize_scene_config(...
%     input_scene, 1000, new_obj_count, new_obj_count, 1);
% [ sample_score, sample_objects ] = choose_mcmc_samples( ...
%     all_score, nodes_sets, new_obj_count + pres_obj_count, 50, 1 );
% sampled_scenes = complete_mcmc_samples_to_scenes( input_scene, sample_objects );
% save('data/test_cases/bedroom_sampled_scenes_005.mat', 'sampled_scenes');
 
% % room = select_room(models_dir); %randomly select a layout
% load('data/test_cases/bedroom_sampled_scenes_005.mat');
% scene = sampled_scenes(3).scene;
% scene = select_models(modelnames_file, scene);
% scene = prune_models(scene);
% % % remember to manually check the models
%  
scene = compute_model_BB(scene, models_dir);
scene = scale_models(scene, sample_sizes);
 
scene = init_models_to_insert(scene);
save('data/test_cases/bedroom_sample_scene_007.mat', 'scene');
 
load('data/test_cases/bedroom_sample_scene_007.mat', 'scene');
%optimize the placement
[ final_scene ] = optimize_arrangement_scene( scene );
save('data/Synthesized Scenes/scene_zeinab_011.mat', 'final_scene');

final_scene = compute_transform(final_scene);
 
scene3d_objects = prepare_data_to_write_file(final_scene);
modelcount = length(scene3d_objects);
scene3d = struct('modelcount', modelcount, 'objects', scene3d_objects);
% scene3d.objects = scene3d_objects;

out_file = [scenes_dir 'synth_scene_39_progressive_synthesis.txt'];
write_scene_to_file( scene3d, out_file )

