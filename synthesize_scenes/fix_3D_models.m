function [ scene ] = fix_3D_models( scene )
%FIX_3D_MODELS fixes the orientation for 3D models, based on the information in the file models_fixes.

for mid = 1:length(scene)
    modelname = scene(mid).modelname;
    
    switch modelname
        case {'f2518339da2a64ea5e87e18e0a88e78f', '569e2fce2f1ab3be617e9d9aa36a8137', ...
                '699468993d0ab5cb98d5fc0473d00a1c', 'da0f6b3a375a7e77e963c7e7c24b8dcd', ...
                'a4c14d2008146b61bcab7dd7c7b222d8', '133c16fc6ca7d77676bb31db0358e9c6', ...
                '5ce562e0632b7e81d8e3889d90601dd1', '215f72973cfa2c9a42c2142b4fb342c8', ...
                '3d3b4b8874f2aaddc397356311cbeea4', '26bb7229b024a8549b0c8289d51d981b', ...
                'f814eb2a6234540aa35a7666f0cfa5bb', 'cb70b087e5bc5e9522e46d8e163c0f81', ...
                'a49eec529b5c44eaac00fd1150223027', 'f017544fe5b334df1ab186a8b7e8a26a', ...
                'b7019849063234b6bad8372756ee3232', '6a85470c071da91a73c24ae76518fe62', ...
                '49ce47fb353f3460dd42083791b3d3a8', 'myroom_2', 'myroom_3'}
            %reverse the orientation
            scene(mid).orientation(1) = -scene(mid).orientation(1);
            scene(mid).orientation(2) = -scene(mid).orientation(2);
            
        case {'976ac71df97c9cd22bf3161ae4fda942'}
            temp = scene(mid).orientation(1);
            scene(mid).orientation(1) = scene(mid).orientation(2);
            scene(mid).orientation(2) = temp;
        
        case {'8ed7309372c7b0dd98d5fc0473d00a1c'}
            scene(mid).orientation(1) = 6.123e-17;
            scene(mid).orientation(2) = 1;
            
%         case {'3d3b4b8874f2aaddc397356311cbeea4'}
%             scene(mid).corners(5:8,3) = scene(mid).corners(5:8,3) - 29;
    end
end


end

