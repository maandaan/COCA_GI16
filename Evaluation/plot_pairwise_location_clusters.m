function plot_pairwise_location_clusters( cat1, cat2 )
%PLOT_PAIRWISE_LOCATION_CLUSTERS plots the result for k-means clustering on
%the pairwise location data between categories cat1 & cat2.

Consts;
load(kmeans_file, 'kmeans_matrix');
% load(size_data_file, 'all_valid_sizes');
load(sample_size_fisher_file, 'sample_sizes');

pair_kmeans = kmeans_matrix(cat1, cat2).kmeans_xy;
pairs_num = length(pair_kmeans.cluster_index);
pairs_ind = pair_kmeans.cluster_index;
data = pair_kmeans.data;

colors = {'r','b','g','c','k'};

figure
for pid = 1:pairs_num
    scatter(data(pid,1),data(pid,2),25,colors{pairs_ind(pid)},'filled');
    hold on
end

%the object itself
% ratios_bnd = [all_valid_sizes(cat1).min_wlratio, all_valid_sizes(cat1).max_wlratio];
sample_size = sample_sizes(cat1).fisherDB_dims;
aspect_ratio = sample_size(2) / sample_size(1);
        
base_corners = [-.5 -.5; .5 -.5; .5 .5; -.5 .5; -.5 -.5].*2;
corners = base_corners .* repmat([1 aspect_ratio].* .9, 5, 1);
plot(corners(:,1),corners(:,2));
hold on

corners = base_corners .* repmat([1 aspect_ratio].* .8, 5, 1);
plot(corners(:,1),corners(:,2));
hold on

corners = base_corners .* repmat([1 aspect_ratio], 5, 1);
plot(corners(:,1),corners(:,2));
% axis equal
axis([-10 10 -10 10],'equal')

cat1_str = get_object_type_bedroom(cat1);
cat2_str = get_object_type_bedroom(cat2);
title(sprintf('K-means clustering for locations of %s in %s frame', ...
    cat2_str{1}, cat1_str{1}));

end

