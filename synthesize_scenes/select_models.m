function [ scene ] = select_models(modelnames_file, scene)
%SELECT_MODELS randomly selects models for each object category

% types = [scene(:).obj_type];
cats = {scene(:).obj_category};
[unique_types, b, c] = unique(cats);
count_uniques = hist(c, length(unique_types));

% model_names = struct('obj_type',[], 'modelname',[]);
% scene(1).modelname = '';
% model_count = 1;
for nid = 1:length(unique_types)
    cat = unique_types(nid);
    %the following lines seem unnecessary, but they're not! To ensure
    %consistency between old and new versions of mapping between object
    %categories and types
    obj_type = get_object_type_bedroom(cat);
    obj_cat = get_object_type_bedroom(obj_type);
    if strcmp(obj_cat{1}, 'night_stand')
        obj_cat = {'nightstand'};
    end
    
    %for better visualization, we will always use this 3D model for room
    if strcmp(obj_cat, 'room')
        scene(b(nid)).modelname = 'room02';
        continue
    end
    
    % find the model names for the specific category
    h = fopen(modelnames_file);
    line = fgets(h);
    obj_models = {};
    count = 0;
    while ischar(line)
        if ~isempty(strfind(line, obj_cat{1}))
            line_parts = strsplit(line, '|');
%             if strcmp(strtrim(line_parts{2}), obj_cat{1}) %look for exact matches
                count = count + 1;
                obj_models{count} = line_parts{1};
%             end
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

