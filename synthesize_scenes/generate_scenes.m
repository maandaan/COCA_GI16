function generate_scenes( objects_num, input_scene_filename, ...
    results_filename, max_arrangement_opt_iter)
%GENERATE_SCENES starts the synthesize from the beginning and invokes the
%necessary functions and saves the results in each step.

Consts;
load(global_factor_graph_file, 'factors', 'all_vars');
load(sample_size_fisher_file, 'sample_sizes');

objectsets_filename = [scenes_dir, results_filename, '_objectsets.mat'];

if isempty(input_scene_filename) %start from an empty room
    identifier = ['room_' num2str(randi(1000))];
    input_scene = struct('identifier', identifier, 'obj_type', 29, 'obj_category', 'room', ...
        'supporter_id', -1, 'supporter', -1, 'supporter_category', [], 'support_type', -1, ...
        'symm_group_id', [], 'symm_ref_id', [], 'orientation_rels', [], 'modelname', [], ...
        'BB', [], 'dims', [], 'scale', [], 'children', [], 'corners', [], ...
        'orientation', [], 'transform',[], 'optimized_location', 1);
    pres_obj_count = 2;
else %continue a previously populated scene
    load(input_scene_filename, 'final_scene');
    input_scene = final_scene;
    pres_obj_count = length(final_scene) + 1;
end

[ all_config, all_score, nodes_sets ] = mcmc_optimize_scene_config(...
    input_scene, 1000, objects_num, objects_num, 1);
[ sample_score, sample_objects ] = choose_mcmc_samples( ...
    all_score, nodes_sets, objects_num + pres_obj_count, 15, 1 );
sampled_scenes = complete_mcmc_samples_to_scenes( input_scene, sample_objects );
save(objectsets_filename, 'sampled_scenes');
fprintf('Finished MCMC sampling from the factor graph!\n');

load(objectsets_filename, 'sampled_scenes');

for sample_id = 1:length(sampled_scenes)
    scene = sampled_scenes(sample_id).scene;
    scene = select_models(modelnames_file, scene);
    scene = prune_models(scene);
    fprintf('Finished selecting models for the sample %d!\n', sample_id);
    
    scene = compute_model_BB(scene, models_dir);
    scene = scale_models(scene, sample_sizes);
    scene = init_models_to_insert(scene);
    save([scenes_dir, results_filename, '_init_', num2str(sample_id)], 'scene');
    fprintf('Finished initializing the placement and scaling the sizes for sample %d!\n', sample_id);
    
    load([scenes_dir, results_filename, '_init_', num2str(sample_id)], 'scene');
    iter = 1;
    [ final_scene ] = optimize_arrangement_scene( scene );
    while isempty(final_scene) && iter <= max_arrangement_opt_iter 
        %the arrangement failed, should be restarted
        fprintf('Optimization Failed! Restarting...\n');
        final_scene = optimize_arrangement_scene( scene );
        iter = iter + 1;
    end
    
    %in the case of previously populted scenes, we might need to repeat the
    %optimization for present objects as well (total restart)
    iter = 1;
    while isempty(final_scene) && iter <= max_arrangement_opt_iter
        fprintf('Optimization Failed! Restarting...\n');
        for object_id = 2:length(scene)
            scene(object_id).optimized_location = 0;
        end
        final_scene = optimize_arrangement_scene( scene );
        iter = iter + 1;
    end
    
    if isempty(final_scene)
        fprintf('The placement for sample %d could not be optimized! :( \n', sample_id);
        continue
    end
    
    save([scenes_dir, results_filename, '_final_', num2str(sample_id)], 'final_scene');
    fprintf('Finished optimizing the placement for sample %d!\n', sample_id);
    
    %preparing the results for scene_viewer
    final_scene = fix_3D_models(final_scene);
    final_scene = compute_transform(final_scene);
    scene3d_objects = prepare_data_to_write_file(final_scene);
    modelcount = length(scene3d_objects);
    scene3d = struct('modelcount', modelcount, 'objects', scene3d_objects);
    % scene3d.objects = scene3d_objects;
    out_file = [scenes_dir, results_filename, '_', num2str(sample_id), '.txt'];
    write_scene_to_file( scene3d, out_file );
    fprintf('Finished preparing the result for scene viewer for sample %d!\n', sample_id);
end


end
