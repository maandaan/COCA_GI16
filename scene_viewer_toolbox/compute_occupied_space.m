function [ occupied_spaces ] = compute_occupied_space( scene3d, object_index )
% This function computes the occupied space of the object (object_index) by
% its children. (by Zeinab Sadeghipour)

object = scene3d.objects(object_index);
occupied_spaces = [];

if isempty(object.children)
    return;
end

children_num = length(object.children);
for cid = 1:children_num
    child = scene3d.objects(object.children(cid));
    sorted_bb = [min(child.world_bb) max(child.world_bb)];
    align_ind = [1 2 3; 4 2 3; 4 5 3; 1 5 3; 
                 1 2 6; 4 2 6; 4 5 6; 1 5 6];
    align = sorted_bb(align_ind);
    occupied_spaces = [occupied_spaces; align];
end

end

