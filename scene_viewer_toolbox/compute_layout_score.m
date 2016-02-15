function [layout_score, object_score] = compute_layout_score( scene, object_id )
%COMPUTE_LAYOUT_SCORE computes the layout score for an input scene, based
%on the formulation in the example-based scene synthesis paper (Fisher et
%al.)

Consts_fisher;
load(estimated_PDF_support_file, 'estimated_PDFs');

layout_score = 0;
object_score = 0;
for oid = 1:length(scene)
%     obj_score = 0;
    
    obj = scene(oid);
    if obj.obj_type == get_object_type_bedroom({'room'})
        continue
    end
%     obj_center = mean(obj.corners);
%     obj_cos = obj.transform(1,1) / obj.scale;
%     obj_sin = obj.transform(1,2) / obj.scale;
%     obj_orient = [obj_sin, obj_cos];
    
    %pairwise score
    pairwise_score = compute_pairwise_score( scene, obj, oid );
    
    %support score
    parent_row = structfind(scene, 'identifier', obj.supporter_id);
    if isempty(parent_row) %no support -> room itself
        support_score = 1;
    else
        parent = scene(parent_row);
        x_rng = max(parent.corners(1:4,1)) - min(parent.corners(1:4,1));
        y_rng = max(parent.corners(1:4,2)) - min(parent.corners(1:4,2));
        area = sqrt(x_rng * y_rng);
        height = min(obj.corners(:,3));
        f_area = estimated_PDFs(obj.obj_type).estimated_PDF(1,1);
        f_height = estimated_PDFs(obj.obj_type).estimated_PDF(2,1);
        support_score = pdf(f_area, area) + pdf(f_height, height);
    end
    
    %collision penalty
    collision_penalty = compute_collision_penalty( scene, obj, oid );
    
    %proximity penalty
    proximity_penalty = compute_proximity_penalty( scene, obj, oid );
    
    %overhang penalty
    if isempty(parent_row)
        overhang_penalty = 1;
    else
        overhang_penalty = compute_overhang_penalty( obj, parent );
    end
    
    obj_score = pairwise_score * support_score * collision_penalty * ...
        proximity_penalty * overhang_penalty;
    
    if oid == object_id
        object_score = obj_score;
    end
    
    %hard constraints
    if obj_score == 0
        layout_score = 0;
        return
    end
    
    layout_score = layout_score + obj_score;
end

end

