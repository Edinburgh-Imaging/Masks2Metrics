function [xWall,yWall,length_of_perpendicular] = MeasureLength(X1,Y1,x1_point_on_perpendicular, y1_point_on_perpendicular, CombinedImage,vox_x,vox_y,draw)

% Measure the length of the perpendicular line drawn from (X1,Y1) on one (GM/WM) curve to the corresponding pair (WM/GM curve).
% This function is an adaptation of one written by C Gray (Edinburgh Imaging and Edinburgh Clinical Research Facility, 
% University of Edinburgh, Scotland, UK) with his permission.
% Code adapted by S Mikhael (Edinburgh Imaging, Centre for Clinical Brain Sciences, University of Edinburgh, Scotland, UK).
% This function specifically identifies the coordinates at which the perpendicular, 
% when drawn from one mask (GM/WM) hits the other (WM/GM) at xWall,yWall.
% The perpendicular line with start-point (X1,Y1) and end-point 
% (x1_point_on_perpendicular, y1_point_on_perpendicular) is projected
% hopefully long enough that it will cross the wall boundary (if present).
% The wall boundary will exist with either an intensity value of 2 (=wall)
% or 3 (=stent+wall). If there is no wall present, the intensity values
% crossed by the perpendicular line will be less than 2 (note: the
% intensity values may be 1 at points along the perpendicular line,
% signifying parts of the stent boundary, therefore we cannot just look for
% intensity values of zero to signify no wall boundary)
%
%Inputs:
% X1,Y1: coordinates from which the perpendicular will originate
% x1_point_on_perpendicular: x coord of the perpendicular's endpoint
% y1_point_on_perpendicular: y coord of the perpendicular's endpoint
% CombinedImage: matrix representing the sum of the gm and wm curves
% vox_x: voxel size along the x/horizontal axis
% vox_y: voxel size along the y/vertical axis
% draw: if 0 then don't draw any points, if 1 then do draw
%    
%Outputs:
% xWall,yWall: x and y coordinates of the intersection between the
% perpendicular and the opposite wall/curve
%
% There will be 3 outcomes to this function:
% 1) stent & wall coincide (c==3)
% 2) wall boundary present (c==2)
% 3) no wall ('catch-all')
%
% Masks2Metrics Copyright (C) 2017 S. Mikhael and C. Gray


% Search along line
[cx,cy,c] = improfile(CombinedImage,[X1,x1_point_on_perpendicular],[Y1,y1_point_on_perpendicular],100);

c=ceil(c); %Rounds the elements of c to the nearest integers greater than or equal to c
% (i.e. rounds up the intensity values where the improfile line has went
% through part of a pixel and would normally return a 0 - e.g. 0.0123 will
% now be rounded up to 1)

max_c=max(c);

%% Stent and wall coincide
if max(c)==3  %catch special case where wall & stent occupy same area (i.e. wall intensity (2) + stent intensity (1) = 3)
    [x] = find(c==3); %find along the projected line where Wall ROI & Stent ROI occupy same location
    length_of_perpendicular = 1;
    if (draw)
        hold on
        line([X1-0.25, X1+0.25],[Y1,Y1],'Color','r','LineWidth',4);
    end
    xWall=X1; %return the coordinates of the where the stent and wall appose
    yWall=Y1; %in this case there is no apposing wall so the coordinates returned will be the same as the stent wall
    
%% Find opposing mask/wall    
else if max(c)==2
        [x] = find(c==2); %find along the projected line if it crosses the Wall ROI which has been set to have an intensity value=2
       
        % Calculate length of perpendicular line
        if numel(x)>0 %If the number of pixels which are found to have an intensity value=1 is greater than zero, then an intersection exists
            X_WallIntersection=cx(x(1));
            Y_WallIntersection=cy(x(1));
            
            %using euclidean coordinates to measure thickness and
            %account for voxel size
            X1_euclidean = X1*vox_x;
            Y1_euclidean = Y1*vox_y;
            X_WallIntersection_euclidean = X_WallIntersection * vox_x;
            Y_WallIntersection_euclidean = Y_WallIntersection * vox_y;
            
            %find the euclidean distance between the 2 coords
            length_of_perpendicular = euclidean_distance([X1_euclidean, Y1_euclidean],[X_WallIntersection_euclidean,Y_WallIntersection_euclidean]);%Calculate the length of the perpendicular between the edge point on the stent and the intersection point with the Wall ROI
            if (draw)
            hold on
            line([X1, cx(x(1))],[Y1,cy(x(1))],'Color','r','LineWidth',2); %draw a line between the point on the Stent wall and the corresponding point on the Wall (i.e. found perpendicularly)
            end
            xWall=X_WallIntersection; %return the coordinates of the where the stent and wall appose
            yWall=Y_WallIntersection; %in this case the coordinates returned will be where the projected perpendicular line intersects the wall boundary
        end
        
%% No opposing wall
    else % max(c)=2 = GM
        length_of_perpendicular =0;
        xWall=X1; %return the coordinates of the where the stent and wall appose
        yWall=Y1; %in this case there is no apposing wall so the coordinates returned will be the same as the stent wall
        
        if (draw)
            hold on
            plot(X1, Y1,'--rs','LineWidth',2,...
                         'MarkerEdgeColor','r',...
                         'MarkerFaceColor','g',...
                         'MarkerSize',5)
        end 
    end
end

end
