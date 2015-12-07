function [ score ] = compute_config_score( factors, all_present_nodes )
%COMPUTE_CONFIG_SCORE computes the score for a scene configuration based on
%the joint probability of the global scene graph.

score = 1;
% score = 0;
Consts;

for fid = 1:length(factors)
%     func = factors(fid).potential_func;
%     if isfield(func, 'CPT')
%         prob_mat = func.CPT;
%     else
%         prob_mat = func.PF;
%     end
    
    assignment = ismember(factors(fid).var, all_present_nodes);
    v = GetValueOfAssignment(factors(fid), assignment + 1);
    if v == 0
%         v = 1e-3;
        continue
    end
    
    score = score * v;
%     score = score + log(v);
    
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

