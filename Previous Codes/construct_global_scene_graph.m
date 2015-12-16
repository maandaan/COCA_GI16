function [ global_scene_graph ] = construct_global_scene_graph
%CONSTRUCT_GLOBAL_SCENE_GRAPH combines the support relations and focal
%informations in one global factor graph. (by Zeinab Sadeghipour)

Consts;

load(support_relations_file, 'support_matrix');
load(mapping_nodes_names_file, 'mapping_nodes_names');
load(focals_file, 'updated_focals');
load(symmetry_relations_file, 'symmetry_relations');
load(orientation_relations_file, 'orientation_relations');
load(instance_freq_file, 'instances_freq');

scene_count = round(updated_focals.count(1) ./ updated_focals.prob(1));
nodes_count = length(mapping_nodes_names);
nodes = 1:nodes_count;
edges = [];
factors = struct('variables', [], 'factor_type', [], 'potential_func', []);

%support edges
support_matrix = support_matrix(1:56, 1:56, :); %just for eliminating the ceiling
[ supp_edges, supp_factors, support_thresh_avg, support_count ] = add_support_edges_global_graph( support_matrix );
edges = [edges; supp_edges];
% factors = [factors; supp_factors];

%proximity edges
[ proximity_edges, proximity_factors, single_node_focals, focal_count ] = add_proximity_edges_global_graph( mapping_nodes_names, updated_focals );
edges = [edges; proximity_edges];
factors = [factors; proximity_factors];

%add orientation edges
[ orientation_edges, orientation_factors, orient_prob_avg, orient_count ] = add_orientation_edges_global_graph( scene_count, orientation_relations );
edges = [edges; orientation_edges];
factors = [factors; orientation_factors];

%add symmetry edges
[ symm_edges, symm_factors, symm_prob_avg, symm_count ] = add_symmetry_edges_global_graph( scene_count, symmetry_relations, mapping_nodes_names );
edges = [edges; symm_edges];
factors = [factors; symm_factors];

% counting nodes and factors, eliminating the nodes with no edge for now
node_count = 0;
validnodes = [];
for nid = 1:length(nodes)
    if isempty(find( edges(:,1) == nid)) && isempty(find( edges(:,2) == nid))
       if ~isempty(find(single_node_focals == nid)) % if it's a single node focal, it means it's frequent enough
           node_count = node_count + 1;
           validnodes = [validnodes, nid];
       end
       continue
    end
    node_count = node_count + 1;
    validnodes = [validnodes, nid];
end
node_count

% add single variable factors relating to frequency for valid nodes
singlevar_factors = add_singlevar_factors_global_graph(scene_count, instances_freq, mapping_nodes_names, validnodes);
factors = [factors; singlevar_factors];

%add support factors for singlevar_factors which don't have support already
[ extra_supp_edges, extra_supp_factors, extra_supp_count ] = ...
    update_support_edges_global_graph(support_matrix, singlevar_factors, supp_factors, mapping_nodes_names);
edges = [edges; extra_supp_edges];
factors = [factors; extra_supp_factors];

% pf = [1; exp(1)];
% potential_func = struct('PF', pf);
% factors = [factors; struct('variables', 55, 'factor_type', occurrence, 'potential_func', potential_func)];
% factors = [factors; struct('variables', 56, 'factor_type', occurrence, 'potential_func', potential_func)];

factor_count = symm_count + support_count + focal_count + orient_count + extra_supp_count 

global_scene_graph.nodes = nodes;
global_scene_graph.nodelabels = mapping_nodes_names;
global_scene_graph.validnodes = validnodes;
global_scene_graph.edges = edges;
global_scene_graph.factors = factors(2:end);

end

