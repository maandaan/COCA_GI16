% This script is for collecting data about valid sizes and dimension ratios
% from FurnitureData.csv from the paper "On Being the Right Scale", Savva
% et al. 2014.
%
% by Zeinab Sadeghipour

% if the source is a csv file
source_1_filename = 'data/training/furnitureData.csv';
[name objtype_str width height len] = csvimport(source_1_filename, 'columns', {'name','furnitureType','itemWidth','itemHeight','itemLength'});
objects_valid_sizes = collect_size_ratio(name, objtype_str, width, height, len, source_1_filename);

% aggregate information
% objtype_list = [{'bed'},{'bedside'},{'chair'},{'painting'},{'door'},{'mirror'},{'cabinet'},{'tv'},...
%                 {'desk'},{'window'},{'wardrobe'},{'sofa'},{'cushion'},{'bench'},{'shelf'}];
objtype_list = get_object_type_bedroom(1:54);
all_valid_sizes = repmat(struct('objtype_str',[],'objtype',[], 'diag_sum',0, 'instance_count',0, 'avg_diag', 0),...
    length(objtype_list), 1);

for oid = 1:size(objects_valid_sizes, 1)
%     obj_ind = find(strcmpi(objects_valid_sizes(oid).objtype_str, objtype_list));
    if isempty(objects_valid_sizes(oid).objtype_str)
        continue
    end
    obj_ind = get_object_type_bedroom({objects_valid_sizes(oid).objtype_str});
    
    object = objects_valid_sizes(oid);
    diag = norm([object.width, object.height, object.len]);
    if isnan(diag)
        continue
    end
    all_valid_sizes(obj_ind).diag_sum = all_valid_sizes(obj_ind).diag_sum + diag;
    all_valid_sizes(obj_ind).instance_count = all_valid_sizes(obj_ind).instance_count + 1;
%     
%     if object.width < all_valid_sizes(obj_ind).min_width
%         all_valid_sizes(obj_ind).min_width = object.width;
%     end
%     if object.width > all_valid_sizes(obj_ind).max_width
%         all_valid_sizes(obj_ind).max_width = object.width;
%     end
%     
%     if object.height < all_valid_sizes(obj_ind).min_height
%         all_valid_sizes(obj_ind).min_height = object.height;
%     end
%     if object.height > all_valid_sizes(obj_ind).max_height
%         all_valid_sizes(obj_ind).max_height = object.height;
%     end
%     
%     if object.len < all_valid_sizes(obj_ind).min_len
%         all_valid_sizes(obj_ind).min_len = object.len;
%     end
%     if object.len > all_valid_sizes(obj_ind).max_len
%         all_valid_sizes(obj_ind).max_len = object.len;
%     end
%     
%     if object.wh_ratio < all_valid_sizes(obj_ind).min_wh_ratio
%         all_valid_sizes(obj_ind).min_wh_ratio = object.wh_ratio;
%     end
%     if object.wh_ratio > all_valid_sizes(obj_ind).max_wh_ratio
%         all_valid_sizes(obj_ind).max_wh_ratio = object.wh_ratio;
%     end
%         
%     if object.hl_ratio < all_valid_sizes(obj_ind).min_hl_ratio
%         all_valid_sizes(obj_ind).min_hl_ratio = object.hl_ratio;
%     end
%     if object.hl_ratio > all_valid_sizes(obj_ind).max_hl_ratio
%         all_valid_sizes(obj_ind).max_hl_ratio = object.hl_ratio;
%     end
%     
%     if object.wl_ratio < all_valid_sizes(obj_ind).min_wl_ratio
%         all_valid_sizes(obj_ind).min_wl_ratio = object.wl_ratio;
%     end
%     if object.wl_ratio > all_valid_sizes(obj_ind).max_wl_ratio
%         all_valid_sizes(obj_ind).max_wl_ratio = object.wl_ratio;
%     end
%     
%     if object.diag < all_valid_sizes(obj_ind).min_diag
%         all_valid_sizes(obj_ind).min_diag = object.diag;
%     end
%     if object.diag > all_valid_sizes(obj_ind).max_diag
%         all_valid_sizes(obj_ind).max_diag = object.diag;
%     end
%     
%     if object.diag_ratio < all_valid_sizes(obj_ind).min_diag_ratio
%         all_valid_sizes(obj_ind).min_diag_ratio = object.diag_ratio;
%     end
%     if object.diag_ratio > all_valid_sizes(obj_ind).max_diag_ratio
%         all_valid_sizes(obj_ind).max_diag_ratio = object.diag_ratio;
%     end
end

all_valid_sizes = collect_size_info(all_valid_sizes, 'bedroom');

for oid = 1:length(all_valid_sizes)
    all_valid_sizes(oid).objtype = oid;
    all_valid_sizes(oid).objtype_str = get_object_type_bedroom(oid);
    if all_valid_sizes(oid).instance_count > 0
        all_valid_sizes(oid).avg_diag = all_valid_sizes(oid).diag_sum / all_valid_sizes(oid).instance_count;
    end
end

valid_sizes_file = 'data/training/SUNRGBD/bedroom_valid_sizes.mat';
save(valid_sizes_file, 'all_valid_sizes');

% for oid = 1:size(objtype_list,2)
%     all_valid_sizes(oid).objtype_str = objtype_list(oid);
%     all_valid_sizes(oid).objtype = get_object_type(objtype_list(oid));
%     
%     all_valid_sizes(oid).min_width = realmax;
%     all_valid_sizes(oid).max_width = -realmax;
%     all_valid_sizes(oid).min_height = realmax;
%     all_valid_sizes(oid).max_height = -realmax;
%     all_valid_sizes(oid).min_len = realmax;
%     all_valid_sizes(oid).max_len = -realmax;
%     
%     all_valid_sizes(oid).min_wh_ratio = realmax;
%     all_valid_sizes(oid).max_wh_ratio = -realmax;
%     all_valid_sizes(oid).min_hl_ratio = realmax;
%     all_valid_sizes(oid).max_hl_ratio = -realmax;
%     all_valid_sizes(oid).min_wl_ratio = realmax;
%     all_valid_sizes(oid).max_wl_ratio = -realmax;
%     
%     all_valid_sizes(oid).min_diag = realmax;
%     all_valid_sizes(oid).max_diag = -realmax;
%     all_valid_sizes(oid).min_diag_ratio = realmax;
%     all_valid_sizes(oid).max_diag_ratio = -realmax;
% end
% 
% 
% 
% % data cleansing
% for tid = 1:size(all_valid_sizes,1)
%     if all_valid_sizes(tid).min_wh_ratio > 10000
%         all_valid_sizes(tid).min_wh_ratio = 0.05;
%     end
%     if all_valid_sizes(tid).max_wh_ratio < 0
%         all_valid_sizes(tid).max_wh_ratio = 5;
%     end
% end
