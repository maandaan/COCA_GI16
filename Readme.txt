Implementation details (started from Oct 13, 2015)
SUN_RGBD_toolbox:
Notice: These are all for bedrooms, update for each scene type.
	1. run get_mapping_scene_name_type (script for putting the name of the scene file and scene type in scene.txt in one place)
	2. run get_mapping_object_category_id (function for getting all the object categories available in a specific scene type)
		- then I polished the results to updata get_object_type_bedroom.m
	3. run count_categories (function for computing how many times objects co-occur and also how many instances of each category occurrs)
	4. run gather_pairwise_relations_exact_location (function for gathering the location and orientation relations between pairs of objects)
        - special orientations: 1 -> 90deg, 2 -> 180deg (facing), 3 -> 0deg
    4.1. run construct_special_orientation_matrix
	5. run collect_support_relations_NYUv2
    6. run construct_symmetric_matrix




    6. run count_observations_BN ( to get raw data for BN), then run prepare_data_BN_learning (to make the right format for the data to feed into the BN)