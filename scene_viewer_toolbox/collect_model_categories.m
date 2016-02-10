%This script collects and cleans the data for object categories for 3D
%models in Fisher DB.

Consts_fisher;

fid = fopen(models_file);
line = fgets(fid);
model_categories = struct('modelname', [], 'obj_name', [], 'obj_category_str', [], 'obj_category_num', []);

count = 1;
while ischar(line)
    
    line_parts = strsplit(line, '|');
    model_categories(count).modelname = line_parts{1};
    model_categories(count).obj_name = line_parts{2};
    count = count + 1;
    
    line = fgets(fid);
end

% save(out_file, 'model_categories');

%assign categories manually

for mid = 1:length(model_categories)
    if isempty(model_categories(mid).obj_category_str)
        continue
    end
    
    model_categories(mid).obj_category_num = get_object_type_bedroom({model_categories(mid).obj_category_str});
end

save(mapping_model_categories_file, 'model_categories');