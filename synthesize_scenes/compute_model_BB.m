function [ scene ] = compute_model_BB( scene, models_dir )
%COMPUTE_MODEL_BB computes the bounding box and size for selected models to
%be inserted in the scene.

%bounding box format: [x_min y_min z_min; x_max y_max z_max]

model_num = length(scene);
% scene(1).BB = [];
% scene(1).dims = [];
% scene = repmat(struct('obj_type',[], 'modelname', [], 'BB', [], 'dims', []), model_num, 1);

for mid = 1:model_num
    if isfield(scene, 'BB') && ~isempty(scene(mid).BB)
        continue
    end
    
    filename = scene(mid).modelname;
    model = read_wobj([models_dir filename '.obj']);
%     scene(mid).obj_type = scene(mid).obj_type;
%     scene(mid).modelname = filename;
    scene(mid).BB = [min(model.vertices,[],1); max(model.vertices,[],1)];
    scene(mid).dims = scene(mid).BB(2,:) - scene(mid).BB(1,:);
end

end

