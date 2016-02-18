function synthesize_new_scene_fisher( input_scene, scene_file, scene_dir, out_dir )
%SYNTHESIZE_NEW_SCENE_FISHER Summary of this function goes here
%   Detailed explanation goes here

out_file = [out_dir, scene_file];

[arranged_scenes, scores] = arrange_objects( input_scene, [30,55,75,90,100] );
save([out_file '.mat'], 'arranged_scenes', 'scores');

for i = 1:length(arranged_scenes)
    arranged_scene = arranged_scenes(i).scene;
    arranged_scene = fix_3D_models(arranged_scene);
    arranged_scene = compute_transform(arranged_scene);
    scene3d_objects = prepare_data_to_write_file(arranged_scene);
    modelcount = length(scene3d_objects);
    scene3d = struct('modelcount', modelcount, 'objects', scene3d_objects);
    
    write_scene_to_file( scene3d, [out_file '_iter' num2str(i) '_score_' num2str(scores(i)) '.txt'] );
    
    run_scene_viewer( [scene_file '_iter' num2str(i) '_score_' num2str(scores(i))], scene_dir )
end

end

