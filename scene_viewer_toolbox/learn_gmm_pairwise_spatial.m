function gmm_matrix = learn_gmm_pairwise_spatial
% This function learns the set of Gaussian mixture models for pairwise
% spatial relations between object categories. (by Zeinab Sadeghipour)

Consts_fisher;

load(pairwise_relations_file, 'pairwise_relations');
cat_count = size(pairwise_relations,1);
gmm_matrix = repmat(struct('gmm_location',[], 'gmm_angle', []), cat_count, cat_count);

for cid = 1:cat_count
    for pid = 1:cat_count
        this_pair_data = pairwise_relations(cid,pid).relations;
        if isempty(this_pair_data) ...
%                 || size(this_pair_data,1) < size(this_pair_data,2)
            continue
        end
        
        k = 1:5;
        % GMM for only location
        best_gmm = tune_number_of_gaussians(this_pair_data(:,1:3), k);
        gmm_matrix(cid,pid).gmm_location = best_gmm;
        
        % GMM for angle
        best_gmm = tune_number_of_gaussians(this_pair_data(:,4), k);
        gmm_matrix(cid,pid).gmm_angle = best_gmm;
%         gmm_matrix(pid,cid).gmm = best_gmm;
    end
end

save(gmm_pairwise_file, 'gmm_matrix');


end

