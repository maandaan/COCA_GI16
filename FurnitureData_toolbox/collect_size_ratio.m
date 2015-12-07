function [objects_valid_sizes] = collect_size_ratio(name, objtype_str, width, height, len, source)
% This function is to gather input data into a matrix and computing
% dimension ratios. (by Zeinab Sadeghipour)

no_obj = size(name,1);
objects = repmat(struct('name',[],'objtype_str',[],'width',[],'height',[],'len',[],'source',[],'wh_ratio',[],'hl_ratio',[],'wl_ratio',[],'diag',[],'diag_ratio',[]), no_obj, 1);

width = str2double(width);
height = str2double(height);
len = str2double(len);

for i = 1:no_obj
    objects(i).name = name{i};
    objects(i).objtype_str = lower(objtype_str{i});
    objects(i).width = width(i) .* 100;
    objects(i).height = height(i) .* 100;
    objects(i).len = len(i) .* 100;
    objects(i).source = source;
    
    objects(i).wh_ratio = width(i) ./ height(i);
    objects(i).hl_ratio = height(i) ./ len(i);
    objects(i).wl_ratio = width(i) ./ len(i);
    
end

objects_valid_sizes = objects;

end