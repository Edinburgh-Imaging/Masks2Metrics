function [X_closest, Y_closest] = find_closestY_at_X1(X1,Y1,curve)
% This function identifies the closest Y coordinate on either:
% 1. the GM curve array corresponding to an X coordinate on the WM curve (Xwm, Ywm). i.e., finds on GM: Ygm at Xwm (Xwm, Ygm). In this case it returns closest Ygm
% 2. the WM curve array corresponding to an X coordinate on the GM curve (Xgm, Ygm). i.e., finds on WM: Ywm at Xgm (Xgm, Ywm). In this case it returns closest Ywm
% X1 is Xwm for the first case, and Xgm for the 2nd
% 
% Inputs: 
%   X1,Y1: the x- and y-coordinates of the voxel under investigation on
%   either the WM or GM mask in the
%   current slice
%   curve: the array of (x,y) coordinates that make up the corresponding GM
%   or WM mask
%
% Outputs:
%   Y_closest: the y-coordinate of the voxel on 'curve' (i.e., the GM/WM
%   mask) that is closest to X1
%   X_closest: the corresponding x-coordinate of the voxel on 'curve' (i.e., the GM/WM
%   mask) that is closest to X1
%
% Author: S Mikhael - 26 June 2017

Xcurve_array = curve(:,1); %identify all x coordinates of the curve array
Xarray = abs(Xcurve_array-X1); %taking the difference to identify the closest coords to X1, i.e., with min distance to X1
indices_array = find(Xarray==(min(Xarray(:)))); %find the indices of these closest coords

%if only one voxel is the closest, identify it as (X_closest,Y_closest)
    if size(indices_array) == 1
        closest_index=indices_array;
        X_closest=curve(closest_index,1);
        Y_closest=curve(closest_index,2);

        % else more than one close Y coordinate, so repeat the above while looking for closest of these points to Y1
    else
        min_Ycurve=curve(indices_array,2); %reduce curve to list Y coords with minimum indices
        Yarray = abs(min_Ycurve-Y1);
        indices_array_2=find(Yarray==(min(Yarray(:))));

        if size(indices_array_2) == 1 %only one coordinate found
            closest_index=indices_array_2;
        else
            closest_index=indices_array_2(1); %more than one close coordinate. Take the first 1
        end

        X_closest = curve(indices_array(closest_index),1); %identify the corresponding closest x coordinate
        Y_closest = curve(indices_array(closest_index),2); %identify the corresponding closest y coordinate
    end

end

