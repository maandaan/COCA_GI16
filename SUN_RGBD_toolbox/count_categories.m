function [ instances_freq, co_occurrence, mapping_nodes_names ] = count_categories( scene_type, mapping_file )
% This function is to count the co-occurrence of categories and number of instances per category for the input
% scene type. (by Zeinab Sadeghipour)

% scene_type = 'bedroom';
% mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';

load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);

sunrgbdmeta_file = 'SUNRGBDMeta.mat';
load(sunrgbdmeta_file);

[dummy, categories_count] = get_object_type_bedroom('');
instances_freq = repmat(struct('freq', []),categories_count,1); % frequency of each object type, e.g. [4 0 5] shows 1 instance happened 4 times, 2 instances never happened and 3 instances happened 5 times
co_occurrence = zeros(categories_count, categories_count);

for mid = 1:total_size
    % check for the scene type
    if ~strcmp(map_scene_name_type(mid).sceneType, scene_type)
        continue
    end
    
    % get the object labels in each scene
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D)
        continue;
    end
    
    obj_labels = {gt3D(:).classname};
    obj_types = get_object_type_bedroom(obj_labels);
    [unique_types, b, c] = unique(obj_types); % have a unique vector of names for counting co-occurrence
    count_uniques = hist(c, length(unique_types)); % count how many times each category is repeated
    
    for lid = 1:size(unique_types, 1)
        type = unique_types(lid);
        label_count = count_uniques(lid);
        
        if label_count > 1
            co_occurrence(type, type) = co_occurrence(type, type) + 1;
        end
        
        % update the frequency
        freq = instances_freq(type).freq;
        if length(freq) < label_count
            % label_count number of instances never happened
            freq = [freq zeros(1,label_count - length(freq))];
            freq(end) = 1;
        else
            freq(label_count) = freq(label_count) + 1;
        end
        instances_freq(type).freq = freq;
        
        % update the co-occurrence
        for i = 1:size(unique_types,1)
            if i == lid
                continue
            end
            second_type = unique_types(i);
            co_occurrence(type, second_type) = co_occurrence(type, second_type) + 1;
%             co_occurrence(second_label_id, label_id) = co_occurrence(second_label_id, label_id) + 1;
        end
    end
    
    
end

% mapping_nodes_names = {};
count = 1;
for ind = 1:length(instances_freq)
    cat_str = get_object_type_bedroom(ind);
    if isempty(cat_str{1})
        continue
    end
    
    freq = instances_freq(ind).freq;
    if isempty(freq)
        continue
    end
    
    for fid = 1:length(freq)
        mapping_nodes_names{count,1} = [cat_str{1} '_' num2str(fid)];
        count = count + 1;
    end
end

% save('data/training/SUNRGBD/bedroom_co_occurrence_v2.mat', 'co_occurrence');
% save('data/training/SUNRGBD/bedroom_instance_frequency_v2.mat', 'instances_freq');
save('data/training/SUNRGBD/bedroom_mapping_nodes_names_BN_v2.mat', 'mapping_nodes_names');

end

