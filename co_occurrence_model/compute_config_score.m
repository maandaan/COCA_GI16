function [ score ] = compute_config_score( factors, all_present_nodes, use_log )
%COMPUTE_CONFIG_SCORE computes the score for a scene configuration based on
%the joint probability of the global scene graph.

if use_log
    score = 0;
else
    score = 1;
end
Consts;
valid_factor_types = [suppedge_below, suppedge_behind, occurrence];
factor_count = 0;

for fid = 1:length(factors)
%     func = factors(fid).potential_func;
%     if isfield(func, 'CPT')
%         prob_mat = func.CPT;
%     else
%         prob_mat = func.PF;
%     end

%     if ~ismember(factors(fid).factor_type , valid_factor_types)
%         continue
%     end
    
    assignment = ismember(factors(fid).var, all_present_nodes);
    v = GetValueOfAssignment(factors(fid), assignment + 1);
    if v == 0
        v = 1e-4;
        continue
    end
    
    if use_log
        score = score + log(v);
    else
        score = score * v;
%         if mod(factor_count,4) ~= 0
%             score = score * v;
%         else
%             score = score * v * 10;
%         end
        factor_count = factor_count + 1;
    end
    
%     ind = bin2dec( num2str( fliplr(var_assignment) ) ) + 1;
%     if prob_mat(ind) == 0
%         continue
%     end
%     
%     %if the focal is support focal for other objects, ignore it
%     type = factors.factors(fid).factor_type;
%     if type == suppedge_below || type == suppedge_behind
%        if ind < 3 % supported object is not present
%            continue
%        end
%     end
    
%     fprintf('focal id: %d, score: %f\n', fid, score);
end

end

