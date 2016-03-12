function [ updated_focals ] = focal_joining( frequent_subgraphs_file )
%FOCAL_JOINING combines the extracted focals to form a larger and non-local
%substructure. (by Zeinab Sadeghipour)

% frequent_subgraphs_file = 'data/training/SUNRGBD/bedroom_FSM_gSpan_results_v2.mat'

load(frequent_subgraphs_file, 'frequent_subgraphs');

%computing scene_counts
scene_counts = round(frequent_subgraphs.count(1) ./ frequent_subgraphs.prob(1));

% For now, I even join single nodes, if they satisfy the constraint.
subg = frequent_subgraphs.subgraphs;
focal_num = length(subg);
overlap_thresh = 0.9;

new_focals_count = 1;
new_subgraphs = {};
new_count = [];
new_prob = [];
new_supporter_set = [];

for f1 = 1:focal_num
    support1 = frequent_subgraphs.supporter_set(f1).supporters;
    for f2 = f1+1:focal_num
        support2 = frequent_subgraphs.supporter_set(f2).supporters;
        overlap_support = intersect(support1, support2);
        this_thresh = overlap_thresh * min( length(support1), length(support2) );
        
        if length(overlap_support) > this_thresh
            new_focal = join_focals(f1, f2, frequent_subgraphs);
            if isempty(new_focal.nodelabels)
                continue
            end
%             subplot(1,3,1); visualize_graph(frequent_subgraphs.subgraphs{f1}, 'gspan_code');
%             subplot(1,3,2); visualize_graph(frequent_subgraphs.subgraphs{f2}, 'gspan_code');
%             subplot(1,3,3); visualize_graph(new_focal, 'gspan_code');
%             close all;
            
            if check_repeated_focals(new_focal, frequent_subgraphs.subgraphs) && ...
                    check_repeated_focals(new_focal, new_subgraphs)
                new_subgraphs{new_focals_count,1} = new_focal;
                new_count(new_focals_count) = length(overlap_support);
                new_prob(new_focals_count) = length(overlap_support) ./ scene_counts;
                new_supporter_set(new_focals_count).supporters = overlap_support;
                new_focals_count = new_focals_count + 1;
            end
        end
    end
end

updated_focals.subgraphs = {frequent_subgraphs.subgraphs{:}, new_subgraphs{:}};
updated_focals.count = [frequent_subgraphs.count, new_count];
updated_focals.prob = [frequent_subgraphs.prob, new_prob];
updated_focals.supporter_set = [frequent_subgraphs.supporter_set, new_supporter_set];

% some computation for reports
count = 0;
prob_sum = 0;
for i = 1:length(updated_focals.count)
    g = updated_focals.subgraphs{i};
    if length(g.nodelabels) ~= 1
        count = count + 1;
        prob_sum = prob_sum + updated_focals.prob(i);
    end
end
prob_avg = prob_sum / count;

save('data/training/SUNRGBD/bedroom_focal_joining_results_v2.mat', 'updated_focals');

end

function is_new = check_repeated_focals(new_focal, current_focals)
% This function checks that whether the new_focal has been already in
% current_focals or not.
Consts;

is_new = 1;
[new_nodes_sorted, new_ind] = sort(new_focal.nodelabels);
new_sorted_edges = zeros(size(new_focal.edges, 1), 3);
for eid = 1:size(new_focal.edges, 1)
    sorted_start = find(new_ind == new_focal.edges(eid,1));
    sorted_end = find(new_ind == new_focal.edges(eid,2));
    new_sorted_edges(eid,:) = [sorted_start, sorted_end, new_focal.edges(eid,3)];
end

for fid = 1:length(current_focals)
    break_flag = 0;
    focal = current_focals{fid};
    if length(new_focal.nodelabels) ~= length(focal.nodelabels)
        %         is_new = 1;
        continue
    end
    
    % checking nodes
    [focal_nodes_sorted, focal_ind] = sort(focal.nodelabels);    
    for nid = 1:length(focal.nodelabels)
        if focal_nodes_sorted(nid) ~= new_nodes_sorted(nid)
            break_flag = 1;
            break
        end
    end
    
    if ~break_flag
        is_new = 0;
        return
    end
    
    %checking edges, if we have only proximity edges, there's no need to
    %check edges
%     if size(new_focal.edges,1) ~= size(focal.edges,1)
%         continue
%     end
%     
%     focal_sorted_edges = zeros(size(focal.edges, 1), 3);
%     for eid = 1:size(focal.edges, 1)
%         sorted_start = find(focal_ind == focal.edges(eid,1));
%         sorted_end = find(focal_ind == focal.edges(eid,2));
%         focal_sorted_edges(eid,:) = [sorted_start, sorted_end, focal.edges(eid,3)];
%     end
%     
%     for eid = 1:size(new_sorted_edges, 1)
%         new_edge = new_sorted_edges(eid,:);
%         inverse_new_edge = [new_edge(2), new_edge(1), new_edge(3)];
%         if ~ismember(new_edge, focal_sorted_edges, 'rows') && ...
%                 (new_edge(3) ~= symm_resp && ~ismember(inverse_new_edge, focal_sorted_edges, 'rows'))
%             break_flag = 1;
%             break
%         end
%     end
%     
%     if ~break_flag
%         is_new = 0;
%         return
%     end
end
end

