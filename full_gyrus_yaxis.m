function [start_slice,stop_slice,thickness_wm_gm,thickness_gm_wm,mhd,f,wm_sa,gm_area,filled_roi] = full_gyrus_yaxis(data_bin_gm,data_bin_wm,dim,vox_x,vox_y,step_size,draw)
%This function runs when the region of interest (ROI) drawn in the coronal direction, i.e. along the y-axis
%
% Inputs:
%   data_bin_gm: a binarized version of the gm data
%   data_bin_wm: a binarized version of the wm data
%   dim: dimensions of the image
%   vox_x, vox_y: voxel size along the horizontal and vertical axes
%   step_size:used to identify the line to which the perpendicular will be drawn when measuring thickness 
%   draw: 0 if not wanting to show figures of thickness measurements for every slice, 1 if wanting to show them
%
% Outputs:
%   start_slice: the first nonzero slice, i.e., the 1st slice in which the
%   gyrus appears
%   stop_slice: the last nonzero slice, i.e., the last slice in which the 
%   gyrus appears
%   thickness_wm_gm: thickness array in Euclidean space, in the wm-to-gm
%   direction (units: mm)
%   thickness_gm_wm: thickness array in Euclidean space, in the gm-to-wm
%   direction (units: mm)
%   mhd: mean Hausdorff distance array, in Euclidean space (units: mm)
%   f: Frechet distance, in Euclidean space (units: mm)
%   wm_sa:white matter surface area of a given ROI segment, in Euclidean space (units: mm^2)
%   gm_area:area covered by grey matter for a given ROI segment, in pixel
%   space. This is equivalent to grey matter volume of the segment (units:
%   pixel^3)
%   filled_roi: the filled roi volume, for a given segment, in the form of
%   a binary mask
%
% Masks2Metrics Copyright (C) 2017 S. Mikhael

%initialize variables
start_slice=0;
stop_slice=0;
num_gyral_slices=0;

thickness_wm_gm=NaN;
thickness_gm_wm=NaN;
mhd=NaN;
f=NaN;
wm_sa=NaN;
gm_area=NaN;
filled_roi=zeros(size(data_bin_gm));


%For each slice in the y direction
for s = 1:1:size(data_bin_gm,2)
    gm_slice=squeeze(data_bin_gm(:,s,:)); %read gm details for slice s
    wm_slice=squeeze(data_bin_wm(:,s,:)); %read wm details for slice s


    filled_slice=zeros(size(gm_slice)); %initialize filled slice with zeros
    %if there is parcellation in this slice, calculate GM thickness and
    %other stats
    if (any(any(gm_slice)) && any(any(wm_slice)))
        if(start_slice==0)
            %1st gyral slice reached
            start_slice=s;
        else
            %last gyral slice reached
            stop_slice=s-1;
        end
        %increment # gyral slices by 1
        num_gyral_slices=num_gyral_slices + 1;
        %get thickness, surface area, and volume stats of current slice and concatenate it to that of all 
        %other slices. All stats except for gm_area are in Euclidean space
        [mhd_slice,f_slice,thickness_slice_wm_gm,thickness_slice_gm_wm,wm_sa_slice,gm_area_slice,filled_slice] = gyrus_slice(gm_slice,wm_slice,dim,vox_x,vox_y,s,step_size,draw);
        
        if isnan(thickness_wm_gm) % first slice with GM & WM segmentation
            thickness_wm_gm = thickness_slice_wm_gm;
            thickness_gm_wm = thickness_slice_gm_wm;
            mhd=mhd_slice;
            f=f_slice;
            wm_sa=wm_sa_slice;
            gm_area=gm_area_slice;
        else %remaining slices with GM & WM segmentation. Concatenate current
            %slice thickness to thickness array
            thickness_wm_gm = vertcat(thickness_wm_gm,thickness_slice_wm_gm); 
            thickness_gm_wm = vertcat(thickness_gm_wm,thickness_slice_gm_wm);
            mhd = vertcat(mhd,mhd_slice);
            f = vertcat(f,f_slice);
            wm_sa=vertcat(wm_sa,wm_sa_slice);
            gm_area=vertcat(gm_area,gm_area_slice);
        %thickness(s,:)=[mean_th_slice max_th_slice new_mean_th_slice];
        end
   
    end
filled_roi(:,s,:) = filled_slice; 

end
end
