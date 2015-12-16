function [ BN_dag, best_score ] = learn_BN_structure( bn_data_file, support_relations_file, mapping_nodes_names_file )
%LEARN_BN_STRUCTURE uses the BN toolbox to learn the structure for the
%network, based on the observations. (by Zeinab Sadeghipour)

% bn_data_file = 'data/training/SUNRGBD/bedroom_data_BN.mat';
% mapping_nodes_names_file = 'data/training/SUNRGBD/bedroom_mapping_nodes_names_BN.mat'
% support_relations_file = 'data/training/SUNRGBD/bedroom_support_relations.mat'

load(bn_data_file, 'bn_data');
load(support_relations_file, 'support_matrix');
load(mapping_nodes_names_file, 'mapping_nodes_names');

nodes_count = length(mapping_nodes_names);
init_dag = zeros(nodes_count, nodes_count);

support_matrix = support_matrix(1:56, 1:56, :); %just for eliminating the ceiling

%support edges
for i = 1:size(support_matrix,1)
    for j = 1:size(support_matrix,1)
        if support_matrix(i,j,1) > 0 || support_matrix(i,j,2) > 0 % i is supported by j
            init_dag(j,i) = 1;
        end
    end
end

%cardinality edges
temp = {mapping_nodes_names(:)};
for i = 1:size(support_matrix,1)
    category = get_object_type_bedroom(i);
    cat_name = category{1};
    ind = find(strncmp(temp{:}, cat_name, size(cat_name, 2)));
    
    for j = 2:length(ind)
        init_dag(i, ind(j)) = 1;
    end
end

node_sizes = repmat(2,1,nodes_count);
[BN_dag,best_score] = learn_struct_gs_hard_constraints(bn_data, node_sizes, init_dag);

end

