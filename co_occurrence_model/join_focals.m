function new_focal = join_focals(f1, f2, frequent_subgraphs)
% This function combines two focals indexed by f1 and f2.

Consts;

new_focal = struct('nodelabels',[], 'edges', []);

subg1 = frequent_subgraphs.subgraphs{f1};
subg2 = frequent_subgraphs.subgraphs{f2};
if length(subg1.nodelabels) < length(subg2.nodelabels)
    small_subg = subg1;
    big_subg = subg2;
else
    small_subg = subg2;
    big_subg = subg1;
end

%check whether the smaller focal is a subset of the bigger one
issubset = issubset_focal( small_subg, big_subg );
if issubset
    return
end

%exactly the same set of nodes, but different edges -> we don't want to
%join them
[small_subg_sorted_labels, small_ind] = sort(small_subg.nodelabels);
[big_subg_sorted_labels, big_ind] = sort(big_subg.nodelabels);
if length(small_subg_sorted_labels) == length(big_subg_sorted_labels) && ...
        isempty(find(small_subg_sorted_labels ~= big_subg_sorted_labels, 1))
    return
end

%joining nodes
big_count = 1;
small_count = 1;
small_map = zeros(1, length(small_subg.nodelabels));
big_map = zeros(1, length(big_subg.nodelabels));
nodes = [];
small_finished = 0;
big_finished = 0;

while big_count <= length(big_subg_sorted_labels) || small_count <= length(small_subg_sorted_labels)
    
    if small_count <= length(small_subg_sorted_labels)
        small = small_subg_sorted_labels(small_count);
    else
        small_finished = 1;
    end
    
    if big_count <= length(big_subg_sorted_labels)
        big = big_subg_sorted_labels(big_count);
    else
        big_finished = 1;
    end
    
    if (small < big || big_finished == 1) && small_finished == 0
        nodes = [nodes, small];
        small_map( small_ind(small_count) ) = length(nodes);
        small_count = small_count + 1;
        
    elseif (big < small || small_finished == 1) && big_finished == 0
        nodes = [nodes, big];
        big_map( big_ind(big_count) ) = length(nodes);
        big_count = big_count + 1;
        
    else
        nodes = [nodes, big];
        small_map( small_ind(small_count) ) = length(nodes);
        big_map( big_ind(big_count) ) = length(nodes);
        big_count = big_count + 1;
        small_count = small_count + 1;
    end
end

% updating edges
edges = [];
small_edges = small_subg.edges;
big_edges = big_subg.edges;
%first, add the edges of the smaller focal
for eid = 1:size(small_edges,1)
    start_node = small_map(small_edges(eid,1));
    end_node = small_map(small_edges(eid,2));
    edges = [edges; start_node, end_node, small_edges(eid,3)];
end
%now, add the edges of the bigger focal
for eid = 1:size(big_edges,1)
    start_node = big_map(big_edges(eid,1));
    end_node = big_map(big_edges(eid,2));
    edge = [start_node, end_node, big_edges(eid,3)];
    
    if isempty(edges)
        edges = [edges; edge];
    else
        [~,ind] = ismember(edge, edges, 'rows');
        if ind == 0 %edge is not repeated
            edges = [edges; edge];
        end
    end
end

% if two focals do not share any nodes, we should connect them
focals_separated = isempty(find(ismember(small_subg.nodelabels, big_subg.nodelabels)));
if focals_separated
    edges = [edges; small_map(1), big_map(1), pedge];
end

new_focal.nodelabels = nodes;
new_focal.edges = edges;

% new_focal = big_subg;
% [isshared_nodelabel, shared_ind_bigsubg] = ismember(small_subg.nodelabels, big_subg.nodelabels);
% %node labels
% new_focal.nodelabels = [new_focal.nodelabels; small_subg.nodelabels(~isshared_nodelabel)];
% 
% %debug
% if length(isshared_nodelabel) > 1
%     length(isshared_nodelabel)
% end
% 
% 
% shared_found = ~isempty(isshared_nodelabel);
% bias = length(big_subg.nodelabels);
% 
% if shared_found
%     joint_label = isshared_nodelabel(1);
%     joint_index_small = shared_ind_bigsubg(1);
%     joint_index_big = find(big_subg.nodelabels == joint_label);
%     joint_index_big = joint_index_big(1);
%     new_focal.nodelabels = [new_focal.nodelabels; small_subg.nodelabels(1:joint_index_small-1);...
%         small_subg.nodelabels(joint_index_small+1:end)];
% else
%     joint_index_small = 1;
%     joint_index_big = 1;
%     new_focal.nodelabels = [new_focal.nodelabels; small_subg.nodelabels];
% end
% 
% updated_edges = update_node_indices(small_subg.edges, joint_index_small, joint_index_big, shared_found, bias);
% new_focal.edges = [new_focal.edges; updated_edges];

end

% function updated_edges = update_node_indices(edges, joint_index_small, ...
%     joint_index_big, shared_found, bias)
% % This function updates the node indices for edges when joining focals.
% 
% updated_edges = zeros(size(edges,1),3);
% if shared_found
%     for eid = 1:size(edges,1)
%         
%         if edges(eid,1) < joint_index_small
%             new_edge(1) = edges(eid,1) + bias;
%         elseif edges(eid,1) > joint_index_small
%             new_edge(1) = edges(eid,1) + bias - 1;
%         else
%             new_edge(1) = joint_index_big;
%         end
%         
%         if edges(eid,2) < joint_index_small
%             new_edge(2) = edges(eid,2) + bias;
%         elseif edges(eid,2) > joint_index_small
%             new_edge(2) = edges(eid,2) + bias - 1;
%         else
%             new_edge(2) = joint_index_big;
%         end
%         
%         new_edge(3) = edges(eid,3);
%         updated_edges(eid,:) = new_edge;
%     end
% else
%     updated_edges = edges + uint32(repmat([bias bias 0], size(edges,1), 1));
%     updated_edges = [updated_edges; joint_index_big joint_index_small+bias 1];
% end
% end