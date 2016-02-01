function write_mcmc_evaluation_results_txt( out_filename, ...
    orig_sampled_scenes_file, new_sampled_scenes_file)
%WRITE_MCMC_EVALUATION_RESULTS_TXT saves the comparison between mcmc
%results for the default case vs. turning some factors off.

load(orig_sampled_scenes_file, 'sampled_scenes');
orig_sampled_scenes = sampled_scenes;
load(new_sampled_scenes_file, 'sampled_scenes');

min_len = min(length(orig_sampled_scenes), length(sampled_scenes));

fid = fopen(out_filename, 'w');

for i = 1:min_len
    sample = orig_sampled_scenes(i).scene;
    fprintf(fid, 'original sample %d:', i);
    for j = 1:length(sample)
        fprintf(fid, ' %s,' ,sample(j).obj_category);
    end
    fprintf(fid, '\n');
    fprintf(fid, 'new sample %d:', i);
    sample = sampled_scenes(i).scene;
    for j = 1:length(sample)
        fprintf(fid, ' %s,' ,sample(j).obj_category);
    end
    fprintf(fid, '\n');
end
fclose(fid);

end

