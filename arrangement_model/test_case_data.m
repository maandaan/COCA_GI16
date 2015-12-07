% This script produces a test case for optimizing the arrangement of all
% objects in the scene.

out_dir = 'data/test_cases/';
out_file = [out_dir 'bedroom_arrangement_model_test.mat'];
mkdir(out_dir);

scene = struct('type', [], 'type_name', [], 'corners', [], 'orientation', []);
new_objects = struct('type', [], 'type_name', [], 'corners', [], 'orientation', []);

align_ind = [1 2 3; 4 2 3; 4 5 3; 1 5 3; 1 2 6; 4 2 6; 4 5 6; 1 5 6];

%room
scene.type = 29;
scene.type_name = 'room';
corners_bnd = [0 0 0 500 500 300];
scene.corners = corners_bnd(align_ind);
scene.orientation = [1,1,0];

%bed
cat = 'bed';
new_objects.type = get_object_type_bedroom({cat});
new_objects.type_name = cat;
corners_bnd = [300 200 0 500 300 50];
new_objects.corners = corners_bnd(align_ind);
new_objects.orientation = [-1,0,0];

%nightstand
cat = 'nightstand';
new_objects(2).type = get_object_type_bedroom({cat});
new_objects(2).type_name = cat;
corners_bnd = [220 230 0 280 270 50];
new_objects(2).corners = corners_bnd(align_ind);
new_objects(2).orientation = [-1,0,0];

%desk
cat = 'desk';
new_objects(3).type = get_object_type_bedroom({cat});
new_objects(3).type_name = cat;
corners_bnd = [200 220 0 300 280 80];
new_objects(3).corners = corners_bnd(align_ind);
new_objects(3).orientation = [0,1,0];

save(out_file, 'scene', 'new_objects');

