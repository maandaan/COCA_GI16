% This script aims to collect and map the support relations in NYUv2
% dataset from image regions to object labels. (by Zeinab Sadeghipour)

scene_type = 'bedroom';
nyu_dataset_dir = 'data/indoor_scene_seg_sup/data2/2012_eccv_support_inference/';

nyu_dataset_path = [nyu_dataset_dir 'nyu_depth_v2_labeled.mat'];
nyu_data = matfile(nyu_dataset_path);
all_sceneTypes = nyu_data.sceneTypes;
labelnames = nyu_data.names;

support_labels_file = [nyu_dataset_dir 'support_labels.mat'];
load(support_labels_file, 'supportLabels');

regions_filename = [nyu_dataset_dir 'regions/regions_from_labels_%06d.mat'];
labels_filename = [nyu_dataset_dir 'labels_objects/labels_%06d.mat'];

%select the desired scene type
scene_type_indices = find(strcmp(scene_type, all_sceneTypes));
scene_type_size = length(scene_type_indices);
semantic_support_labels = repmat(struct('support_rel',[]),scene_type_size,1);

for sid = 1:scene_type_size
        
    data_id = scene_type_indices(sid);
    support_relations = supportLabels{data_id,1};
    semantic_support = [];
    
    load(sprintf(regions_filename, data_id));
    load(sprintf(labels_filename, data_id),'imgObjectLabels');
    
    % loop through available support relations
    for srid = 1:size(support_relations,1)
        supported_region = support_relations(srid,1);
        supporting_region = support_relations(srid,2);
        support_type = support_relations(srid,3);
        
        % find the object label correspondign to that region
        [r,c] = find(imgRegions == supported_region);
        if isempty(r)
            continue
        end
        supported_label = imgObjectLabels(r(1),c(1));
        
        [r,c] = find(imgRegions == supporting_region);
        if isempty(r)
            continue
        end
        supporting_label = imgObjectLabels(r(1),c(1));
        
        if supported_label == 0 || supporting_label == 0
            continue;
        end
        
        semantic_support(srid).supported = labelnames(supported_label);
        semantic_support(srid).supporting = labelnames(supporting_label);
        semantic_support(srid).type = support_type;
    end
    
    semantic_support_labels(sid).support_rel = semantic_support;
end

support_matrix = count_support_relations( semantic_support_labels );

save('data/training/SUNRGBD/bedroom_support_labels_v2.mat','semantic_support_labels');
save('data/training/SUNRGBD/bedroom_support_relations_v2.mat','support_matrix');
