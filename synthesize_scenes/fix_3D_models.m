function [ scene ] = fix_3D_models( scene )
%FIX_3D_MODELS fixes the orientation for 3D models, based on the information in the file models_fixes.

for mid = 1:length(scene)
    modelname = scene(mid).modelname;
    
    switch modelname
        case {'f2518339da2a64ea5e87e18e0a88e78f', '569e2fce2f1ab3be617e9d9aa36a8137', ...
                '699468993d0ab5cb98d5fc0473d00a1c', 'da0f6b3a375a7e77e963c7e7c24b8dcd', ...
                'a4c14d2008146b61bcab7dd7c7b222d8', '133c16fc6ca7d77676bb31db0358e9c6', ...
                '5ce562e0632b7e81d8e3889d90601dd1', '215f72973cfa2c9a42c2142b4fb342c8', ...
                '3d3b4b8874f2aaddc397356311cbeea4', '26bb7229b024a8549b0c8289d51d981b'}
            %reverse the orientation
            scene(mid).orientation(1) = -scene(mid).orientation(1);
            scene(mid).orientation(2) = -scene(mid).orientation(2);
            
%         case {'3d3b4b8874f2aaddc397356311cbeea4'}
%             scene(mid).corners(5:8,3) = scene(mid).corners(5:8,3) - 29;
    end
end


end

