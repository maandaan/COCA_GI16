function sampled_scenes = complete_mcmc_samples_to_scenes( input_scene, sample_objects )
%COMPLETE_MCMC_SAMPLES_TO_SCENES assigns support, symmetry and orientation
%relations to sampled objects

Consts;
load(global_factor_graph_file, 'factors', 'all_vars');
load(mapping_nodes_names_file, 'mapping_nodes_names');

constraint_nodes = find_constrained_nodes( input_scene, all_vars, mapping_nodes_names );
constraint_nodes_ind = find(constraint_nodes);
input_nodes = all_vars(constraint_nodes_ind);

sampled_scenes = [];

for i = 1:length(sample_objects)
    all_nodes = sample_objects(i).nodes;
    nodes = setdiff(all_nodes, input_nodes);
    
    objects_with_support = assign_support_surfaces(nodes, all_nodes, input_scene, factors, mapping_nodes_names);
    objects_with_symmetry = assign_symmetry_groups(objects_with_support, factors);
    objects_with_orientation = assign_special_orientation(objects_with_symmetry, factors);
    
    sampled_scenes = [sampled_scenes; objects_with_orientation];
end

end

