function print_scene_models_info(scene_filename)
%PRINT_SCENE_MODELS_INFO prints the information for the 3D models in each
%scene.

close all

scenes_dir = 'data\Synthesized Scenes\scenes\';
filename = [scenes_dir, scene_filename];
load(filename, 'final_scene');

for i = 1:length(final_scene)
    fprintf('%s: ', final_scene(i).obj_category);
    fprintf('%s, ', final_scene(i).modelname);
    fprintf('%f, %f, %f \n', final_scene(i).scale(1), final_scene(i).scale(3), final_scene(i).scale(2));
    
    %sanity check
    plot(final_scene(i).corners(1:5,1), final_scene(i).corners(1:5,2));
    hold on
end

end

