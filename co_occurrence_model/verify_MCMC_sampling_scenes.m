

Consts;
load(mapping_nodes_names_file, 'mapping_nodes_names');
res_file = 'co_occurrence_model\mcmc_result_10obj.txt';

num_iter = 1000;
use_log = 1;
numobj_lb = 10;
numobj_ub = 10;

identifier = ['room_' num2str(randi(1000))];
input_scene = struct('identifier', identifier, 'obj_type', 29, ...
    'obj_category', 'room', 'supporter_id', -1, 'supporter', -1, ...
    'supporter_category', [], 'support_type', -1);

%generate samples
[ all_config, all_score, nodes_sets ] = mcmc_optimize_scene_config( ...
    input_scene, num_iter, numobj_lb, numobj_ub, use_log );

%lowest scores
[ sample_score, sample_objects ] = choose_mcmc_samples( ...
    all_score, nodes_sets, 10, 5, 0 );

fid = fopen(res_file, 'w');
fprintf(fid, 'MCMC sampling for 10 objects\n');
fprintf(fid, 'Least configuration scores:\n');
for i = 1:length(sample_objects)
    sample = sample_objects(i).nodes;
    fprintf(fid, '%d: ', i);
    for nid = 1:length(sample)
        if sample(nid) == 55 || sample(nid) == 56
            continue
        end
        
        cat = strsplit(mapping_nodes_names{sample(nid)}, '_');
        fprintf(fid, '%s, ', cat{1});
    end
    fprintf(fid, '\n');
end

%top scores
[ sample_score, sample_objects ] = choose_mcmc_samples( ...
    all_score, nodes_sets, 10, 5, 1 );

fprintf(fid, 'Top configuration scores:\n');
for i = 1:length(sample_objects)
    sample = sample_objects(i).nodes;
    fprintf(fid, '%d: ', i);
    for nid = 1:length(sample)
        if sample(nid) == 55 || sample(nid) == 56
            continue
        end
        
        cat = strsplit(mapping_nodes_names{sample(nid)}, '_');
        fprintf(fid, '%s, ', cat{1});
    end
    fprintf(fid, '\n');
end

fclose(fid);

