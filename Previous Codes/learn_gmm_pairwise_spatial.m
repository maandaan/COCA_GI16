function [ gmm_matrix ] = learn_gmm_pairwise_spatial
% This function learns the set of Gaussian mixture models for pairwise
% spatial relations between object categories. (by Zeinab Sadeghipour)

% pairwise_spatial_file = 'data/training/SUNRGBD/bedroom_pairwise_spatial_relations.mat'
Consts;

load(pairwise_locations_file);
co_spatial_relations = pair_spatial_rels_location;
% load(pairwise_spatial_file, 'co_spatial_relations');
cat_count = size(co_spatial_relations,1);
gmm_matrix = repmat(struct('gmm_location',[], 'gmm_angle', []), cat_count, cat_count);

for cid = 1:cat_count
    for pid = 1:cat_count
        this_pair_data = co_spatial_relations(cid,pid).spatial_rel;
        if isempty(this_pair_data) || size(this_pair_data,1) < size(this_pair_data,2)
            continue
        end
        
        k = 1:2;
        % GMM for only location
        best_gmm = tune_number_of_gaussians(this_pair_data(:,1:3), k);
        gmm_matrix(cid,pid).gmm_location = best_gmm;
        
        % GMM for angle
        best_gmm = tune_number_of_gaussians(this_pair_data(:,4), k);
        gmm_matrix(cid,pid).gmm_angle = best_gmm;
%         gmm_matrix(pid,cid).gmm = best_gmm;
    end
end

save(gmm_file, 'gmm_matrix');

end

