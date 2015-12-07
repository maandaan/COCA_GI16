function visualize_graph( g, g_type )
%VISUALIZE_GRAPH draws the graph g, based on its type. (by Zeinab
%Sadeghipour)

Consts;

if strcmp(g_type, 'gspan_code')
    node_num = length(g.nodelabels);
    adj_mat = zeros(node_num, node_num);
    adj_type = zeros(node_num, node_num);
    for i = 1:node_num
        cat_name = get_object_type_bedroom(g.nodelabels(i));
        node_ids{i} = cat_name{1};
    end
    
    edge_num = size(g.edges,1);
    for i = 1:edge_num
        this_edge = g.edges(i,:);
        adj_mat(this_edge(1), this_edge(2)) = 1;
        adj_mat(this_edge(2), this_edge(1)) = 1;
        adj_type(this_edge(1), this_edge(2)) = this_edge(3);
        if this_edge(3) ~= symm_resp
            adj_type(this_edge(2), this_edge(1)) = this_edge(3);
        end
    end
    
    %     bg = biograph(adj_mat, node_ids);
    %     view(bg);
    draw_graph(adj_mat, node_ids, adj_type);
    
elseif strcmp(g_type, 'global_graph')
    node_num = length(g.nodes);
    adj_mat = zeros(node_num, node_num);
    adj_type = zeros(node_num, node_num);
    
    edge_num = size(g.edges,1);
    for i = 1:edge_num
        this_edge = g.edges(i,:);
        adj_mat(this_edge(1), this_edge(2)) = 1;
        adj_type(this_edge(1), this_edge(2)) = this_edge(3);
        if this_edge(3) ~= symm_resp && this_edge(3) ~= suppedge_below && this_edge(3) ~= suppedge_behind
            adj_mat(this_edge(2), this_edge(1)) = 1;
            adj_type(this_edge(2), this_edge(1)) = this_edge(3);
        end
    end
    
    %assumption: always either floor or wall or both of them are present in
    %the graph (they are root)
    level = zeros(1, node_num);
    floor_ind = find(strcmp(g.nodelabels, 'floor_1'));
    wall_ind = find(strcmp(g.nodelabels, 'wall_1'));
    
    if isempty(floor_ind) && isempty(wall_ind)
        draw_graph(adj_mat, g.nodelabels, adj_type);
    else
        parent_ind = [floor_ind, wall_ind];
        level(parent_ind) = 1;
        
        %BFS
        while ~isempty(parent_ind)
            next_parents = [];
            for pid = 1:length(parent_ind)
                parent = parent_ind(pid);
                children = find(adj_mat(parent,:));
                %                 if ~isempty(children)
                for cid = 1:length(children)
                    if level(children(cid)) == 0 % not visited
                        level(children(cid)) = level(parent) + 1;
                        next_parents = [next_parents, children(cid)];
                    end
                end
                %                 end
            end
            parent_ind = next_parents;
        end
        
        level = level - 1;
        y = (level+1)./(max(level)+2);
        y = 1-y;
        x = zeros(size(y));
        for i=0:max(level),
            idx = find(level==i);
            offset = (rem(i,2)-0.5)/10;
            x(idx) = (1:length(idx))./(length(idx)+1)+offset;
        end
        
        node_t = zeros(1, node_num);
        draw_graph(adj_mat, g.nodelabels, adj_type, node_t, x, y);
    end
end


end

