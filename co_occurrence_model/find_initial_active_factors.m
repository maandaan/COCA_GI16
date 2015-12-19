function init_active_factors = find_initial_active_factors( ...
    constraint_nodes_ind, all_vars, factors )
%FIND_INITIAL_ACTIVE_FACTORS searches for factors activated by initial
%constraint nodes

f = [];
for fid = 1:length(factors)
    vars = factors(fid).var;
    present = ismember(vars, all_vars(constraint_nodes_ind));
    if ~isempty( find(present == 0, 1) )
        continue
    end
    
    f = [f, fid];
end

init_active_factors = f;

end

