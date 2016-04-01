%A list of filenames and other constant values for the codes in the
%scene_viewer_toolbox

scene_db_dir = 'data/databaseFull_fisher_Stanford/';
models_dir = [scene_db_dir 'models/'];
scenes_dir = [scene_db_dir 'scenes/'];
models_file = [scene_db_dir, 'fields\names.txt'];

mapping_model_categories_file = 'data\training\FisherDB\mapping_model_categories.mat';
fisher_scenes_file = 'data\databaseFull_fisher_Stanford\scenes\all_scenes.mat';
pairwise_relations_file = 'data\training\FisherDB\pairwise_relations.mat';
gmm_pairwise_file = 'data\training\FisherDB\gmm_pairwise_relations.mat';
gmm_weights_file = 'data\training\FisherDB\gmm_weights.mat';
support_relations_file = 'data\training\FisherDB\support_relations.mat';
estimated_PDF_support_file = 'data\training\FisherDB\estimated_PDF_support.mat';

%SUN RGBD data
sunrgbdmeta_file = 'SUNRGBDMeta.mat';
mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';
scene_type = 'bedroom';
pairwise_relations_file_SUNRGBD = 'data/training/SUNRGBD/pairwise_relations_fisher.mat';
gmm_pairwise_file_SUNRGBD = 'data/training/SUNRGBD/gmm_pairwise_relations_fisher.mat';
gmm_weights_file_SUNRGBD = 'data/training/SUNRGBD/gmm_weights_fisher.mat';
pairwise_location_file_SUNRGBD = 'data/training/SUNRGBD/bedroom_pairwise_locations.mat';
gmm_location_file_SUNRGBD = 'data/training/SUNRGBD/gmm_pairwise_location_fisher.mat';
sample_size_fisher_file = 'data/training/SUNRGBD/bedroom_sample_sizes_fisher.mat';

%smaller objects
pairwise_location_file_SUNRGBD_v2 = 'data/training/SUNRGBD/bedroom_pairwise_locations_v2.mat';
gmm_location_file_SUNRGBD_v2 = 'data/training/SUNRGBD/gmm_pairwise_location_fisher_v2.mat';
gmm_weights_file_SUNRGBD_v2 = 'data/training/SUNRGBD/gmm_weights_fisher_v2.mat';
sample_size_fisher_file_v2 = 'data/training/SUNRGBD/bedroom_sample_sizes_fisher_v2.mat';