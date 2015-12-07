function [ bn_data, mapping_nodes_names ] = prepare_data_BN_learning( observations_file, mapping_nodes_names_file )
%PREPARE_DATA_BN_LEARNING prepares the data for learning the bayesian
%network, especiall add nodes with different number of instances per
%category than 1. (by Zeinab Sadeghipour)

% observations_file = 'data/training/SUNRGBD/bedroom_object_category_observations.mat'
% mapping_nodes_names_file = 'data/training/SUNRGBD/bedroom_mapping_nodes_names_BN.mat'

load(observations_file, 'variable_obs');
load(mapping_nodes_names_file, 'mapping_nodes_names');
nodes_count = length(mapping_nodes_names);
prev_nodes_count = nodes_count;

%adding nodes with multiple instances of a category
for nid = 1:nodes_count-2 %except floor and wall
    node_obs = variable_obs(nid,:);
    ind = find(node_obs > 1);
    cardinality = unique(node_obs(ind));
    for cid = 1:length(cardinality)
        nodes_count = nodes_count + 1;
        category = get_object_type_bedroom(nid);
        mapping_nodes_names{nodes_count} = [category{1} '_' num2str(cardinality(cid))];
    end
end

temp = {mapping_nodes_names(:)};
bn_data = zeros(nodes_count, size(variable_obs, 2));
for sid = 1:size(variable_obs, 2)
    prev_obs = variable_obs(:,sid);
    ind = find(prev_obs > 1);
    bn_data(1:prev_nodes_count, sid) = prev_obs;
    bn_data(ind, sid) = 0;
    
    if length(ind) > 1
        a = 1;
    end
    
    for i = 1:length(ind)
        category = get_object_type_bedroom(ind(i));
        node_name = [category{1} '_' num2str(prev_obs(ind(i)))];
        node_row = find(strcmp(temp{:}, node_name));
        bn_data(node_row, sid) = 1;
    end
end

end

