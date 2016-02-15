function synthesize_new_scene_fisher( input_scene, scene_file, scene_dir, out_dir )
%SYNTHESIZE_NEW_SCENE_FISHER Summary of this function goes here
%   Detailed explanation goes here

out_file = [out_dir, scene_file];

arranged_scene = arrange_objects( input_scene );
save([out_file '.mat'], 'arranged_scene');

arranged_scene = fix_3D_models(arranged_scene);
arranged_scene = compute_transform(arranged_scene);
scene3d_objects = prepare_data_to_write_file(arranged_scene);
modelcount = length(scene3d_objects);
scene3d = struct('modelcount', modelcount, 'objects', scene3d_objects);

write_scene_to_file( scene3d, [out_file '.txt'] );

run_scene_viewer( scene_file, scene_dir )

end

