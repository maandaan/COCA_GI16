function [ factors ] = construct_global_factor_graph
%CONSTRUCT_GLOBAL_FACTOR_GRAPH is the updated version of
%construct_global_scene_graph.m with the Factor Graph Toolbox.

Consts;

load(support_relations_file_v2, 'support_matrix');
load(mapping_nodes_names_file_v2, 'mapping_nodes_names');
load(focals_file_v2, 'updated_focals');
load(symmetry_relations_file_v2, 'symmetry_relations');
load(orientation_relations_file_v2, 'orientation_relations');
load(instance_freq_file_v2, 'instances_freq');

scene_count = round(updated_focals.count(1) ./ updated_focals.prob(1));
nodes_count = length(mapping_nodes_names);
vars = 1:nodes_count;
factors = [];

% support factors
support_size = size(support_matrix, 1);
support_matrix = support_matrix(1:support_size-1, 1:support_size-1, :); %just for eliminating the ceiling
support_factors = add_support_factors(support_matrix, mapping_nodes_names);
factors = [factors, support_factors];

% proximity factors
[proximity_factors, single_node_focals] = add_proximity_factors(mapping_nodes_names, updated_focals);
factors = [factors, proximity_factors];

% orientation factors
orientation_factors = add_orientation_factors(scene_count, ...
    orientation_relations, mapping_nodes_names);
factors = [factors, orientation_factors];

% symmetry factors
symmetry_factors = add_symmetry_factors(scene_count, symmetry_relations, mapping_nodes_names);
factors = [factors, symmetry_factors];

% single variable factors
% load(global_factor_graph_file_v2, 'factors', 'single_node_focals')
validnodes = [];
for fid = 1:length(factors)
    validnodes = union(validnodes, factors(fid).var);
end
validnodes = union(validnodes, single_node_focals);
singlevar_factors = add_singlevar_factors(scene_count, instances_freq, mapping_nodes_names, validnodes);
factors = [factors, singlevar_factors];

% update support factors
if ~exist('support_factors', 'var')
    support_factors_ind = [structfind(factors, 'factor_type', suppedge_below), ...
        structfind(factors, 'factor_type', suppedge_behind)];
    support_factors = factors(support_factors_ind);
end
    
extra_support_factors = update_support_factors(support_matrix, singlevar_factors, support_factors, mapping_nodes_names);
factors = [factors, extra_support_factors];

% global graph
% joint_support = ComputeJointDistribution([support_factors, extra_support_factors]);
% joint_proximity = ComputeJointDistribution(proximity_factors);
% joint_orientation = ComputeJointDistribution(orientation_factors);
% joint_symmetry = ComputeJointDistribution(symmetry_factors);
% joint_occurrence = ComputeJointDistribution(singlevar_factors);
% global_graph = [joint_support, joint_proximity, joint_orientation, ...
%     joint_symmetry, joint_occurrence];

% save the result
all_vars = validnodes;
save(global_factor_graph_file_v2, 'factors', 'all_vars');

end

