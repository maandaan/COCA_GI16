% selected_nodes = [2,7,9,10,13,31,32,45,55,75,76,77];
selected_nodes_str = {'painting_1', 'bedside_1','bed_1','chair_1','desk_1','lamp_1','wall_1','floor_1','book_1'};
% selected_nodes = [75, 9, 13, 70, 100, 61, 69, 10, 32, 31, 7, 2, 76];
selected_nodes = [];
load('data\training\SUNRGBD\bedroom_mapping_nodes_names_BN.mat');
for i = 1:length(selected_nodes_str)
    ind = find( strcmp( mapping_nodes_names(:), selected_nodes_str{i}));
    selected_nodes = [selected_nodes, ind];
end
selected_nodes = sort(selected_nodes);

original_graph = global_scene_graph;
partial_graph.nodes = original_graph.nodes(selected_nodes);
partial_graph.nodelabels = original_graph.nodelabels(selected_nodes);

Consts;

edges = [];
orig_edges = original_graph.edges;
for eid = 1:size(orig_edges, 1)
    % support
    if orig_edges(eid,3) ~= suppedge_below && orig_edges(eid,3) ~= suppedge_behind
        continue
    end
    
    % proximity
%     if orig_edges(eid,3) ~= pedge
%         continue
%     end
    
    % symmetry
%     if orig_edges(eid,3) ~= symm_g && orig_edges(eid,3) ~= symm_resp
%         continue
%     end
    
    % special orientations
%     if orig_edges(eid,3) ~= facing && orig_edges(eid,3) ~= perpendicular
%         continue
%     end

    start_ind = find(selected_nodes == orig_edges(eid,1));
    end_ind = find(selected_nodes == orig_edges(eid,2));
    if isempty(start_ind) || isempty(end_ind)
        continue
    end
   
    new_edge = [start_ind(1) end_ind(1) orig_edges(eid,3)];
    edges = [edges; new_edge];
end
partial_graph.edges = edges;

visualize_graph(partial_graph, 'global_graph');

