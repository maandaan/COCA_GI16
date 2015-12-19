function [ scene ] = select_models(modelnames_file, scene)
%SELECT_MODELS randomly selects models for each object category

types = [scene(:).obj_type];
[unique_types, b, c] = unique(types);
count_uniques = hist(c, length(unique_types));

% model_names = struct('obj_type',[], 'modelname',[]);
% scene(1).modelname = '';
% model_count = 1;
for nid = 1:length(unique_types)
    obj_type = unique_types(nid);
    obj_cat = get_object_type_bedroom(obj_type);
    
    % find the model names for the specific category
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
        % if the object is already inserted in the scene and the model is
        % specified
        if isfield(scene, 'modelname') && ~isempty(scene(b(nid)).modelname)
            continue
        end
        scene(b(nid)).modelname = obj_models{rand_ind};
    else
%         rand_ind = zeros(1,count_uniques(nid));
        symm = ~isempty(scene(b(nid)).symm_group_id);
        if symm
            random = randi(count);
            rand_ind = repmat(random, 1, count_uniques(nid));
        else
            rand_ind = randi(count, 1, count_uniques(nid));
        end
        
        %check whether at least one object in the group is already inserted
        %in the scene
        group_present = 0;
        for i = 1:length(c)
            if c(i) == nid
                if isfield(scene, 'modelname') && ~isempty(scene(i).modelname)
                    group_present = 1;
                    group_modelname = scene(i).modelname;
                end
            end
        end
        
        m_count = 1;
        for i = 1:length(c)
            if c(i) == nid
                if group_present && symm %one object in the symmetric group already has a definite modelname
                    scene(i).modelname = group_modelname;
                elseif ~isfield(scene, 'modelname') || isempty(scene(i).modelname) %do not change the model for previously inserted objects
                    scene(i).modelname = obj_models{rand_ind(m_count)};
                    m_count = m_count + 1;
                end
            end
        end
    end
end

end

