function [ scaled_models ] = scale_models( scene, all_valid_sizes )
%SCALE_MODELS computes the reasonable scale for each model based on the
%prior

scaled_models = scene;
for mid = 1:length(scaled_models)
    model = scene(mid);
    orig_diag = norm(model.dims);
    prior_avg_diag = all_valid_sizes(model.obj_type).avg_diag;
    scale = prior_avg_diag / orig_diag;
    scaled_models(mid).scale = scale;
end

end

