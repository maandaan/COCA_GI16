function scene3d = read_scene_txt( scene_filename )
%This function is for reading the scene txt file (fisher's format) into a
%matlab struct. (by Zeinab Sadeghipour)

fid = fopen(scene_filename);

tline = fgetl(fid); %StanfordSceneDatabase
tline = fgetl(fid); %version <major version>.<minor version>

modelcount_line = fgetl(fid);
modelcount_line_split = strsplit(modelcount_line);
modelcount = str2num(modelcount_line_split{2});
scene3d.modelcount = modelcount;

objects = [];

for mid = 1:modelcount
    line_split = strsplit(fgetl(fid));
    object.mindex = str2num(line_split{2}); %model index
    object.mid = line_split{3}; %model id
    
    line_split = strsplit(fgetl(fid));
    object.pindex = str2num(line_split{2}); %parent index
    
    line_split = strsplit(fgetl(fid));
    children = [];
    for cid = 1:size(line_split,2)
        children = [children str2num(line_split{cid})];
    end
    object.children = children; %children indices
    
    line_split = strsplit(fgetl(fid));
    object.pmgindex = str2num(line_split{2}); %parent material group index
    
    line_split = strsplit(fgetl(fid));
    object.ptindex = str2num(line_split{2}); %parent triangle index
    
    line_split = strsplit(fgetl(fid));
    object.parentuv = [str2double(line_split{2}) str2double(line_split{3})]; %parent uv
    
    line_split = strsplit(fgetl(fid));
    object.pcontactposition = [str2double(line_split{2}) str2double(line_split{3}) str2double(line_split{4})]; %parent contact position
    
    line_split = strsplit(fgetl(fid));
    object.pcontactnormal = [str2double(line_split{2}) str2double(line_split{3}) str2double(line_split{4})]; %parent contact normal
    
    line_split = strsplit(fgetl(fid));
    object.poffset = [str2double(line_split{2}) str2double(line_split{3}) str2double(line_split{4})]; %parent offset
    
    line_split = strsplit(fgetl(fid));
    object.scale = str2double(line_split{2});
    
    line_split = strsplit(fgetl(fid));
    object.transform = [str2double(line_split{2}) str2double(line_split{3}) str2double(line_split{4}) str2double(line_split{5}); ...
        str2double(line_split{6}) str2double(line_split{7}) str2double(line_split{8}) str2double(line_split{9}); ...
        str2double(line_split{10}) str2double(line_split{11}) str2double(line_split{12}) str2double(line_split{13}); ...
        str2double(line_split{14}) str2double(line_split{15}) str2double(line_split{16}) str2double(line_split{17})];
    
    objects = [objects; object];
end

scene3d.objects = objects;

fclose(fid);

end

