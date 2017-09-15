function [roi_gm_mean_thickness, roi_gm_vol, roi_wm_sa] = masks2metrics(subj, segments, roi, hem, step_size, draw)
%This is the main function which is used to calculate 3 metrics for a given
%ROI. The ROI must be defined by paired nii masks, and drawn continuously
%along one direction (x-, y- or z-axis). In the case of the ROI being a
%gyrus, the paired masks would be the corresponding grey matter (GM) and
%white matter curves (WM).
%
%Paired ROI nifti (.nii) masks are expected to be of the form
%subj_roi_hem_gm/wmsegments.nii. An example of a pair corresponding to
%subject 1's right SFG (superior frontal gyrus would be 1_sfg_r_gm1.nii and
%1_sfg_r_wm1.nii.
%
%The ROI metrics outputted are grey matter thickness (GMth), grey matter volume
%(GMvol),and white matter surface area (WMsa).
%
%
%Inputs
	%subj: subject number
	%segments: number of ROI segments making up the ROI. This number will
	%be the same for both WM and GM segments. This allows for flexibility
	%in the event that an ROI is a combination of masks.
	%roi: region of interest, e.g. gyrus' name
	%hem: left ('l') or right ('r') hemisphere
	%step_size: used to identify the line to which the perpendicular will
	%be drawn when measuring thickness. Recommended step size is 3.
	%draw: 0 if not wanting to show figures of thickness measurements for
	%every slice, 1 if wanting to show them
%Outputs:
	%roi_gm_th: grey matter thickness, in mm
	%roi_gm_vol: grey matter volume, in mm^3
	%roi_wm_sa: white matter surface area, in mm^2
%    
%Example: [s1_sfg_gm_th,s1_sfg_l_gm_vol,s1_sfg_wm_sa] = masks2metrics(1,1,'sfg','l',3,1)
%
% Author: S Mikhael - 26 June 2017

%Request direction along which the region of interest was drawn in a continuous manner
prompt = ['Along which direction was the region of interest drawn?\n Please note that this ' ...
    'needs to have been done in a continuous manner. Press:'...
    '\n ''1'' for saggital (i.e., along the x-axis)'...
    '\n ''2'' for coronal (i.e., along the y-axis)'...
    '\n ''3'' for axial (i.e., along the z-axis):  '];
direction = input(prompt);


while (direction~=1&&direction~=2&&direction~=3)
    prompt = ['\n\nPlease enter a valid number (1/2/3) for the direction in which the ROI has'...
        'been continuously drawn:' ...
    '\n ''1'' for saggital (i.e., along the x-axis)'...
    '\n ''2'' for coronal (i.e., along the y-axis)'...
    '\n ''3'' for axial (i.e., along the z-axis):  '];
    direction = input(prompt);
end


disp(['Preparing ' roi ' for subject ' num2str(subj) '... ']);
 
%Initializing variables for the entire gyrus: thickness, mean Hausdorff 
%distance, Frechet's distance

total_thickness_gm_wm=NaN;
total_thickness_wm_gm=NaN;
total_mhd=NaN;
total_f=NaN;


%For each of the gm/wm segments, calculate each of the stats (thickness,
%mhd, f) and merge them with the list for the entire gyrus
for seg=1:1:segments

    ROI_hem_gm=strcat(num2str(subj),'_',roi,'_',hem,'_gm',num2str(seg));
    ROI_hem_wm=strcat(num2str(subj),'_',roi,'_',hem,'_wm',num2str(seg));


%%%code for Matlab2015 and higher
%Read the nifti GM and WM masks and load their corresponding data and
%metadata
[data,dim,vox,type]=read_nifti_volume(ROI_hem_gm);
data_bin_gm=logical(data); %binarize data


[data,dim,vox,type]=read_nifti_volume(ROI_hem_wm);
data_bin_wm=logical(data); %binarize data

    %switch case based on the direction in which masks were drawn
    switch direction
        case 1
            %ROI drawn in the saggital direction, i.e. along the x-axis
            %For each slice in the x direction
            vox_x=vox(2); vox_y=vox(3); %voxel size along the horizontal (x) and vertical (y) axes
            vox_z=vox(1); % voxel size along the direction in which the roi was drawn
            [start_slice,stop_slice,thickness_wm_gm,thickness_gm_wm,mhd,f,wm_sa,gm_area,filled_roi] = full_gyrus_xaxis(data_bin_gm,data_bin_wm,dim,vox_x,vox_y,step_size,draw);
        case 2
            %ROI drawn in the coronal direction, i.e. along the y-axis
            %For each slice in the y direction
            vox_x=vox(3); vox_y=vox(1); %voxel size along the horizontal (x) and vertical (y) axes
            vox_z=vox(2); % voxel size along the direction in which the roi was drawn
            [start_slice,stop_slice,thickness_wm_gm,thickness_gm_wm,mhd,f,wm_sa,gm_area,filled_roi] = full_gyrus_yaxis(data_bin_gm,data_bin_wm,dim,vox_x,vox_y,step_size,draw);
            
        otherwise %case 3
            %ROI drawn in the axial direction, i.e. along the z-axis
            %For each slice in the z direction
            vox_x=vox(2); vox_y=vox(1); %voxel size along the horizontal (x) and vertical (y) axes
            vox_z=vox(3); % voxel size along the direction in which the roi was drawn
            [start_slice,stop_slice,thickness_wm_gm,thickness_gm_wm,mhd,f,wm_sa,gm_area,filled_roi] = full_gyrus_zaxis(data_bin_gm,data_bin_wm,dim,vox_x,vox_y,step_size,draw);
            
    end
   

 
    %After running through all the volume for a given gm/wm segment, append
    %this segment's stats to the current list of all segments stats for this gyrus
    if isnan(total_thickness_wm_gm) % first segment of GM/WM for this gyrus
        total_thickness_wm_gm = thickness_wm_gm;
        total_thickness_gm_wm = thickness_gm_wm;
        total_mhd = mhd;
        total_f = f;
        total_wm_sa = wm_sa;
        total_gm_area = gm_area;
        total_filled_roi = filled_roi;
    else %remaining segments of GM/WM for this gyrus. Concatenate segment stats
        %thickness/mhd/f to stats arrays
        total_thickness_wm_gm = vertcat(total_thickness_wm_gm,thickness_wm_gm);
        total_thickness_gm_wm = vertcat(total_thickness_gm_wm,thickness_gm_wm);
        total_mhd = vertcat(total_mhd,mhd);
        total_f = vertcat(total_f,f);
        total_wm_sa = vertcat(total_wm_sa,wm_sa);
        total_gm_area = vertcat(total_gm_area,gm_area);
        total_filled_roi = total_filled_roi | filled_roi; %combining all roi segments
    end
   
end

%% Convert gm stats from pixel space to voxel space by mulitplying
%% by voxel dimensions found in the header file.
%% We are assuming that there are no spaces between the voxels.
total_gm_area = total_gm_area * vox_x * vox_y * vox_z; %multiply area by voxel size in 3 directions to obtain ROI volume 
 
%% Multiply wm_sa stats by voxel size in the direction along which it was drawn to account for slice thickness
total_wm_sa = total_wm_sa * vox_z; 
 
 
%% Write all desired variables to files

%Write the filled roi volume to a nifti file
%convert array to type double as make_nii cannot hand logical data
total_filled_roi=double(total_filled_roi);
filled_name = strcat(int2str(subj),'_',roi,'_',hem,'_filled_step',int2str(step_size));
filename_filled=make_nii(total_filled_roi,[1 1 2],[0 0 0],2,'binary file');
filled_name_nii=strcat(filled_name,'.nii');
save_nii(filename_filled,filled_name_nii);

%rename variable below for the sake of clarity
total_gm_vol=total_gm_area; % sum of GM areas/slice makes up GMV of that roi


%get the mean and maximum of the Frechet and mean Hausdorff distances
%of each slice. This gives us the mean Frechet and mean mhd across the
%entire roi

mean_total_f=mean(total_f);
mean_total_mhd=mean(total_mhd);

max_total_f = max(total_f);
max_total_mhd = max(total_mhd);


%write thickness data to file
%th_range = 'A1';

file1 = strcat(int2str(subj),'_',roi,'_',hem,'_thickness_WMtoGM_step',int2str(step_size),'.xls');
file2 = strcat(int2str(subj),'_',roi,'_',hem,'_thickness_GMtoWM_step',int2str(step_size),'.xls');
file3 = strcat(int2str(subj),'_',roi,'_',hem,'_frechet_step',int2str(step_size),'.xls');
file4 = strcat(int2str(subj),'_',roi,'_',hem,'_modified_hausdorff_step',int2str(step_size),'.xls');
file5 = strcat(int2str(subj),'_',roi,'_',hem,'_WM_sa_step',int2str(step_size),'.xls');
file6 = strcat(int2str(subj),'_',roi,'_',hem,'_GM_vol_step',int2str(step_size),'.xls');

xlswrite(file1,total_thickness_wm_gm);
xlswrite(file2,total_thickness_gm_wm);
xlswrite(file3,total_f);
xlswrite(file4,total_mhd);
xlswrite(file5,total_wm_sa);
xlswrite(file6,total_gm_vol);


filename1 = strcat(int2str(subj),'_',roi,'_',hem,'_thickness_WMtoGM_step',int2str(step_size),'.mat');
save(filename1,'total_thickness_wm_gm');

filename2 = strcat(int2str(subj),'_',roi,'_',hem,'_thickness_GMtoWM_step',int2str(step_size),'.mat');
save(filename2,'total_thickness_gm_wm');

filename3 = strcat(int2str(subj),'_',roi,'_',hem,'_frechet_step',int2str(step_size),'.mat');
save(filename3,'total_f');


filename3_mean = strcat(int2str(subj),'_',roi,'_',hem,'_mean_frechet_step',int2str(step_size),'.mat');
save(filename3_mean,'mean_total_f');

filename4 = strcat(int2str(subj),'_',roi,'_',hem,'_modified_hausdorff_step',int2str(step_size),'.mat');
save(filename4,'total_mhd');

filename4_mean = strcat(int2str(subj),'_',roi,'_',hem,'_mean_modified_hausdorff_step',int2str(step_size),'.mat');
save(filename4_mean,'mean_total_mhd');

filename5 = strcat(int2str(subj),'_',roi,'_',hem,'_WM_sa_step',int2str(step_size),'.mat');
save(filename5,'total_wm_sa');

filename6 = strcat(int2str(subj),'_',roi,'_',hem,'_GM_vol_step',int2str(step_size),'.mat');
save(filename6,'total_gm_vol');

%Identify total WM_SA & GM vol for the roi in pixel space
roi_wm_sa = sum(total_wm_sa);
roi_gm_vol= sum(total_gm_vol);

%% Some statistics on the thickness metrics: mean, median and trim mean (at 20%)

%Calculate mean/trim mean at 20%/median thicknesses for both WM->GM  and
%GM->WM directions
mean_thickness_wm_gm = mean(nonzeros(total_thickness_wm_gm)); 
mean_thickness_gm_wm = mean(nonzeros(total_thickness_gm_wm));
roi_gm_mean_thickness = mean(nonzeros([mean_thickness_wm_gm mean_thickness_gm_wm]));

trim_mean_thickness_wm_gm = trimmean(total_thickness_wm_gm,20);
trim_mean_thickness_gm_wm = trimmean(total_thickness_gm_wm,20);
roi_gm_trim_mean_thickness = mean(nonzeros([trim_mean_thickness_wm_gm,trim_mean_thickness_gm_wm]));


median_thickness_wm_gm = median(nonzeros(total_thickness_wm_gm));
median_thickness_gm_wm = median(nonzeros(total_thickness_gm_wm));
roi_gm_median_thickness = median(nonzeros([median_thickness_wm_gm,median_thickness_gm_wm]));


end

