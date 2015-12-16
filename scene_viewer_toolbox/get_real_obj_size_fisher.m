function dims = get_real_obj_size_fisher( scene3d, objid, modelBB_file )
%GET_REAL_OBJ_SIZE_FISHER tries to get the real size of objects in a
%typical scene in Fisher database so we can set others manually. (by Zeinab
%Sadeghipour)

% modelBB_file = 'data\fisher_bounding_boxes.mat';

object = scene3d.objects(objid);
load(modelBB_file);

modelname = object.mid;
scale = object.scale;

bb_index = structfind(bounding_box, 'name', modelname);
if isempty(bb_index)
    dims = [0 0 0];
end

bb = bounding_box(bb_index).bb;
bb_dims = bb(2,:) - bb(1,:);
dims = bb_dims * scale;

end

