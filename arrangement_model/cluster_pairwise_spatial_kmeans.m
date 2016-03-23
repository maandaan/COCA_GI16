function kmeans_matrix = cluster_pairwise_spatial_kmeans
%CLUSTER_PAIRWISE_SPATIAL_KMEANS clusters the spatial relations between
%pairs of object categories using kmeans.

Consts;
load(pairwise_locations_file, 'pair_spatial_rels_location');
cat_count = size(pair_spatial_rels_location,1);
kmeans_matrix = repmat(struct('kmeans_xy',[], 'kmeans_angle', []), cat_count, cat_count);

for cid = 1:cat_count
    for pair_id = 1:cat_count
        data = pair_spatial_rels_location(cid, pair_id).spatial_rel;
        
        if isempty(data) || size(data,1) < 5
            continue
        end
        
        % cluster x and y
        e = evalclusters(data(:,1:2), 'kmeans', 'silhouette', 'klist',[1:4]);
        %find the optimal number of clusters
        if isempty( find(e.CriterionValues(2:end) >= 0.6, 1))
            num_clust = 1;
        else
            num_clust = e.OptimalK;
        end
        
        try
            [ind, c, sumd, d] = kmeans(data(:,1:2), num_clust, 'Replicates', num_clust+1);
        catch
            fprintf('main category: %d, pair_id: %d, num_clust: %d\n', cid, pair_id, num_clust);
        end
        kmeans_xy = struct('data', data(:,1:2), 'num_cluster', num_clust, ...
            'cluster_index', ind, 'cluster_centroid', c, 'sum_distance', sumd, ...
            'distance_to_centroids', d);
        
        % cluster angle
        e = evalclusters(data(:,4), 'kmeans', 'silhouette', 'klist',[1:4]);
        %find the optimal number of clusters
        if isempty( find(e.CriterionValues(2:end) >= 0.6, 1))
            num_clust = 1;
        else
            num_clust = e.OptimalK;
        end
        [ind, c, sumd, d] = kmeans(data(:,4), num_clust, 'Replicates', num_clust+1);
        kmeans_angle = struct('data', data(:,4), 'num_cluster', num_clust, ...
            'cluster_index', ind, 'cluster_centroid', c, 'sum_distance', sumd, ...
            'distance_to_centroids', d);
        
        %cluster x,y and angle
        e = evalclusters([data(:,1:2), data(:,4)], 'kmeans', 'silhouette', 'klist',[1:4]);
        %find the optimal number of clusters
        if isempty( find(e.CriterionValues(2:end) >= 0.6, 1))
            num_clust = 1;
        else
            num_clust = e.OptimalK;
        end
        try
            [ind, c, sumd, d] = kmeans([data(:,1:2), data(:,4)], num_clust, 'Replicates', num_clust+1);
        catch me
            fprintf(me.message)
        end
        kmeans_xyangle = struct('data', [data(:,1:2), data(:,4)], 'num_cluster', num_clust, ...
            'cluster_index', ind, 'cluster_centroid', c, 'sum_distance', sumd, ...
            'distance_to_centroids', d);
        
        kmeans_matrix(cid, pair_id).kmeans_xy = kmeans_xy;
        kmeans_matrix(cid, pair_id).kmeans_angle = kmeans_angle;
        kmeans_matrix(cid, pair_id).kmeans_xyangle = kmeans_xyangle;
    end
    fprintf('Finished for category: %d\n', cid);
end

save(kmeans_file, 'kmeans_matrix');

end

