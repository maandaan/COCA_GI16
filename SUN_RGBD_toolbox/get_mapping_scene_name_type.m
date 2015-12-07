% This script is to generate a mapping from the name of the scene file and
% its type, all in a matrix. (by Zeinab Sadeghipour)

sunrgbdmeta_file = '../SUNRGBD/code/SUNRGBDtoolbox/Metadata/SUNRGBDMeta.mat';
sunrgbdmeta_mat = matfile(sunrgbdmeta_file);
data_size = size(sunrgbdmeta_mat.SUNRGBDMeta,2);

map_scene_name_type = repmat(struct('sequenceName',[],'sceneType',[]),data_size,1);

%the size is large, for efficiency load part by part
count = 1;
for did = 1:100:data_size
   
   gt_partial = sunrgbdmeta_mat.SUNRGBDMeta(:,did:min(did+99, data_size));
   filenames = {gt_partial(:).sequenceName};
   
   for i = 1:size(filenames,2)
       fid = fopen(['../SUNRGBD/code/SUNRGBDtoolbox/n/fs/sun3d/data/' filenames{i} '/scene.txt']);
       scene_type = fscanf(fid,'%s');
       map_scene_name_type(count).sequenceName = filenames{i};
       map_scene_name_type(count).sceneType = scene_type;
       count = count + 1;
       fclose(fid);
   end
end

out_file = 'data/training/SUNRGBD/scene_name_type.mat';
save(out_file, 'map_scene_name_type');