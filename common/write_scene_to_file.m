function write_scene_to_file( scene3d, out_file )
%This function is for writing a scene model to a text file (fisher's
%format). (by Zeinab Sadeghipour)

fid = fopen(out_file, 'w');

%initialize
fprintf(fid, 'StanfordSceneDatabase\nversion 1.0\n');

modelcount = scene3d.modelcount;
fprintf(fid, 'modelCount %d\n', modelcount);

for oid = 1:modelcount
    object = scene3d.objects(oid);
    fprintf(fid, 'newModel %d %s\n', object.mindex, object.mid);
    fprintf(fid, 'parentIndex %d\n', object.pindex);
    fprintf(fid, 'children');
    for cid = 1:length(object.children)
        fprintf(fid, ' %d', object.children(cid));
    end
    fprintf(fid,'\n');
    fprintf(fid, 'parentMaterialGroupIndex %d\n', object.pmgindex);
    fprintf(fid, 'parentTriangleIndex %d\n', object.ptindex);
    fprintf(fid, 'parentUV %.7f %.7f\n', object.parentuv(1), object.parentuv(2));
    fprintf(fid, 'parentContactPosition %.7f %.7f %.7f\n', object.pcontactposition(1), object.pcontactposition(2), object.pcontactposition(3));
    fprintf(fid, 'parentContactNormal %.7f %.7f %.7f\n', object.pcontactnormal(1), object.pcontactnormal(2), object.pcontactnormal(3));
    fprintf(fid, 'parentOffset %.7f %.7f %.7f\n', object.poffset(1), object.poffset(2), object.poffset(3));
    fprintf(fid, 'scale %.7f\n', object.scale);
    fprintf(fid, 'transform');
    for r = 1:4
        for c = 1:4
            fprintf(fid, ' %.7f', object.transform(r,c));
        end
    end
    fprintf(fid, '\n');
end

fclose(fid);

end

