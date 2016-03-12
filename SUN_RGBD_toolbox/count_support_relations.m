function [ support_matrix ] = count_support_relations( support_labels )
% This function is implemented to creat a 2D matrix of how many times each
% category is supported by another category. (by Zeinab Sadeghipour)

%output: support_matrix(i,j,k) = m; i.e. category i is supported by category
%j for the supporting type k (=1 -> below, =2 -> behind), for m times

[dummy, cat_count] = get_object_type_bedroom('');
categories_count = cat_count + 3; %one for floor, one for wall, one for ceiling(?)
support_matrix = zeros(categories_count, categories_count, 2);

for sid = 1:size(support_labels)
    support_rels = support_labels(sid).support_rel;
    
    for rid = 1:size(support_rels,2)
        
        supported = support_rels(rid).supported;
        supporting = support_rels(rid).supporting;
        type = support_rels(rid).type;
        
        if isempty(supported) || isempty(supporting) || isempty(type) ...
                || type < 1 || type > 2
            continue
        end

        if strcmp(supported{1}, 'floor')
            supported_cat = 55;
        elseif strcmp(supported{1}, 'wall')
            supported_cat = 56;
        elseif strcmp(supported{1}, 'ceiling')
            supported_cat = 57;
        else
            supported_cat = get_object_type_bedroom(supported);
            %just to check annotation
%             if supported_cat == 28 %other
%                 fprintf('%s\n',supported{1});
%             end
        end
        
        if strcmp(supporting{1}, 'floor')
            supporting_cat = cat_count + 1;
        elseif strcmp(supporting{1}, 'wall')
            supporting_cat = cat_count + 2;
        elseif strcmp(supporting{1}, 'ceiling')
            supporting_cat = cat_count + 3;
        else
            supporting_cat = get_object_type_bedroom(supporting);
            %just to check annotation
%             if supporting_cat == 28 %other
%                 fprintf('%s\n',supporting{1});
%             end
        end
        
        support_matrix(supported_cat, supporting_cat, type) = support_matrix(supported_cat, supporting_cat, type) + 1;
    end
end

end

