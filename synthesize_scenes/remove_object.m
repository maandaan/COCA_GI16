function scene = remove_object( scene, missed_obj )
%REMOVE_OBJECT removes an object and updates the scene in the case of not
%being able to optimize its placement

missed_row = structfind(scene, 'identifier', missed_obj.identifier);
if isempty(missed_row)
    return
end

scene = [scene(1:missed_row-1); scene(missed_row+1:end)];
 
%update the support for the missed object's children
children_rows = structfind(scene, 'supporter_id', missed_obj.identifier);
if ~isempty(children_rows)
    for cid = 1:length(children_rows)
        scene(children_rows(cid)).supporter_id = [];
        scene(children_rows(cid)).supporter = [];
        scene(children_rows(cid)).supporter_category = [];
        scene(children_rows(cid)).support_type = [];
    end
    scene = update_support_surfaces(scene);
end

scene = update_relations( scene, missed_obj );
fprintf('Successfully removed %s!\n', missed_obj.identifier);

%remove children of the missed object, if we were not able to find another
%supporting surface for them
count = 1;
while count <= length(scene)
    if ~isempty(scene(count).supporter)
        count = count + 1;
        continue
    end
    
    missed_obj = scene(count);
    scene = [scene(1:count-1); scene(count+1:end)];
    scene = update_relations( scene, missed_obj );
    fprintf('Successfully removed %s!\n', missed_obj.identifier);
end

end

