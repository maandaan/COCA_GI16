function [ scaled_models ] = scale_models( scene, sample_sizes )
%SCALE_MODELS computes the reasonable scale for each model based on the
%prior

scaled_models = scene;
for mid = 1:length(scaled_models)
    model = scene(mid);
    prior_dims = sample_sizes(model.obj_type).fisherDB_dims;
    scale = prior_dims ./ model.dims;
%     orig_diag = norm(model.dims);
%     prior_avg_diag = sample_sizes(model.obj_type).avg_diag;
%     scale = prior_avg_diag / orig_diag;
    scaled_models(mid).scale = scale;
end

end

