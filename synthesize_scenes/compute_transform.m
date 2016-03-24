function [ final_scene ] = compute_transform( final_scene )
%COMPUTE_TRANSFORM

epsilon = 0.0001;

for oid = 1:length(final_scene)
%     if final_scene(oid).obj_type == 29
%         scale = final_scene(oid).scale;
%         orient = final_scene(oid).orientation;
%         cos_theta = orient(2) / norm(orient);
%         sin_theta = orient(1) / norm(orient);
%         trans = [scale(1)*cos_theta scale(1)*sin_theta 0 0; ...
%                 -scale(2)*sin_theta scale(2)*cos_theta 0 0; ...
%                 0 0 scale(3) 0; 0 0 0 1];
%         final_scene(oid).transform = trans;
%         continue
%     end
    
%     ind = structfind(model_BBs_dims, 'modelname', final_scene(oid).modelname);
    orig_BB = final_scene(oid).BB;
    curr_corners = final_scene(oid).corners;
    
    orig_points = [orig_BB(1,1), orig_BB(2,1), orig_BB(2,1), orig_BB(1,1); ...
                   orig_BB(1,2), orig_BB(1,2), orig_BB(2,2), orig_BB(2,2); ...
                   orig_BB(2,3), orig_BB(2,3), orig_BB(2,3), orig_BB(2,3); ...
                   1,1,1,1];
    curr_points = [curr_corners(5:8,:)'; 1,1,1,1];
    
%     r = (curr_BB(2,:) - curr_BB(1,:)) ./ (orig_BB(2,:) - orig_BB(1,:));
%     t = curr_BB(1,:) - r .* orig_BB(1,:);
    
%     transform = [r(1) 0 0 0; 0 r(2) 0 0; 0 0 r(3) 0; t 1];
%     transform = curr_points \ orig_points;
    s = final_scene(oid).scale;
    orient = final_scene(oid).orientation;
    cos_theta = orient(2) / norm(orient);
    sin_theta = orient(1) / norm(orient);
    
    if abs(cos_theta - 0) < epsilon
        temp = s(1);
        s(1) = s(2);
        s(2) = temp;
    end
    
    r = [s(1)*cos_theta s(1)*sin_theta 0;...
        -s(2)*sin_theta s(2)*cos_theta 0;...
        0 0 s(3)];
    curr_center = mean(curr_corners);
    orig_center = (orig_BB(2,:) + orig_BB(1,:)) / 2;
%     t = curr_points(1:3,1) - r * orig_points(1:3,1);
    t = curr_center' - r * orig_center';
    t = [t; 1];
    rotation = [r; 0 0 0];
    transform = [rotation, t];
    final_scene(oid).transform = transform';
end

end

