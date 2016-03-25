%This script is to run fisher's method on multiple scenes at once...
out_dir = 'data/Synthesized Scenes/scenes/';
scene_dir = '';

input_filenames = {'bedroom01311_final_2', 'bedroom0013411_final_8', ...
    'bedroom0013411_final_10', 'bedroom000134_final_11'};

scene_files = {'bedroom01311_2_fisher', 'bedroom0013411_8_fisher', ...
    'bedroom0013411_10_fisher', 'bedroom000134_11_fisher'};

for i = 1:length(input_filenames)
    load(input_filenames{i});
    input_scene = final_scene;
    try
        synthesize_new_scene_fisher( input_scene, scene_files{i}, scene_dir, out_dir );
    catch me
        fprintf('Failed for scene %s! :( \n', input_filenames{i})
        fprintf(me.message);
        fprintf('\n');
        continue
    end
end