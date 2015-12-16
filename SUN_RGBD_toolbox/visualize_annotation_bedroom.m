% This script is implemented to visualize the annotation in RGBD dataset
% and saves them as figures.

Consts;

load(sunrgbdmeta_file, 'SUNRGBDMeta');
load(mapping_file, 'map_scene_name_type');
total_size = size(map_scene_name_type, 1);

result_dir = 'data\training\SUNRGBD\dataset_annotations_bedroom\';
mkdir(result_dir);

for mid = 1:total_size
    % check for the scene type
    if ~strcmp(map_scene_name_type(mid).sceneType, scene_type)
        continue
    end
    
    % get the room diagonal for normalizing distances
    room_corners = SUNRGBDMeta(:,mid).gtCorner3D;
    if isempty(room_corners)
        continue
    end
    
    gt3D = SUNRGBDMeta(:,mid).groundtruth3DBB;
    if isempty(gt3D)
        continue;
    end
    
    figure
    plot(room_corners(1,1:5), room_corners(2,1:5), 'r', 'LineWidth', 3);
    hold on
    
    no_objects = size(gt3D,2);
    for oid = 1:no_objects
        corners = get_corners_of_bb3d(gt3D(oid));
        plot(corners(1:5,1), corners(1:5,2), 'b', 'LineWidth', 2);
        center = mean(corners);
        text(center(1), center(2), gt3D(oid).classname, 'BackgroundColor', 'y');
        arrow(center(1:2), center(1:2) + gt3D(oid).orientation(1:2)./2);
        
        %test rectIntersect code
        if oid == 1
            rect1 = corners(1:4,1:2);
            next_corners = get_corners_of_bb3d(gt3D(oid+1));
            rect2 = next_corners(1:4,1:2);
            intersect = RectIntersect(rect1, rect2);
        end
    end
    
    print('-dpng', [result_dir 'scene_' num2str(mid)]);
    close
end