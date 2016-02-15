function plot_pairwise_location_clusters( cat1, cat2 )
%PLOT_PAIRWISE_LOCATION_CLUSTERS plots the result for k-means clustering on
%the pairwise location data between categories cat1 & cat2.

Consts;
load(kmeans_file, 'kmeans_matrix');
load(size_data_file, 'all_valid_sizes');

pair_kmeans = kmeans_matrix(cat1, cat2).kmeans_xy;
pairs_num = length(pair_kmeans.cluster_index);
pairs_ind = pair_kmeans.cluster_index;
data = pair_kmeans.data;

colors = {'r.','b.','g.','y.','p.'};

figure
for pid = 1:pairs_num
    scatter(data(pid,1),data(pid,2),colors{pairs_ind(pid)});
    hold on
end

%the object itself
ratios_bnd = [all_valid_sizes(cat1).min_wlratio, all_valid_sizes(cat1).max_wlratio];
        
base_corners = [-.5 -.5; .5 -.5; .5 .5; -.5 .5; -.5 -.5].*2;
corners = base_corners .* repmat([1 ratios_bnd(1)].* .75, 5, 1);
plot(corners(:,1),corners(:,2));
hold on

corners = base_corners .* repmat([1 ratios_bnd(2)].* 1.25, 5, 1);
plot(corners(:,1),corners(:,2));
hold on

corners = base_corners .* repmat([1 mean(ratios_bnd)], 5, 1);
plot(corners(:,1),corners(:,2));
% axis equal

cat1_str = get_object_type_bedroom(cat1);
cat2_str = get_object_type_bedroom(cat2);
title(sprintf('K-means clustering for locations of %s in %s frame', ...
    cat2_str{1}, cat1_str{1}));

end

