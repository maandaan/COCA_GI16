%This script prunes the model categories for 3D models in the fisher
%database and writes the results to a text file.

scene_db_dir = 'data/Synthesized Scenes/';
modelnames_file = [scene_db_dir 'fields/models_pruned_categories.txt'];
mapping_model_categories_file = 'data\training\FisherDB\mapping_model_categories.mat';

fid = fopen(modelnames_file, 'w');
for mid = 1:length(model_categories)
    
    if strcmp(model_categories(mid).obj_category_str, 'room') || ...
            isempty(model_categories(mid).obj_category_str)
        continue
    end
    
    fprintf(fid, '%s', model_categories(mid).modelname);
    fprintf(fid, '|');
    fprintf(fid, '%s', model_categories(mid).obj_category_str);
    fprintf(fid, '\n');
end

fclose(fid);