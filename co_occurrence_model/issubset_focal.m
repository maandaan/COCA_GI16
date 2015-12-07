function [ issubset ] = issubset_focal( focal1, focal2 )
%ISSUBSET_FOCAL checks whether either of focal1 or focal2 is a subset of
%the other one with the assumption that size of focal1 is less than focal2.
%(by Zeinab Sadeghipour)

Consts;

%first, check for nodes
[unique_nodes_1, ~, c] = unique(focal1.nodelabels);
unique_counts_1 = hist(c, length(unique_nodes_1));

[unique_nodes_2, ~, c] = unique(focal2.nodelabels);
unique_counts_2 = hist(c, length(unique_nodes_2));

[ismember_nodes, ismember_ind] = ismember(unique_nodes_1, unique_nodes_2);
if ~isempty(find(ismember_nodes == 0 ,1)) %if there's a node in smaller focal that is not in the bigger one
    issubset = 0;
    return;
end

for i = 1:length(ismember_nodes)
    if unique_counts_1(i) > unique_counts_2(ismember_ind(i)) %if the smaller focal has more instances of the same object type
        issubset = 0;
        return;
    end
end

%now, check for edges
for eid = 1:size(focal1.edges, 1)
    edge_1_start = focal1.nodelabels(focal1.edges(eid,1));
    edge_1_end = focal1.nodelabels(focal1.edges(eid,2));
    edge_1_type = focal1.edges(eid,3);
    
    matched_edge = 0;
    for eeid = 1:size(focal2.edges, 1)
        edge_2_start = focal2.nodelabels(focal2.edges(eeid,1));
        edge_2_end = focal2.nodelabels(focal2.edges(eeid,2));
        % only for symm_resp edges, the direction does matter
        if focal2.edges(eeid,3) == edge_1_type && ...
                (edge_1_start == edge_2_start && edge_1_end == edge_2_end) || ...
                (edge_1_type ~= symm_resp && edge_1_start == edge_2_end && edge_1_end == edge_2_start)
            matched_edge = 1;
            break
        end
    end
    
    if ~matched_edge
        issubset = 0;
        return;
    end
end

issubset = 1;

end

