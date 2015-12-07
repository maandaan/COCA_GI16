function run_scene_viewer( scene_file, scene_dir )
%A function to run fisher's code for rendering scenes for the specified
%scene filename. (by Zeinab Sadeghipour)

scene_viewer_dir = 'scene_viewer_fisher/bin/';
parameters_file = [scene_viewer_dir 'parameters.txt'];

A = regexp( fileread(parameters_file), '\n', 'split');
A{1} = ['databaseDirectory=' scene_dir];
A{2} = ['defaultScene=' scene_file];

fid = fopen(parameters_file, 'w');
fprintf(fid, '%s\n', A{:});
fclose(fid);

current_dir = pwd;
cd(scene_viewer_dir);
system('sceneViewer.exe');
cd(current_dir);

end

