function new_factors = UpdateFactors( factor_type, result_filename, ...
    orig_factors, all_vars )
%UPDATEFACTORS eliminates factors with specified type

factors = [];

for fid = 1:length(orig_factors)
    if orig_factors(fid).factor_type == factor_type
        continue
    end
    factors = [factors, orig_factors(fid)];
end

new_factors = factors;

if ~isempty(result_filename)
    save(result_filename, 'factors', 'all_vars');
end

end

