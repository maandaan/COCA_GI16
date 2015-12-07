function [ pruned_scene ] = prune_models( scene )
%PRUNE_MODELS removes objects from the scene for which we could not find a
%suitable 3D model. For now, I assumed that this does not happen for major
%objects, like supporting surfaces or symmetry references. 

pruned_scene = [];

for oid = 1:length(scene)
    if isempty(scene(oid).modelname)
        continue
    end
    pruned_scene = [pruned_scene; scene(oid)];
end

end

