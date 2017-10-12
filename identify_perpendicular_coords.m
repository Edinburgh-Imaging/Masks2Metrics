function [X1,Y1,x1_point_on_perpendicular, y1_point_on_perpendicular] = identify_perpendicular_coords(step_size, l, j, B, X_closest_atY1, Y_closest_atX1)
% This function is an adaptation of the function InsideStentBoundary written by C Gray (CRIC, University of Edinburgh, Scotland, UK) with his permission
% Code adapted by S Mikhael (CCBS, University of Edinburgh, Scotland, UK)
% The original code used to work only in one direction, but now works in both GM to WM, and WM to GM. 
% It specifically identifies the coordinates at which the perpendicular, when drawn from one mask (GM/WM) hits the other (WM/GM)
%
%Inputs:
% step_size: distance between current point and the point used to draw the
% perpendicular
% l: the length of the perpendicular that is to be drawn from one curve to
% the next
% j: the index of the current voxel in the array
% B: cell array of coordinates belonging to the curve from which the
% perpendicular is being drawn
% X_closest_atY1: the x coord of a point on the GM/WM curve that is closest
% to a Y coordinate on the WM/GM curve
% Y_closest_atX1: the y coord of a point on the GM/WM curve that is closest
% to an x coordinate on the WM/GM curve
%
%Outputs:
% X1: x coord of the perpendicular's startpoint
% Y1: y coord of the perpendicular's startpoint
% x1_point_on_perpendicular: x coord of the perpendicular's endpoint
% y1_point_on_perpendicular: y coord of the perpendicular's endpoint
%
% Masks2Metrics Copyright (C) 2017 S. Mikhael

%This checks if the current iteration plus the 'step size' would take the
%loop outwith the number of elements in the range. If so, it will read the
%'step size' backwards (i.e. previous points) and takes this into account
%when calculating the gradient of the best fit line
if j+step_size > numel(B{1,1}(:,1))
    
    X1 = B{1,1}(j,1); % SM swapped '1' for '2', and '2' for '1' for these 2 lines
    Y1 = B{1,1}(j,2);
 
    %check if you can step back by an amount = step_size
    if j-step_size >= 1 %step backwards by an amount equal to stepsize
        X2 = B{1,1}((j-step_size),1);
        Y2 = B{1,1}((j-step_size),2);
		
    else %j-step_size is < 1, in a very small segment (rare case). Step back 1 pixel only
        X2 = B{1,1}((j-1),1);
        Y2 = B{1,1}((j-1),2);
    end
    
    gradient_of_best_fit_line = -(Y1-Y2)/(X1-X2);  %to work out the gradient going 'backwards'
    
else    
    %This is the default situation where the current iteration plus the
    % 'step size' are still within the number of elements in the range.
    X1 = B{1,1}(j,1); % SM swapped '1' for '2', and '2' for '1' for these 2 lines
    Y1 = B{1,1}(j,2);
    X2 = B{1,1}((j+step_size),1);
    Y2 = B{1,1}((j+step_size),2);

    gradient_of_best_fit_line = (Y2-Y1)/(X2-X1);
end
    

if  gradient_of_best_fit_line ==0  %condition for a vertical line
    gradient_angle_of_perpendicular = 90;
    % fprintf('the gradient is zero')
    
    if Y_closest_atX1 >= Y1 %GM curve is lower than WM curve at this point, i.e., perpendicular line will project south from the WM curve
        x1_point_on_perpendicular = X1 + (l*cosd(gradient_angle_of_perpendicular));
        y1_point_on_perpendicular = Y1 + (l*sind(gradient_angle_of_perpendicular));
        
    else % Y_closest_atX1 < Y1, perpendicular line will project north from the WM curve
        %the vertical line is coming from the SOUTH
        x1_point_on_perpendicular = X1 - (l*cosd(gradient_angle_of_perpendicular));
        y1_point_on_perpendicular = Y1 - (l*sind(gradient_angle_of_perpendicular));		
    end
    
    
    
else if  gradient_of_best_fit_line == Inf || gradient_of_best_fit_line == -Inf  %condition for a horizontal perpendicular
        gradient_angle_of_perpendicular = 180;
        if X_closest_atY1 >= X1 %GM curve is to the right of the WM curve, and the perpendicular will project east from the WM curve
            %if Y2>Y1  %the horizontal line is coming from the EAST and is in the top right quadrant (between zero and pi/2 radians)
            x1_point_on_perpendicular = X1 + abs((l*cosd(gradient_angle_of_perpendicular)));
            y1_point_on_perpendicular = Y1 + abs((l*sind(gradient_angle_of_perpendicular)));
        
        else %the horizontal perpendicular will project west from the WM curve
            %the horizontal line is coming from the EAST and is in the bottom right quadrant (between pi/2 and pi)
            x1_point_on_perpendicular = X1 - abs((l*cosd(gradient_angle_of_perpendicular)));
            y1_point_on_perpendicular = Y1 - abs((l*sind(gradient_angle_of_perpendicular)));		
			
        end        

              else if  gradient_of_best_fit_line >0
                gradient_of_perpendicular_line = -1/gradient_of_best_fit_line;
                gradient_angle_of_perpendicular =-atand(gradient_of_perpendicular_line);
                
                if  Y_closest_atX1 < Y1 %GM curve to the right of WM curve
                    x1_point_on_perpendicular = X1 + (l*cosd(gradient_angle_of_perpendicular));
                    y1_point_on_perpendicular = Y1 - (l*sind(gradient_angle_of_perpendicular));				
					
                else  %the line is sloping from the SOUTH-WEST
                    x1_point_on_perpendicular = X1 - (l*cosd(gradient_angle_of_perpendicular)); %$
                    y1_point_on_perpendicular = Y1 + (l*sind(gradient_angle_of_perpendicular)); %$
                end
                
            else  %gradient_of_best_fit_line <0
                gradient_of_perpendicular_line = -1/gradient_of_best_fit_line;
                gradient_angle_of_perpendicular = atand(gradient_of_perpendicular_line);
                
                if  Y_closest_atX1 < Y1 %GM curve to the left of WM curve
                    %gradient_angle_of_perpendicular = atand(gradient_of_perpendicular_line); %it's 180=atand in reality, but keeping in first quadrant for easier calculations below
                    x1_point_on_perpendicular = X1 - (l*cosd(gradient_angle_of_perpendicular)); %$
                    y1_point_on_perpendicular = Y1 - (l*sind(gradient_angle_of_perpendicular));			
					
                else  %the line is sloping from the SOUTH-EAST
                    x1_point_on_perpendicular = X1 + (l*cosd(gradient_angle_of_perpendicular));
                    y1_point_on_perpendicular = Y1 + (l*sind(gradient_angle_of_perpendicular)); 
                end
            end
        end
    end
end
