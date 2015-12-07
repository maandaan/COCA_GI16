function [ frequent_subgraphs ] = FSM_local_scene_graph( local_graphs_file )
%FSM_LOCAL_SCENE_GRAPH is implemented to apply Frequent Subgraph Mining on
%local scene graphs to detect groups of objects with salient relationships.
%(by Zeinab Sadeghipour)

% local_graphs_file = 'data/training/SUNRGBD/bedroom_local_scene_graphs.mat'

load(local_graphs_file, 'local_graphs');
scene_counts = length(local_graphs);
min_support = floor(0.05 * scene_counts);
[subg, count, GY] = gspan (local_graphs, min_support);

frequent_subgraphs.subgraphs = subg;
frequent_subgraphs.count = double(count);
frequent_subgraphs.prob = double(count) ./ scene_counts;

supporter_set = repmat(struct('supporters', []), 1, length(subg));
for i = 1:length(subg)
    supporters = find(GY(:,i) > 0);
    supporter_set(i).supporters = supporters;
end
frequent_subgraphs.supporter_set = supporter_set;
    
end

