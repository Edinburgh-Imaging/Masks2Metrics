function [mhd,f,thickness_array_slice_wm_gm, thickness_array_slice_gm_wm,wm_sa,gm_area,filled_ROI] = gyrus_slice(gm_slice,wm_slice,dim,vox_x,vox_y,slice_num,step_size,draw)
%
%This function measures thickness, surface area, and volume stats of the
%current slice. 
%
% Inputs:
%   gm_slice: grey matter mask for the current slice, in the form of a
%   matrix
%   wm_slice: white matter mask for the current slice, in the form of a
%   matrix
%   dim: volume dimensions
%   vox_x, vox_y: voxel size in the 2 directions normal to that in which
%   the slices were drawn. They are used to convert the measurments from
%   voxel space into Euclidean space
%   slice_num: number of the current slice
%   %step_size: used to identify the line to which the perpendicular will
%   be drawn when measuring thickness. Recommended step size is 3.
%   draw: 0 if not wanting to show figures of thickness measurements for
%   every slice, 1 if wanting to show them
%        
% Outputs: for each ROI
%   mhd: mean Hausdorff distance between the GM and WM curves, in mm
%   f: Frechet distance between the gm and wm curves, in mm
%   thickness_array_slice_wm_gm: thickness from the wm to the GM curve,
%   in mm
%   thickness_array_slice_gm_wm: thickness from the gm to the WM curve,
%   in mm.
%   wm_sa: white matter surface area, in mm^2
%   gm_area: grey matter area, or the area between the GM and WM curves, in
%   voxel^2.
%   filled_ROI: the filled in region of interest (ROI), comprising of the
%   area between the GM and WM curves
%
% Author: S Mikhael - 26 June 2017

%Identify endpoints of GM and WM segmentations, as well as the sequential
%order of pixels that make up each of these segmentations

ROI_slice_or = gm_slice | wm_slice;


if(draw)
    scrsz = get(groot,'ScreenSize');
    figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2])
    subplot(1,2,1);
    imshow(ROI_slice_or,[]);
    title('GM and WM borders')
    impixelinfo
    hold on
end


%Identify endpoints for GM and WM segmentations- start point and end point 
%will be saved to gm/wm_ends. 

gm_ends = identify_endpoints(gm_slice,dim); %identify the 2 endpoints of gm
wm_ends = identify_endpoints(wm_slice,dim); %identify the 2 endpoints of wm

%get nonzero pixels representing gm in this slice, in sequential order
[gm_array,newgm_ends]=get_sequential_pixels_given_seedpoint(gm_slice,gm_ends,draw);
newgm_ends=double(newgm_ends);
gm_array=double(gm_array);


%get nonzero pixels representing wm in this slice, in sequential order
[wm_array,newwm_ends]=get_sequential_pixels_given_seedpoint(wm_slice,wm_ends,draw);
newwm_ends=double(newwm_ends);
wm_array=double(wm_array);

%Run 2 checks on endpoints:

%Check 1: wanting gm and wm start pts to be lower than their end pts, so swap
% endpoints if that's not the case. This is necessary for identify_perpendicular_coords
%fn to work.
if newgm_ends(1,2) < newgm_ends(2,2) %ie if startpt higher than endpt
    newgm_ends = flipud(newgm_ends); %swap gm start & endpts
end


%Check 2: check that sequential order of both GM and WM is correct with respect to
%one another by checking euclidian distances between their start points and
%distances between their endpoints. Reverse the order of coordinates for WM
%if distance start-to-start-pt is greater than start-to-endpt.

%calculate distance betw gm start pt and wm start pt
dist_gm_wm_ss= euclidean_distance(newgm_ends(1,:),newwm_ends(1,:));
%calculate distance bewt gm start pt and wm end pt
dist_gm_wm_se= euclidean_distance(newgm_ends(1,:),newwm_ends(2,:));

%check gm_start_to_wm_start vs gm_start_to_wm_end distances to ensure that 
%GM & WM start and end points correspond to one another
if dist_gm_wm_ss > dist_gm_wm_se 
    disp(['Note: reversing sequential order of WM coordinates in slice ' num2str(slice_num)]);
    %reverse sequential order of WM points (wm_array), and reverse the
    newwm_ends = flipud(newwm_ends);
        
end

%plot WM endpoints (start in blue, end in red) for visual confirmation
    c_wm=newwm_ends(:,1); r_wm=newwm_ends(:,2);
    if (draw)
        plot(c_wm(1),r_wm(1), 'bs'); hold on; plot(c_wm(2),r_wm(2), 'rs'); hold on;
    end
    
 %plot GM endpoints (start in blue, end in red) for visual confirmation
    c_gm=newgm_ends(:,1); r_gm=newgm_ends(:,2);
    if (draw)
        plot(c_gm(1),r_gm(1), 'bs'); hold on; plot(c_gm(2),r_gm(2), 'rs'); hold on;   
    end





%% Calculating area between the two lines GM and WM for the current slice in
%% order to find the ROI's volume. This area is aka gm area (gm_area)


%Create a list of vertices for the polygon constiting of the gm and wm
%vertices, then find it's area in the following steps:

%1. gm & wm vertices need to be consecutive, so that we can close the
%polygon being drawn. Therefore 1st reverse the sequence of wm_array using
%flipud.
flipped_wmarray=flipud(wm_array);

%2. merge the list of gm and wm vertices (gm_array and flipped wm array)
allpixels=vertcat(gm_array,flipped_wmarray);
allpixels_x = allpixels(:,1); % x coordinates of all pixels
allpixels_y = allpixels(:,2); % y coordinates of all pixels

%3. create the matrix 'slice' representing all nonzero pixels- gm & wm
slice=zeros(size(gm_slice));
for (s=1:size(allpixels,1))
    slice(allpixels_y(s),allpixels_x(s))=1;
end

%4. Draw a white line between each of the 2 sets of endpoints by joining
%endpoints
gm_first=newgm_ends(1,:); %first point of gm array
gm_last=newgm_ends(2,:); %last point of gm array
wm_first=newwm_ends(1,:); %first point of wm array
wm_last=newwm_ends(2,:); %last point of wm array


lines_slice=zeros(size(gm_slice)); %representation of lines join'g WM & GM

%join the starting points of GM and WM ROIs, using 10 points in linspace
%fn
x_ends_first=linspace(gm_first(1),wm_first(1),10); % x coords of the joining line
y_ends_first=linspace(gm_first(2),wm_first(2),10); % y coords of the joining line
index_first=sub2ind(size(lines_slice),round(y_ends_first),round(x_ends_first));

lines_slice(index_first)=1; %set value voxels of the 1st joining line to 1


%join the ending points of GM and WM ROIs, using 10 points in linspace fn
x_ends_end=linspace(gm_last(1),wm_last(1),10); %x coords of the joining line
y_ends_end=linspace(gm_last(2),wm_last(2),10); % y coords of the joining line

index_end=sub2ind(size(lines_slice),round(y_ends_end),round(x_ends_end));
lines_slice(index_end)=1; %set value voxels of the 1st joining line to 1

%Get matrix of the closed ROI: closed_ROI= GM border + WM border + 2 joining
%lines @ the two ends
closed_ROI = slice | lines_slice; 

if(draw)
    subplot(1,2,2);
    imshow(closed_ROI,[]);%using transpose for visualizatn purposes
    title('Closed ROI')
    impixelinfo
    hold off
end


%Fill the closed ROI using bwmorph and show a figure of it
filled_ROI=imfill(closed_ROI,'holes');
if(draw)
    scrsz = get(groot,'ScreenSize');
    figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);
    subplot(2,2,[1 2]);
    imshow(filled_ROI,[0 3]); %using transpose for visualizatn purposes
    title('Filled ROI')
    impixelinfo
    hold on
end


    
%5.calculate polygon's area, in voxel^2, which is equal to the number of nonzero pixels
gm_area=size(nonzeros(filled_ROI),1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%getting GM representation in the slice based on the thin GM array
gm_slice_thin = zeros(size(gm_slice)); %create an empty slice
size_gm=size(gm_array);
%fill slice with intensity 2 at pixels making the line
for i = 1:1:size_gm(1)
    %read nonzero coordinates (listed in gm_array) which make up the GM line
    gm_x=gm_array(i,1); % x coordinate
    gm_y=gm_array(i,2); % y coordinate
    gm_slice_thin(gm_y,gm_x) = 2; 
end


%getting WM representation in the slice based on the thin WM array
wm_slice_thin = zeros(size(wm_slice)); %create an empty slice
size_wm=size(wm_array);

%fill slice with intensity 1 at pixels constituting the line
for i = 1:1:size_wm(1)
    %read nonzero coordinates (listed in wm_array) which make up the WM line
    wm_x=wm_array(i,1); % x coordinate
    wm_y=wm_array(i,2); % y coordinate
    wm_slice_thin(wm_y,wm_x) = 1; 
end

%for identify_perpendicular_coords fn only:
ROI_slice_plus_wm_gm = gm_slice_thin + wm_slice_thin;


gm_slice_thin_gm_wm = gm_slice_thin; 
wm_slice_thin_gm_wm = wm_slice_thin;

%swap 2s for 1s and vice versa
gm_slice_thin_gm_wm(gm_slice_thin_gm_wm==2)=1;
wm_slice_thin_gm_wm(wm_slice_thin_gm_wm==1)=2; 
ROI_slice_plus_gm_wm = gm_slice_thin_gm_wm + wm_slice_thin_gm_wm;



% set the number of pixels to be used to calculate gradient of line
Linside = 7;  %length of perpendicular line when searching inside roi_r_gm
Loutside = 7; %length of perpendicular line when searching outside roi_r_wm (since distances will be greater)

measurementInterval = 1; %measurements to be made at every pixel

%changing wm and gm arrays into cell format
wm_array_cell={wm_array}; 
gm_array_cell={gm_array};


%%Obtain thickness measurements for current slice in Euclidean space(units:
%mm)
size_wm_array=size(wm_array);


%subplot for the 2 sets of measurements: WM to GM (top), and GM to WM (bottom)
    if(draw)
        subplot(2,2,3);
        imshow(ROI_slice_plus_wm_gm,[0 3])
        title('WM to GM thickness measurements')
        impixelinfo
        hold on
    end
    


% Obtain WM to GM thickness measurements (units:mm)
 num_wm_pixels = numel(wm_array_cell{1,1}(:,1));
 thickness_array_slice_wm_gm=zeros(num_wm_pixels,1);

 num_gm_pixels = numel(gm_array_cell{1,1}(:,1));
 thickness_array_slice_gm_wm=zeros(num_gm_pixels,1);
 
 wm_sa = 0;
 %if it's not a very short segment
 if ((num_wm_pixels > 3) && (num_gm_pixels > 3))
    
     for k = 1:measurementInterval:num_wm_pixels
         %% measure from inner boundary (WM) to outer boundary (GM)
         Xwm = wm_array(k,1); %set Xgm = Xwm in order to find where gm is relative to wm at this Xwm coordinate, and in turn, the direction in which the perpendicular is to be drawn
         Ywm = wm_array(k,2); %set Ygm = Ywm in order to find where gm is relative to wm at this Ywm coordinate, and in turn, the direction in which the perpendicular is to be drawn
         [Xgm_closest_atX1, Ygm_closest_atX1] = find_closestY_at_X1(Xwm,Ywm,gm_array); %find the corresponding closest (Xgm,Ygm) at X1
         [Xgm_closest_atY1, Ygm_closest_atY1] = find_closestX_at_Y1(Xwm,Ywm,gm_array); %find the corresponding closest (Xgm,Ygm) at Y1
         [X2,Y2,x2_point_on_perpendicular, y2_point_on_perpendicular] = identify_perpendicular_coords(step_size, Linside, k, wm_array_cell,Xgm_closest_atY1, Ygm_closest_atX1);
         [xROI_r_gm,yROI_r_gm,length_of_perpendicular_wm_gm] = MeasureLength(X2,Y2,x2_point_on_perpendicular, y2_point_on_perpendicular,ROI_slice_plus_wm_gm,vox_x,vox_y,draw);
		 		 
		 %if the perpendicular passes through a GM voxel (i.e., length of perpendicular >0)
         if (length_of_perpendicular_wm_gm > 0)
			thickness_array_slice_wm_gm(k)=length_of_perpendicular_wm_gm;
         else % the perpendicular passes between 2 voxels (and length of perpendicular is 0). In this case, change step size (-1 / +1) and remeasure perpedicular's length. This will minimize the number of zero readings.
             %It may be zero if this new perpendicular passes between 2 voxels as well. In that case thickness=0.
             if step_size>1
                 new_step_size = step_size-1;
             else %step_size=1
                 new_step_size = step_size+1;
             end
             [X2,Y2,x2_point_on_perpendicular, y2_point_on_perpendicular] = identify_perpendicular_coords(new_step_size, Linside, k, wm_array_cell,Xgm_closest_atY1, Ygm_closest_atX1);
             [xROI_r_gm,yROI_r_gm,length_of_perpendicular_wm_gm] = MeasureLength(X2,Y2,x2_point_on_perpendicular, y2_point_on_perpendicular,ROI_slice_plus_wm_gm,vox_x,vox_y,draw);
             thickness_array_slice_wm_gm(k)=length_of_perpendicular_wm_gm;
         end
         
     %%Calculate WM surface area (wm_sa) by calculating Euclidean distance
     %%between 2 consecutive voxels- (Xwm,Ywm) and (Xwm_next,Ywm_next)
        if k < num_wm_pixels
            %account for voxel size in the 2-D slice- horizontal (x) and
            %vertical (y) directions
            Xwm_euclidean = Xwm * vox_x; 
            Xwm_next_euclidean = wm_array(k+1,1) * vox_x; 
            Ywm_euclidean = Ywm * vox_y;
            Ywm_next_euclidean = wm_array(k+1,2) * vox_y;
            dist= euclidean_distance([Xwm_euclidean, Ywm_euclidean],[Xwm_next_euclidean,Ywm_next_euclidean]);
            wm_sa = wm_sa + dist;
        end
                 
     end

    if(draw)
        subplot(2,2,4);
        imshow(ROI_slice_plus_gm_wm,[0 3])
        title('GM to WM thickness measurements')
        impixelinfo
        hold on
    end
    
    for j = 1:measurementInterval:num_gm_pixels
        %% measure from outer boundary (GM) to inner boundary (WM)
        Xgm = gm_array(j,1); %set Xwm = Xgm in order to find where wm is relative to gm at this Xgm coordinate
        Ygm = gm_array(j,2); %set Ywm = Ygm in order to find where wm is relative to gm at this Ygm coordinate
        [Xwm_closest_atX1, Ywm_closest_atX1] = find_closestY_at_X1(Xgm,Ygm,wm_array); %find the corresponding closest (Xwm,Ywm) at X1
        [Xwm_closest_atY1, Ywm_closest_atY1] = find_closestX_at_Y1(Xgm,Ygm,wm_array); %find the corresponding closest (Xwm,Ywm) at Y1
        [X1,Y1,x1_point_on_perpendicular, y1_point_on_perpendicular] = identify_perpendicular_coords(step_size, Linside, j, gm_array_cell,Xwm_closest_atY1, Ywm_closest_atX1);
        [xROI_r_wm,yROI_r_wm,length_of_perpendicular_gm_wm] = MeasureLength(X1,Y1,x1_point_on_perpendicular, y1_point_on_perpendicular,ROI_slice_plus_gm_wm,vox_x,vox_y,draw);
		
		%if the perpendicular passes through a GM voxel (i.e., length of perpendicular >0)
		 if length_of_perpendicular_gm_wm > 0
             %record that length/thickness
			thickness_array_slice_gm_wm(j)=length_of_perpendicular_gm_wm;
         else % the perpendicular passes between 2 voxels (and length of perpendicular is 0).In this case, change step size (-1 / +1) and remeasure perpedicular's length. This will minimize the number of zero readings.
             %It may be zero if this new perpendicular passes between 2 voxels as well. In that case thickness=0.
            if step_size>1
                 new_step_size = step_size-1;
             else %step_size=1
                 new_step_size = step_size+1;
            end
            [X1,Y1,x1_point_on_perpendicular, y1_point_on_perpendicular] = identify_perpendicular_coords(new_step_size, Linside, j, gm_array_cell,Xwm_closest_atY1, Ywm_closest_atX1);
            [xROI_r_wm,yROI_r_wm,length_of_perpendicular_gm_wm] = MeasureLength(X1,Y1,x1_point_on_perpendicular, y1_point_on_perpendicular,ROI_slice_plus_gm_wm,vox_x,vox_y,draw);
            
            thickness_array_slice_gm_wm(j)=length_of_perpendicular_gm_wm;
            
		 end
    end

   	 
		 
%clean the thickness arrays of current slice of values that are more than double the
%previous and next values, most likely due to crossing between 2 pixels and
%hitting the curve at a (wrong) more distant location
thickness_array_slice_wm_gm = clean_thickness_array(thickness_array_slice_wm_gm);
thickness_array_slice_gm_wm = clean_thickness_array(thickness_array_slice_gm_wm);


    if(draw)
        hold off
    end

 end


%%Calculate Frechet distance, from GM to WM layer / WM to GM layer, in mm

x_wm=wm_array(:,1)*vox_x; %x (or horizontal) Euclidean coordinates of wm curve
y_wm=wm_array(:,2)*vox_y; %y (or vertical) Euclidean coordinates of wm curve

x_gm=gm_array(:,1) * vox_x; %x (or horizontal) Euclidean coordinates of gm curve
y_gm=gm_array(:,2) * vox_y; %y (or vertical) Euclidean coordinates of gm curve

try
f = frechet(x_gm,y_gm,x_wm,y_wm); 
%above failing once in a blue moon when inputs aren't column vectors (single value instead) 
%hence try-catch phrase until resolved
catch
    f=0;
end


%%Modified Hausdorff distance from WM to GM / GM to WM layer (same result),
%%in mm
wm_array_euclidean = [x_wm y_wm];
gm_array_euclidean = [x_gm y_gm];
mhd=ModHausdorffDist(wm_array_euclidean,gm_array_euclidean);
end
