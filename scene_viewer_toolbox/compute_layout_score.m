function score = compute_layout_score( scene )
%COMPUTE_LAYOUT_SCORE computes the layout score for an input scene, based
%on the formulation in the example-based scene synthesis paper (Fisher et
%al.)

Consts_fisher;
load(estimated_PDF_support_file, 'estimated_PDFs');

score = 0;
for oid = 1:length(scene)
    obj_score = 0;
    
    obj = scene(oid);
%     obj_center = mean(obj.corners);
%     obj_cos = obj.transform(1,1) / obj.scale;
%     obj_sin = obj.transform(1,2) / obj.scale;
%     obj_orient = [obj_sin, obj_cos];
    
    %pairwise score
    pairwise_score = compute_pairwise_score( scene, obj, oid );
    
    %support score
    parent = scene(obj.supporter_id);
    x_rng = max(parent.corners(1:4,1)) - min(parent.corners(1:4,1));
    y_rng = max(parent.corners(1:4,2)) - min(parent.corners(1:4,2));
    area = sqrt(x_rng * y_rng);
    height = min(obj.corners(:,3));
    f_area = estimated_PDFs(obj.obj_type).estimated_PDF(1,1);
    f_height = estimated_PDFs(obj.obj_type).estimated_PDF(2,1);
    support_score = pdf(f_area, area) + pdf(f_height, height);
    
    %collision penalty
    collision_penalty = compute_collision_penalty( scene, obj, oid );
    
    %proximity penalty
    
    %overhang penalty
    overhang_penalty = compute_overhang_penalty( obj, parent );
    
    score = score + obj_score;
end

end

