function sampled_scenes = generate_scenes_MCMC_sampling( ...
    input_scene, obj_count, num_samples, out_file)
%GENERATE_SCENES_MCMC_SAMPLING runs MCMC sampling to generate a set of new
%objects to be inserted in the scene and choose the top $num_samples$ ones
%to include in sampled_scenes and save in the file indicated as out_file.

% out_file = 'data/Sampled Scenes/bedroom_sampled_scenes_5objs_001.mat';

num_iter = 1000;
use_log = 1;
numobj_lb = obj_count;
numobj_ub = obj_count;

%generate samples
[ all_config, all_score, nodes_sets ] = mcmc_optimize_scene_config( ...
    input_scene, num_iter, numobj_lb, numobj_ub, use_log );

%pick top samples
[ sample_score, sample_objects ] = choose_mcmc_samples( ...
    all_score, nodes_sets, obj_count, num_samples );

% add support, symmetry and orientation relations to sampled objects
sampled_scenes = complete_mcmc_samples_to_scenes( input_scene, sample_objects );

save(out_file, 'sampled_scenes');


end

