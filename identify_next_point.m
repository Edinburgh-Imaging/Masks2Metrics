function next_point = identify_next_point(temp_slice,current_array,current_order,dim,draw)
% This function identifies the seed point of a gm/wm mask (line) in a 
% given slice, and returns its coordinates. In order for a point to be a 
% seed point, its value should be nonzero and its connectivity should equal
% 1. This should be the case at either endpoint of the line.
%
% Inputs:
%   temp_slice: matrix representation of the current slice with the
%   remaining part of the wm/gm mask (the part not yet investigated for
%   sequence of points)
%   current_array: current list of coordinates that make up the mask
%   current_order: index of the current point
%   dim: dimensions of current 2d slice
%   draw: 1 for displaying results, 0 for not displaying them
%
% Output:
%   next_point: (x,y) coordinates of the next point in the mask
%
% Masks2Metrics Copyright (C) 2017 S. Mikhael

%Identify the current point and its connectivity
current_pt=current_array(current_order,:);
x = current_pt(1);
y = current_pt(2);
con = connectivity(x,y,temp_slice,dim);

%initializing next point's coordinates
next_point = [0 0];

%find coordinates (j,i) or (x,y) of all nonzero voxels of temp_slice, and
%the size (s) of the array i,j
[i,j,s]=find(temp_slice);
temp_array=[j i]; %save coordinates of nonzero voxels to an array

%if zero connectivity but more than 2 points left in the slice, chances are
%that the remaining pts are junk => returns next_point=[0 0]
if (con==0 && (size(s,1)<2))
    return;
end

%if zero connectivity but more than 3 points left in the slice. This is the
%case when cleaning a slice has broken the segmented line. 
if (con==0 && (size(s,1)>3))

    %find next nearest point, with hopes that this point will be the nearest
    %endpoint of the broken line that we are seeking, and not of 'uncleaned' 
    %parts of the slice.
    d = zeros(size(temp_array,1),1);
    nearest_d = 7;
    for a=1:1:size(temp_array,1)
        d(a) = euclidean_distance(double(current_pt),double(temp_array(a,:)));
        if d(a) < nearest_d
            next_point = temp_array(a,:);
            nearest_d = d(a);
        end
    end
    
    if any(next_point)&&(draw)
        hold on;
        plot(next_point(1),next_point(2), 'gx'); hold on
    end
      
else %usual scenario
    
    %check temp_slice in clockwise direction for the next nonzero (connected)
    %point, given the current point. I.e., checking neighboring 8 pixels
    
    %checking if current point out of slice range
    if ((x < 0) || (x > dim(2)) || (y < 0) || (y > dim(1)))
        disp(['Point ' num2str(x) ',' num2str(y) ' is out of range'])
        return;
    end
    
    %Identifying the first neighboring nonzero pixel, out of a possible 8, in a
    %clockwise direction
    
    %Checking 3rd point's connectivity (x,y+1)
    xtemp=x; ytemp=y+1;
    if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
        if (temp_slice(ytemp,xtemp)==0)
            %Checking 2nd point's connectivity (x+1,y+1)
            xtemp=x+1; ytemp=y+1;
            %if not past the edge of the slice, then check intensity value
            if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
                if (temp_slice(ytemp,xtemp)==0)
                    %Checking 1st point's connectivity (x+1,y)
                    xtemp=x+1; ytemp=y;
                    %if not past the edge of the slice, then check intensity value
                    if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
                        if (temp_slice(ytemp,xtemp) == 0)
                            %Checking 8th point's connectivity (x+1,y-1)
                            xtemp=x+1; ytemp=y-1;
                            %if not past the edge of the slice, then check intensity value
                            if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
                                if (temp_slice(ytemp,xtemp)==0)
                                    %Checking 7th point's connectivity (x,y-1)
                                    xtemp=x; ytemp=y-1;
                                    %if not past the edge of the slice, then check intensity value
                                    if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
                                        if (temp_slice(ytemp,xtemp)==0)                                     
                                           %Checking 6th point's connectivity (x-1,y-1)
                                           xtemp=x-1; ytemp=y-1;
                                           %if not past the edge of the slice, then check intensity value
                                           if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
                                               if (temp_slice(ytemp,xtemp)==0)
                                                   %Checking 5th point's connectivity (x-1,y)
                                                   xtemp=x-1; ytemp=y;
                                                   %if not past the edge of the slice, then check intensity value
                                                   if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
                                                       if (temp_slice(ytemp,xtemp)==0)                                          
                                                           %Checking 4th point's connectivity (x-1,y+1)
                                                           xtemp=x-1; ytemp=y+1;
                                                           %if not past the edge of the slice, then check intensity value
                                                           if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
                                                               if (temp_slice(ytemp,xtemp)==0)
                                                                   next_point=[0 0]; %no neighboring nonzero pixels
                                                                   return
                                                               end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        next_point = [xtemp ytemp];
        %plot the next point
        if(draw)
            hold on
            plot(next_point(1),next_point(2), 'g*');  
        end
    end
end
