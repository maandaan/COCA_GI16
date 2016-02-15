function plot_pairwise_location_gmm( cat1, cat2 )
%PLOT_PAIRWISE_LOCATION_GMM plots the result for gmm fitting on
%the pairwise location data between categories cat1 & cat2.

Consts_fisher;
load(sample_size_fisher_file, 'sample_sizes');
load(gmm_location_file_SUNRGBD, 'gmm_matrix');
load(pairwise_location_file_SUNRGBD, 'pair_spatial_rels_location');

pair_gmm_l = gmm_matrix(cat1, cat2).gmm_location;
pair_raw_data = pair_spatial_rels_location(cat1,cat2).spatial_rel;

[samples,idx] = random(pair_gmm_l, size(pair_raw_data, 1));

colors = {'r','b','g','c','k'};
figure
for sid = 1:size(samples,1)
    scatter(samples(sid,1), samples(sid,2), 10, colors{idx(sid)}, 'filled');
    hold on
end

%the object itself
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
title(sprintf('GMM samples for locations of %s in %s frame', ...
    cat2_str{1}, cat1_str{1}));


end

