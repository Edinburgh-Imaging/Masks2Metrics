function [thickness_array] = clean_thickness_array(thickness_array)
%This function cleans the thickness array by eliminating all the thickness
%readings that are more than twice the previous and next reading. These
%high thicknesses are then replaced by the mean of the previous and next
%thickness. They are most often caused by perpendiculars running between
%two voxel edges, and stopping at a (wrong) part of the curve that is
%further away, giving us a false impression that thicknesses are higher
%than they actually are. By cleaning the array of these false thicknesses,
%the overall thickness will drop slightly.
%
% Input: thickness array, possibly with high thickness readings
% Output: cleaned thickness array, where thicknesses that are double the
%previous and next thickness have been replaced by a value equal to the
%mean of the two, i.e., (previous thickness + next thickness)/2
%
% Masks2Metrics Copyright (C) 2017 S. Mikhael

%if array has more than 3 thickness readings, check thicknesses
if size(thickness_array,1)>3
    %starting from the 2nd thickness reading, compare current thickness to
    %the previous and next
    for i=2:size(thickness_array)-1
        %if the current thickness is more than twice the previous and next
        %thickness in the array, then replace it by the mean of the 2
        if (thickness_array(i)>(2*thickness_array(i-1)))&&(thickness_array(i)>(2*thickness_array(i+1)))
            thickness_array(i) = (thickness_array(i-1)+ thickness_array(i+1))/2;
        end
    end
    
end
end
