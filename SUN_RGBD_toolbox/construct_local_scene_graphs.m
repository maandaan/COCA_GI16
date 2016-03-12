function [ local_graphs ] = construct_local_scene_graphs()
%CONSTRUCT_LOCAL_SCENE_GRAPHS constructs the local scene graph for each
%image. For now, the edges are only proximity edges, meaning that each
%object is connected to the closest object in the scene. (What may be
%added: symmetry, special angle directions like 90, 180, ...) (by Zeinab
%Sadeghipour)

% scene_type = 'bedroom';
% mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';
% symmetry_groups_file = 'data/training/SUNRGBD/bedroom_symmetry_groups.mat';
% special_orientations_file = 'data/training/SUNRGBD/bedroom_special_orientations.mat';

Consts;

load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);

sunrgbdmeta_file = 'SUNRGBDMeta.mat';
load(sunrgbdmeta_file);

graph_count = 1;
valid_scene_type_indices = [];

for mid = 1:total_size
    % check for the scene type
    if ~strcmp(map_scene_name_type(mid).sceneType, scene_type)
        continue
    end
   
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D) || size(gt3D,2) < 2
        continue;
    end
    
    valid_scene_type_indices = [valid_scene_type_indices, mid];
    
    no_objects = size(gt3D,2);
    nodes = [];
    distances = zeros(no_objects, no_objects); %all the pairwise distances
    adj_matrix = repmat(struct('edges', []),no_objects, no_objects); % adjacency matrix for graph
    
    % for each scene, loop through objects
    for oid = 1:no_objects
        
        this_centroid = gt3D(oid).centroid;
        %         this_orient = gt3D(oid).orientation;
        this_type = get_object_type_bedroom({gt3D(oid).classname});
        nodes = [nodes; this_type];
        
        for pid = 1:no_objects
            if oid == pid
                distances(oid, pid) = realmax;
                continue
            end
            
            pair_centroid = gt3D(pid).centroid;
            %             pair_orient = gt3D(pid).orientation;
            %             pair_type = get_object_type_bedroom({gt3D(pid).classname});
            
            distance = norm(this_centroid - pair_centroid);
            distances(oid, pid) = distance;
            %             cos_angle = dot(this_orient, pair_orient) / (norm(this_orient) * norm(pair_orient));
            %             angle = acos( min(max(cos_angle, -1), 1) ); % for fixing the cases where the cos_angle = 1 or -1
        end
    end
    
    adj_matrix = add_proximity_edges(adj_matrix, distances, pedge);
    % add other types of edges, in future :D
%     if ~isempty(structfind(symmetry_groups, 'scene_index', mid))
%         adj_matrix = add_symmetry_edges(adj_matrix, symmetry_groups, mid, symm_g, symm_resp);
%     end
%     if ~isempty(structfind(special_orientations, 'scene_index', mid))
%         adj_matrix = add_orientation_edges(adj_matrix, special_orientations, mid, same_dir, perpendicular, facing);
%     end
    adj_matrix = connect_components(adj_matrix, distances, pedge);
    
    local_graphs{1,graph_count}.nodelabels = uint32(nodes);
    local_graphs{1,graph_count}.edges = get_edges_from_adj_matrix(adj_matrix, symm_resp);
    graph_count = graph_count + 1;
   
end

save(valid_scene_indices, 'valid_scene_type_indices');
save(local_graphs_file_v2, 'local_graphs')

end

function adj_matrix = add_proximity_edges(adj_matrix, distances, pedge)
% This function constructs proximity edges based on the minimum pairwise
% distances.

for i = 1:size(distances,1)
    min_dist = min(distances(i,:));
    ind = find(distances(i,:) == min_dist);
    
    for j = 1:length(ind)
        curr_edges = adj_matrix(i, ind(j)).edges;
        
        if isempty(find(curr_edges == pedge, 1)) %if the edge is not added already
            curr_edges = [curr_edges; pedge];
            adj_matrix(i, ind(j)).edges = curr_edges;
            
            curr_edges = adj_matrix(ind(j), i).edges;
            curr_edges = [curr_edges; pedge];
            adj_matrix(ind(j), i).edges = curr_edges;
        end
    end
end

end

function adj_matrix = add_symmetry_edges(adj_matrix, symmetry_groups, scene_index, symm_g, symm_resp)
% This function adds symmetry edges to the adjacency matrix

rows = structfind(symmetry_groups, 'scene_index', scene_index);
for rid = 1:length(rows)
    symm_group_ind = symmetry_groups(rows(rid)).symm_group_ind;
    symm_group_outside_obj = symmetry_groups(rows(rid)).symm_group_outside_obj_ind;
    
    for oid = 1:length(symm_group_ind)
        obj1 = symm_group_ind(oid);
        for ooid = oid+1:length(symm_group_ind)
            obj2 = symm_group_ind(ooid);
            curr_edges = adj_matrix(obj1,obj2).edges;
            curr_edges = [curr_edges; symm_g];
            adj_matrix(obj1,obj2).edges = curr_edges;
            
            curr_edges = adj_matrix(obj2,obj1).edges;
            curr_edges = [curr_edges; symm_g];
            adj_matrix(obj2,obj1).edges = curr_edges;
        end
        
        if symm_group_outside_obj > 0
            curr_edges = adj_matrix(obj1,symm_group_outside_obj).edges;
            curr_edges = [curr_edges; symm_resp];
            adj_matrix(obj1,symm_group_outside_obj).edges = curr_edges;
        end
    end
end

end

function adj_matrix = add_orientation_edges(adj_matrix, special_orientations, scene_index, same_dir, perpendicular, facing)
% This function adds special orientations to the adjacency matrix

rows = structfind(special_orientations, 'scene_index', scene_index);

for rid = 1:length(rows)
    
    obj1 = special_orientations(rows(rid)).first_obj_index;
    obj2 = special_orientations(rows(rid)).second_obj_index;
    
%     if special_orientations(rows(rid)).orient_type == 3
%         orient_type = same_dir;
%     else
    if special_orientations(rows(rid)).orient_type == 1
        orient_type = perpendicular;
    elseif special_orientations(rows(rid)).orient_type == 2
        orient_type = facing;
    else
        continue
    end
    
    curr_edges = adj_matrix(obj1,obj2).edges;
    curr_edges = [curr_edges; orient_type];
    adj_matrix(obj1,obj2).edges = curr_edges;
    
    curr_edges = adj_matrix(obj2,obj1).edges;
    curr_edges = [curr_edges; orient_type];
    adj_matrix(obj2,obj1).edges = curr_edges;
end

end

function adj_matrix = connect_components(adj_matrix, distances, pedge)
% This function connects all the components through proximity edges

%convert adj_matrix to A, the format needed for using the function to find
%connected components
A = zeros(size(adj_matrix,1),size(adj_matrix,1));
for i = 1:size(adj_matrix,1)
    for j = 1:size(adj_matrix,1)
        if ~isempty(adj_matrix(i,j).edges)
            A(i,j) = 1;
        end
    end
end

%finding the connected components
[nComponents,sizes,members] = networkComponents(A);

while nComponents > 1
    component = members{1};
    min_dist = realmax;
    
    for ccid = 2:nComponents
        %         if cid == ccid
        %             continue
        %         end
        
        pair_component = members{ccid};
        this_pair_min = min(min(distances(component, pair_component))); % finding the minimum distance between all pairs in these two components
        [r,c] = find( distances(component, pair_component) == this_pair_min );
        if this_pair_min < min_dist
            min_dist = this_pair_min;
            min_pair_component = pair_component;
            min_row = r;
            min_col = c;
        end
    end
    
    % adding edges to connect two components
    for j = 1:length(min_row)
        node1 = component(min_row(j));
        node2 = min_pair_component(min_col(j));
        A(node1, node2) = 1;
        A(node2, node1) = 1;
    end
    [nComponents,sizes,members] = networkComponents(A);
end

% convert A to adj_matrix back
for i = 1:size(A,1)
    for j = 1:size(A,2)
        if A(i,j) && isempty(adj_matrix(i,j).edges) %edges created after connecting components
            adj_matrix(i,j).edges = pedge;
            adj_matrix(j,i).edges = pedge;
        end
    end
end
end

function edges = get_edges_from_adj_matrix(adj_matrix, symm_resp)
% This function converts the adjacency matrix to the format needed to use
% in gspan code to mine frequent subgraphs

% assumption: the matrix is symmetric!
edges = [];
for i = 1:size(adj_matrix,1)
    for j = 1:size(adj_matrix,2)
        if isempty(adj_matrix(i,j).edges)
            continue
        end
                
        this_pair_edges = adj_matrix(i,j).edges;
        % only for symmetry w.r.t relation, because it's assymetric
        if j < i 
            if ~isempty(find(this_pair_edges == symm_resp, 1))
                edges = [edges; i,j,symm_resp];
            end
            continue
        end
        
        for eid = 1:length(this_pair_edges)
            edges = [edges; i,j,this_pair_edges(eid)];
        end
    end
end

edges = uint32(edges);
end

