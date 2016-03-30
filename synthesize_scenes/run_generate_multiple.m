%This script is to run synthesize on multiple scenes at once...
max_arrangement_opt_iter = 2;
objects_num = 0;
input_scene_filename = '';

input_filenames = {'bedroom_small_00001', 'bedroom_small_000133'};

sample_ids = [33, 46];

for i = 1:length(input_filenames)
    results_filename = input_filenames{i};
    sid = sample_ids(i);
    try
        generate_scenes( objects_num, input_scene_filename, results_filename, max_arrangement_opt_iter, sid);
    catch
        fprintf('Failed for scene %s! :( \n', input_filenames{i})
        continue
    end
end