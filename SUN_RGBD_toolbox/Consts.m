% edge and factor types
pedge = 1; %proximity

suppedge_below = 2; %support
suppedge_behind = 3;

symm_g = 4; %in a symmetry group
symm_resp = 5; %symmetric with respect to (directed from the object in the symmetry group to the other one, e.g. from the night stands to the bed)

perpendicular = 6; %two objects are perpendicular to each other
facing = 7; %two objects facing each other
same_dir = 8; %two objects with same orientation vectors

occurrence = 9;

% filenames
% sunrgbdmeta_file = '../SUNRGBD/code/SUNRGBDtoolbox/Metadata/SUNRGBDMeta.mat';
sunrgbdmeta_file = 'SUNRGBDMeta.mat';
valid_scene_indices = 'data/training/SUNRGBD/bedroom_valid_scenes.mat';
mapping_file = 'data/training/SUNRGBD/scene_name_type.mat';
mapping_nodes_names_file = 'data/training/SUNRGBD/bedroom_mapping_nodes_names_BN.mat';
support_relations_file = 'data/training/SUNRGBD/bedroom_support_relations.mat';
focals_file = 'data/training/SUNRGBD/bedroom_focal_joining_results.mat';
symmetry_relations_file = 'data/training/SUNRGBD/bedroom_symmetry_relations.mat';
orientation_relations_file = 'data/training/SUNRGBD/bedroom_special_orientation_relations.mat';
global_scene_graph_file = 'data/training/SUNRGBD/bedroom_global_scene_graph.mat';
instance_freq_file = 'data/training/SUNRGBD/bedroom_instance_frequency.mat';
size_data_file = 'data/training/SUNRGBD/bedroom_valid_sizes.mat';
gmm_file = 'data/training/SUNRGBD/bedroom_gmm_spatial_relations';
kmeans_file = 'data/training/SUNRGBD/bedroom_kmeans_spatial_relations';
co_occurrence_file = 'data/training/SUNRGBD/bedroom_co_occurrence';
pairwise_locations_file = 'data/training/SUNRGBD/bedroom_pairwise_locations.mat';
global_factor_graph_file = 'data/training/SUNRGBD/bedroom_global_factor_graph.mat';
% global_factor_graph_file = 'data/training/SUNRGBD/bedroom_global_factor_graph_alloff.mat';
sample_size_fisher_file = 'data/training/SUNRGBD/bedroom_sample_sizes_fisher.mat';
sidetoside_relations_file = 'data/training/SUNRGBD/bedroom_sidetoside_relations.mat';
sidetoside_constraints_file = 'data/training/SUNRGBD/bedroom_sidetoside_constraints.mat';

%scene database directories and files
% scene_db_dir = 'data/databaseFull_fisher_Stanford/';
scene_db_dir = 'data/Synthesized Scenes/';
models_dir = [scene_db_dir 'models/'];
scenes_dir = [scene_db_dir 'scenes/'];
modelnames_file = [scene_db_dir 'fields/models.txt'];
% modelnames_file = [scene_db_dir 'fields/names.txt'];

% information
scene_type = 'bedroom';
bedroom_support_scene_size = 383; % size of bedroom scenes in NYUv2 which has support labels

