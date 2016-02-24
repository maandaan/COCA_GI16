function scene = update_relations( scene, missed_obj )
%UPDATE_RELATIONS Summary of this function goes here
%   Detailed explanation goes here

for oid = 1:length(scene)
    obj = scene(oid);
    
    %symmetry group
    symm_group_ind = find( ismember(obj.symm_group_id, missed_obj.identifier) );
    if ~isempty( symm_group_ind )
        if length(obj.symm_group_id) == 2 %by removing the object, there's no more objects in the group
            obj.symm_group_id = [];
            obj.symm_ref_id = [];
        else
            obj.symm_group_id = {obj.symm_group_id(1:symm_group_ind-1), ...
                                 obj.symm_group_id(symm_group_ind+1:end)};
        end
    end
    
    %symmetry reference
    if strcmp(obj.symm_ref_id, missed_obj.identifier)
        obj.symm_ref_id = [];
    end
    
    %orientation relations
    orientation_row = structfind(obj.orientation_rels, 'pair_obj_id', missed_obj.identifier);
    if ~isempty(orientation_row)
        obj.orientation_rels = [obj.orientation_rels(1:orientation_row - 1); ...
                                obj.orientation_rels(orientation_row + 1:end)];
    end
    
    scene(oid) = obj;
end

end

