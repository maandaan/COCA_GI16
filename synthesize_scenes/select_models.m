function [ scene ] = select_models(modelnames_file, scene, global_scene_graph)
%SELECT_MODELS randomly selects models for each object category

types = [scene(:).obj_type];
[unique_types, b, c] = unique(types);
count_uniques = hist(c, length(unique_types));

% model_names = struct('obj_type',[], 'modelname',[]);
scene(1).modelname = '';
% model_count = 1;
for nid = 1:length(unique_types)
    obj_type = unique_types(nid);
    obj_cat = get_object_type_bedroom(obj_type);
    
    h = fopen(modelnames_file);
    line = fgets(h);
    obj_models = {};
    count = 0;
    while ischar(line)
        if ~isempty(strfind(line, obj_cat{1}))
            count = count + 1;
            line_parts = strsplit(line, '|');
            obj_models{count} = line_parts{1};
        end
        line = fgets(h);
    end
    fclose(h);
    if count == 0
        continue
    end
    
    if count_uniques(nid) == 1
        rand_ind = randi(count);
%         model_names(model_count).modelname = obj_models{rand_ind};
%         model_names(model_count).obj_type = obj_type;
%         model_count = model_count + 1;
        scene(b(nid)).modelname = obj_models{rand_ind};
    else
%         symm = false;
%         factors = global_scene_graph.factors;
%         symmg_rows = structfind(factors, 'factor_type', 4);
%         symmresp_rows = structfind(factors, 'factor_type', 5);
%         symm_rows = [symmg_rows; symmresp_rows];
%         for rid = 1:length(symm_rows)
%             vars = factors(symm_rows(rid)).variables;
%             if vars(1) == obj_type
%                 symm = true;
%                 break
%             end
%         end
        % the objects are symmetric, the same model
        rand_ind = zeros(1,count_uniques(nid));
        symm = ~isempty(scene(b(nid)).symm_group_id);
        if symm
            random = randi(count);
            rand_ind = repmat(random, 1, count_uniques(nid));
        else
            rand_ind = randi(count, 1, count_uniques(nid));
        end
        m_count = 1;
        for i = 1:length(c)
            if c(i) == nid
                scene(i).modelname = obj_models{rand_ind(m_count)};
                m_count = m_count + 1;
            end
        end
%         for i = 1:length(rand_ind)
%             model_names(model_count).modelname = obj_models{rand_ind(i)};
%             model_names(model_count).obj_type = obj_type;
%             model_count = model_count + 1;
%         end
    end
end

end

