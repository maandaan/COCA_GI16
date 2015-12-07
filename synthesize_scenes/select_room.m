function [ room ] = select_room( models_dir, all_valid_sizes )
%SELECT_ROOM randomly selects one of the available room layouts for the new
%scene.

model_files = dir(models_dir);
room_layouts_ind = [];

for fid = 1:length(model_files)
    filename = model_files(fid).name;
    if isempty(strfind(filename, 'room')) || isempty(strfind(filename, '.obj'))
        continue
    end
    room_layouts_ind = [room_layouts_ind, fid];
end

% rand_ind = randi(length(room_layouts_ind));
room_name = model_files(room_layouts_ind(3)).name;
room_name_split = strsplit(room_name, '.');

align_ind = [1 2 3; 4 2 3; 4 5 3; 1 5 3; 1 2 6; 4 2 6; 4 5 6; 1 5 6];

%construct the empty scene
model = read_wobj([models_dir room_name]);
room.type = 29;
room.type_name = 'room';
room.modelname = room_name_split{1};

corners_bnd = [min(model.vertices,[],1); max(model.vertices,[],1)];
dims = corners_bnd(2,:) - corners_bnd(1,:);
room_diag = norm(dims);
ind = get_object_type_bedroom({'room'});
avg_diag = all_valid_sizes(ind).avg_diag;
scale = avg_diag / room_diag;
scaled_dims = dims * scale;
scaled_corners = [0 0 0 scaled_dims];

room.corners = scaled_corners(align_ind);
room.scale = scale;
room.orientation = [1,0,0];

% room.pindex = -1; %parent index
room.ptype = -1; %parent object type
room.children = [];

end

