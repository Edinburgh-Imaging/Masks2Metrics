% This function identifies the closest X coordinate on either:
% 1. the GM curve array corresponding to a Y coordinate on the WM curve/mask (Xwm, Ywm). i.e., finds on GM: Xgm at Ywm (Xwm, Ygm). In this case it returns closest Xgm
% 2. the WM curve array corresponding to a Y coordinate on the GM curve/mask (Xgm, Ygm). i.e., finds on WM: Xwm at Ygm (Xgm, Ywm). In this case it returns closest Xwm
% X1 is Xwm for the first case, and Xgm for the 2nd
%
% Inputs: 
%   X1,Y1: the x & y-coordinates of a the voxel under investigation, on either the WM or GM mask in the
%   current slice
%   curve: the array of (x,y) coordinates that make up the corresponding GM
%   or WM mask
%
% Outputs:
%   X_closest: the x-coordinate of the voxel on 'curve' (i.e., the GM/WM
%   mask) that is closest to Y1
%   Y_closest: the y-coordinate of the voxel on 'curve' (i.e., the GM/WM
%   mask) that is closest to Y1
%
% Masks2Metrics Copyright (C) 2017 S. Mikhael and C. Gray

function [X_closest, Y_closest] = find_closestX_at_Y1(X1,Y1,curve)

%Identify the array of closest voxels to the curve (or mask)
Ycurve_array = curve(:,2); %identify all y coordinates of the curve array
Yarray = abs(Ycurve_array-Y1); %taking the difference to identify the closest coords to X1, i.e., with min distance to X1
indices_array = find(Yarray==(min(Yarray(:)))); %find the indices of these closest coords

%if only one voxel is the closest, identify it as (X_closest,Y_closest)
if size(indices_array) == 1
    closest_index=indices_array;
    X_closest=curve(closest_index,1);
    Y_closest=curve(closest_index,2);

else % more than one close X coordinate, so repeat the above while looking for closest of these points to X1
    min_Xcurve=curve(indices_array,1); %reduce curve to list X coords with minimum indices
    Xarray = abs(min_Xcurve-X1);
    indices_array_2=find(Xarray==(min(Xarray(:))));
    
    if size(indices_array_2) == 1 %only one coordinate found
        closest_index=indices_array_2;
    else
        closest_index=indices_array_2(1); %more than one close coordinate. Take the first 1
       
    end

    X_closest = curve(indices_array(closest_index),1); %identify the corresponding closest x coordinate
    Y_closest = curve(indices_array(closest_index),2); %identify the corresponding closest y coordinate
end

end
