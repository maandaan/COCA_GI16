function final_scene = generate_empty_room( room_modelname, results_filename )
%GENERATE_EMPTY_ROOM produces only an empty room

Consts;
load(sample_size_fisher_file_v2, 'sample_sizes');
room_type = get_object_type_bedroom({'room'});

identifier = ['room_' num2str(randi(1000))];
input_scene = struct('identifier', identifier, 'obj_type', room_type, 'obj_category', 'room', ...
    'supporter_id', -1, 'supporter', -1, 'supporter_category', [], 'support_type', -1, ...
    'symm_group_id', [], 'symm_ref_id', [], 'orientation_rels', [], 'modelname', [], ...
    'BB', [], 'dims', [], 'scale', [], 'children', [], 'corners', [], ...
    'orientation', [], 'transform',[], 'optimized_location', 1);

input_scene.modelname = room_modelname;
scene = input_scene;

scene = compute_model_BB(scene, models_dir, modelnames_file);
scene = scale_models(scene, sample_sizes);
scene = init_models_to_insert(scene);
final_scene = scene;

final_scene = compute_transform(final_scene);
scene3d_objects = prepare_data_to_write_file(final_scene);
modelcount = length(scene3d_objects);
scene3d = struct('modelcount', modelcount, 'objects', scene3d_objects);
out_file = [scenes_dir, results_filename, '.txt'];
write_scene_to_file( scene3d, out_file );
save(results_filename, 'final_scene');

end

