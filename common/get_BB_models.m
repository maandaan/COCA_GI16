function get_BB_models( models_dir, out_file )
% This function computes the bounding boxes for models in the *model_dir*
% and saves the results in a .mat file. (by Zeinab Sadeghipour)

% models_dir = 'data/databaseFull_fisher_Stanford/models/'
% out_dir = 'data/bounding_boxes.mat'

model_files = dir( fullfile(models_dir,'*.obj') );
models_num = size(model_files, 1);
%bounding box format: [x_min y_min z_min; x_max y_max z_max]
bounding_box = repmat(struct('name',[],'bb',[]), models_num, 1);

for mid = 1:models_num
    model = read_wobj([models_dir model_files(mid).name]);
    [~, bounding_box(mid).name, ~] = fileparts(model_files(mid).name);
    bounding_box(mid).bb = [min(model.vertices,[],1); max(model.vertices,[],1)];
end

save(out_file, 'bounding_box');

end

