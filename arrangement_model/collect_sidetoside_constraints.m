function sidetoside_constraints = collect_sidetoside_constraints
%COLLECT_SIDETOSIDE_CONSTRAINTS collects reliable side-to-side relations as
%constraints for arranging objects

Consts;
load(sidetoside_relations_file_v2, 'sidetoside_rels_matrix');
c = struct('first_type', [], 'second_type', [], ...
    'first_side', [], 'second_side', [], 'avg_dist', [], 'frequency', []);
count = 0;
cat_count = size(sidetoside_rels_matrix, 1);
thresh = 50;
wall_type = get_object_type_bedroom({'wall'});

for i = 1:cat_count - 2
%     if ismember(i, [3,8,13,28])
%         continue
%     end
    
    %relation with walls
    walls_rel = sidetoside_rels_matrix(wall_type,i).side_rels;
    if length(walls_rel) >= thresh
        for side = 1:4
            r = find(walls_rel(:,2) == side);
            if length(r) < thresh %filtering reliable relations
                continue
            end
            
            count = count + 1;
            c(count).first_type = wall_type;
            c(count).second_type = i;
            c(count).first_side = 1;
            c(count).second_side = side;
            c(count).avg_dist = mean(walls_rel(r,3));
            c(count).frequency = length(r);
        end
    end
    
    %relations with other objects
    for j = i+1:cat_count - 2
        this_rel = sidetoside_rels_matrix(i,j).side_rels;
        if isempty(this_rel) 
%             || ismember(j, [3,8,13,28])
            continue
        end
        
        %filtering reliable relations
        if length(this_rel) < thresh
            continue
        end
        
        for side1 = 1:4
            for side2 = 1:4
                side1_rows = find(this_rel(:,1) == side1);
                side2_rows = find(this_rel(:,2) == side2);
                r = intersect(side1_rows, side2_rows);
                
                if length(r) < thresh %filtering reliable relations
                    continue
                end
                
                count = count + 1;
                c(count).first_type = i;
                c(count).second_type = j;
                c(count).first_side = side1;
                c(count).second_side = side2;
                c(count).avg_dist = mean(this_rel(r,3));
                c(count).frequency = length(r);
            end
        end
    end
end

sidetoside_constraints = c;
save(sidetoside_constraints_file, 'sidetoside_constraints');

end

