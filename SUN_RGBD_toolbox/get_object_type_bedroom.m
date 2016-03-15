function [ output, cat_count ] = get_object_type_bedroom( input )
%You can either input an object category name and get the id or do the
%reverse. (by Zeinab Sadeghipour)
% try
%     I = isa(input, 'cell') & isa(input{1}, 'char');
% catch
%     fprintf('');
% end

load('data/training/SUNRGBD/bedroom_object_category_id_all.mat', 'map_object_category_id');
num_rows = length(map_object_category_id);
max_cat_id = map_object_category_id(num_rows).category_id;
cat_count = max_cat_id + 2; %one for room, one for other
output = [];

if isa(input, 'cell') && isa(input{1}, 'char')
    output = zeros(length(input),1);
    for i = 1:length(input)
        switch input{i}
            case {'picture', 'poster','wallframe','wall_frame', 'map', 'walldecor', ...
                    'portrait','wall decoration', 'walldisplay', 'pictures', 'decor'}
                category = 'painting';
            case {'bedside','beside','nightstand', 'night stand'}
                category = 'night_stand';
            case {'television'}
                category = 'tv';
            case {'window', 'window_glass', 'glasswindow'}
                category = 'glass_window';
            case {'recliner', 'sofachair'}
                category = 'sofa_chair';
            case {'futon'}
                category = 'sofa';
            case {'trash can','garbagebin','recycle_bin','recyclebin','garbage bin'}
                category = 'garbage_bin';
            case {'aircon', 'airconditioner','air conditioner'}
                category = 'air_conditioner';
            case {'bookshelf','mini_shelf','shelves'}
                category = 'shelf';
            case {'endtable'}
                category = 'table';
            case {'plastic_bowl'}
                category = 'bowl';
            case {'bulletinboard'}
                category = 'bulletin_board';
            case {'carrybag','attachecase','backpack', 'messengerbag', 'back_pack', 'bags', 'bagpack'}
                category = 'bag';
            case {'stuffed_toy','stufftoys','stuffedtoy','doll', 'toyhourse', ...
                    'stuffed animal','puppy toy', 'miniaturehouse', ...
                    'toy_train', 'toy_car', 'figurine', 'toys'}
                category = 'toy';
            case {'plastic_bottle', 'plastic bottle', 'water_bottle'}
                category = 'bottle';
            case {'luggage', 'suitcase','travellingbag', 'travel bag', 'suitscase'}
                category = 'suits_case';
            case {'laundry_rack','clothingrack'}
                category = 'clothing_rack';
            case {'books'}
                category = 'book';
            case {'cup'}
                category = 'mug';
            case {'blanket','comforter','bed_sheet','bedsheet','mattress'}
                category = 'bedding';
            case {'dressermirror','dresser_mirror'}
                category = 'dresser';
            case {'flower_vase'}
                category = 'vase';
            case {'floor mat', 'mat', 'rubbermat', 'rubber_mat'}
                category = 'rug';
            case {'clock', 'alarm', 'alarm clock','alarmclock'}
                category = 'alarm_clock';
            case {'plantpot','plant','plants', 'cactus'}
                category = 'plant_pot';
            case {'key_board'}
                category = 'keyboard';
            case {'sandals', 'slipper', 'slippers', 'shoes', 'rubber_shoes'}
                category = 'shoe';
            case {'tissue', 'tissue box', 'tissuebox', 'tissue_paper'}
                category = 'tissue_box';
            case {'remote', 'remotecontrol', 'remote control'}
                category = 'remote_control';
            case {'telephone', 'cell_phone'}
                category = 'phone';
            case {'blinds', 'venetianblinds'}
                category = 'curtain';
            case {'diplomas'}
                category = 'diploma';
            case {'electricfan', 'fan'}
                category = 'electric_fan';
            case {'towel'}
                category = 'towels';
            case {'papers'}
                category = 'paper';
            case {'containers'}
                category = 'container';
            case {'plastic_basket'}
                category = 'basket';
            case {'plastic_box'}
                category = 'box';
            case {'crash_helmet'}
                category = 'helmet';
            case {'pants', 'coat', 'sweater'}
                category = 'clothes';
            case {'laundrybasket'}
                category = 'laundry_basket';
            case {'magazines'}
                category = 'magazine';
            case {'frames'}
                category = 'pictureframes';
            case {'ironingboard'}
                category = 'ironboard';
            case {'file_cabinet'}
                category = 'cabinet';
            case {'jar'}
                category = 'jars';
            case {'hangers'}
                category = 'hanger';
            otherwise
                category = input{i};
        end
        
        cat_row = structfind(map_object_category_id, 'category_name', category);
        if isempty(cat_row)
            if strcmp(category, 'room')
                output(i) = max_cat_id + 1;
            elseif strcmp(category, 'floor')
                output(i) = max_cat_id + 3;
            elseif strcmp(category, 'wall')
                output(i) = max_cat_id + 4;
            else
                output(i) = max_cat_id + 2;
            end
        else
            output(i) = map_object_category_id(cat_row).category_id;
        end
               
    end
    
elseif isa(input, 'numeric')
    output = cell(length(input),1);
    for i = 1:length(input)
        cat_row = structfind(map_object_category_id, 'category_id', input(i));
        if isempty(cat_row)
            if input(i) == max_cat_id + 1
                output{i} = 'room';
            elseif input(i) == max_cat_id + 3
                output{i} = 'floor';
            elseif input(i) == max_cat_id + 4
                output{i} = 'wall';
            else
                fprintf('Sorry! not found the category id!\n'); 
            end
            continue
        end
        output{i} = map_object_category_id(cat_row).category_name;
    end
end

% if isa(input, 'cell') && isa(input{1}, 'char')
%     output = zeros(length(input),1);
%     for i = 1:length(input)
%         switch input{i}
%             case {'painting', 'picture', 'poster','wallframe','wall_frame','portrait','wall decoration'}
%                 output(i) = 1;
%             case {'bedside','beside','night_stand','nightstand', 'night stand'}
%                 output(i) = 2;
%             case {'door','doorway'}
%                 output(i) = 3;
%             case {'mirror'}
%                 output(i) = 4;
%             case {'cabinet', 'drawer'}
%                 output(i) = 5;
%             case {'tv','television'}
%                 output(i) = 6;
%             case {'desk'}
%                 output(i) = 7;
%             case {'window'}
%                 output(i) = 8;
%             case {'bed','bunk_bed','bunk bed'}
%                 output(i) = 9;
%             case {'chair','stool'}
%                 output(i) = 10;
%             case {'wardrobe','closet','armoire'}
%                 output(i) = 11;
%             case {'sofa', 'sofa_chair'}
%                 output(i) = 12;
%             case {'cushion','pillow'}
%                 output(i) = 13;
%             case {'tv stand','tv_stand'}
%                 output(i) = 14;
%             case {'bench'}
%                 output(i) = 15;
%             case {'windowsill'}
%                 output(i) = 16;
%             case {'trash can','basket','garbage_bin','garbagebin','recycle_bin','recyclebin','garbage bin'}
%                 output(i) = 17;
%             case {'refrigerator'}
%                 output(i) = 18;
%             case {'column','pillar'}
%                 output(i) = 19;
%             case {'aircon', 'air_conditioner','airconditioner','air conditioner'}
%                 output(i) = 20;
%             case {'stair'}
%                 output(i) = 21;
%             case {'washtub'}
%                 output(i) = 22;
%             case {'bedhead'}
%                 output(i) = 23;
%             case {'microwave oven','microwave'}
%                 output(i) = 24;
%             case {'heater'}
%                 output(i) = 25;
%             case {'box','cuboid','hamper'}
%                 output(i) = 26;
%             case {'shelf','bookshelf','mini_shelf','shelves'}
%                 output(i) = 27;
%             case {'room'}
%                 output(i) = 29;
%             case {'computer','monitor','laptop'}
%                 output(i) = 30;
%             case {'lamp','light'}
%                 output(i) = 31;
%             case {'table','coffee_table','coffeetable'}
%                 output(i) = 32;
%             case {'ottoman'}
%                 output(i) = 33;
%             case {'endtable','end_table','sidetable','side_table'}
%                 output(i) = 34;
%             case {'bowl'}
%                 output(i) = 35;
%             case {'bulletin_board','bulletinboard'}
%                 output(i) = 36;
%             case {'fridge'}
%                 output(i) = 37;
%             case {'bag','carrybag','attachecase','backpack'}
%                 output(i) = 38;
%             case {'toy','stuffed_toy','stuffedtoys','stuffedtoy','doll','stuffed animal','puppy toy'}
%                 output(i) = 39;
%             case {'mouse'}
%                 output(i) = 40;
%             case {'mouse_pad'}
%                 output(i) = 41;
%             case {'bottle', 'plastic_bottle'}
%                 output(i) = 42;
%             case {'luggage', 'suits_case','suitcase','travellingbag', 'travel bag'}
%                 output(i) = 43;
%             case {'shoe_rack','rack'}
%                 output(i) = 44;
%             case {'book','books'}
%                 output(i) = 45;
%             case {'mug','cup'}
%                 output(i) = 46;
%             case {'blanket','bedding','comforter','bed_sheet','bedsheet','sheet','sheets'}
%                 output(i) = 47;
%             case {'printer'}
%                 output(i) = 48;
%             case {'dresser','dressermirror','dresser_mirror'}
%                 output(i) = 49;
%             case {'vase'}
%                 output(i) = 50;
%             case {'rug','floor mat'}
%                 output(i) = 51;
%             case {'clock'}
%                 output(i) = 52;
%             case {'plant_pot','plantpot','plant','plants'}
%                 output(i) = 53;
%             case {'keyboard','key_board'}
%                 output(i) = 54;
%             otherwise
%                 output(i) = 28;
%         end
%     end
%     
% elseif isa(input, 'numeric')
%     output = cell(length(input),1);
%     for i = 1:length(input)
%         switch input(i)
%             case 0
%                 output{i} = 'background';
%             case 1
%                 output{i} = 'painting';
%             case 2
%                 output{i} = 'bedside';
%             case 3
%                 output{i} = 'door';
%             case 4
%                 output{i} = 'mirror';
%             case 5
%                 output{i} = 'drawer';
%             case 6
%                 output{i} = 'tv';
%             case 7
%                 output{i} = 'desk';
%             case 8
%                 output{i} = 'window';
%             case 9
%                 output{i} = 'bed';
%             case 10
%                 output{i} = 'chair';
%             case 11
%                 output{i} = 'wardrobe';
%             case 12
%                 output{i} = 'sofa';
%             case 13
%                 output{i} = 'cushion';
%             case 14
%                 output{i} = 'tv stand';
%             case 15
%                 output{i} = 'bench';
%             case 16
%                 output{i} = 'windowsill';
%             case 17
%                 output{i} = 'trash can';
%             case 18
%                 output{i} = 'refrigerator';
%             case 19
%                 output{i} = 'column';
%             case 20
%                 output{i} = 'aircon';
%             case 21
%                 output{i} = 'stair';
%             case 22
%                 output{i} = 'washtub';
%             case 23
%                 output{i} = 'bedhead';
%             case 24
%                 output{i} = 'microwave oven';
%             case 25
%                 output{i} = 'heater';
%             case 26
%                 output{i} = 'cuboid';
%             case 27
%                 output{i} = 'shelf';
%             case 29
%                 output{i} = 'room';
%             case 30
%                 output{i} = 'computer';
%             case 31
%                 output{i} = 'lamp';
%             case 32
%                 output{i} = 'table';
%             case 33
%                 output{i} = 'ottoman';
%             case 34
%                 output{i} = 'side_table';
%             case 35
%                 output{i} = 'bowl';
%             case 36
%                 output{i} = 'bulletin_board';
%             case 37
%                 output{i} = 'fridge';
%             case 38
%                 output{i} = 'bag';
%             case 39
%                 output{i} = 'toy';
%             case 40
%                 output{i} = 'mouse';
%             case 41
%                 output{i} = 'mouse_pad';
%             case 42
%                 output{i} = 'bottle';
%             case 43
%                 output{i} = 'luggage';
%             case 44
%                 output{i} = 'rack';
%             case 45
%                 output{i} = 'book';
%             case 46
%                 output{i} = 'cup';
%             case 47
%                 output{i} = 'bedding';
%             case 48
%                 output{i} = 'printer';
%             case 49
%                 output{i} = 'dresser';
%             case 50
%                 output{i} = 'vase';
%             case 51
%                 output{i} = 'rug';
%             case 52
%                 output{i} = 'clock';
%             case 53
%                 output{i} = 'plant';
%             case 54
%                 output{i} = 'keyboard';
%             otherwise
%                 output{i} = 'other';
%         end
%     end
%     
% end

end

