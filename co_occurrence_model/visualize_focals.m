function visualize_focals( focals_file, out_dir )
%VISUALIZE_FOCALS Summary of this function goes here
%   Detailed explanation goes here

% focals_file = 'data/training/SUNRGBD/bedroom_focal_joining_results.mat';
% out_dir = 'Results/focals_visualized/';

load(focals_file, 'updated_focals');
mkdir(out_dir);

focals = updated_focals.subgraphs;
for fid = 1:length(focals)
    focal = focals{fid};
    if isempty(focal.edges)
        continue
    end
    
    h = figure;
    visualize_graph(focal, 'gspan_code');
    filename = [out_dir 'focal_' num2str(fid)];
    print(h, '-dpng', filename);
end

end

