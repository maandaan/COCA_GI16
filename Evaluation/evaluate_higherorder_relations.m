function evaluate_higherorder_relations( objects_num, input_scene_filename, ...
    results_filename )
%EVALUATE_HIGHERORDER_RELATIONS evaluates how turning off the factors
%affects mcmc sampling from the factor graph

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

end

