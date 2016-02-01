function relative_score = compute_relative_config_score( factors, curr_nodes, next_nodes )
%COMPUTE_RELATIVE_CONFIG_SCORE computes the relative score between two sets
%of objects by reducing the computations needed to prevent numerical
%errors.

added_nodes = setdiff(next_nodes, curr_nodes);
deleted_nodes = setdiff(curr_nodes, next_nodes);

% new_score = 1;
% curr_score = 1;
new_score = 0;
curr_score = 0;

for fid = 1:length(factors)
    
    vars = factors(fid).var;
    if isempty(find(ismember(vars, [added_nodes, deleted_nodes])))
        continue
    end
    
    assignment = ismember(vars, next_nodes);
    v = GetValueOfAssignment(factors(fid), assignment + 1);
    if v == 0
        v = 1e-4;
%         continue
    end
%     new_score = new_score * v;
    new_score = new_score + log(v);
    
    
    assignment = ismember(vars, curr_nodes);
    v = GetValueOfAssignment(factors(fid), assignment + 1);
    if v == 0
        v = 1e-4;
%         continue
    end   
%     curr_score = curr_score * v;
    curr_score = curr_score + log(v);
end

relative_score = curr_score / new_score;

end

