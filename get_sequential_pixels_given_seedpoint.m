function [array,new_ends] = get_sequential_pixels_given_seedpoint(ROI_slice,ends,draw)
%
% This function gets the sequential list of nonzero pixels representing a
% particular ROI (e.g. WM/GM) in a given nonzero slice 'ROI_slice'. It
% starts by identifying the GM and WM lines' corresponding start and
% endpoints (in a 2x2 'ends' array). The first of the 2 points in the 'ends'
% array is then made the seed point.  The array of sequential points which
% make up the GM/WM line is identified and returned, as well as the end
% points.
%
% Inputs: 
%   ROI_slice: matrix reprsentation of the gm/wm mask in current slice
%   ends: start and points of the gm/wm mask, to be used to identify the
%   sequence of points making up the mask
%   draw: for display purposes. 0 doesn't display figures, whereas 1 does.
%
% Outputs:
%   array: array of x,y coordinates constituting the mask in the current
%   slice
%   new_ends: new/final endpoints of the mask in the current slice
%
% Author: S Mikhael - 26 June 2017

disp('Identifying sequence of points ..');
hold on

%initializing endpoints matrix
new_ends=[0 0;0 0];

%Create a matrix of zeros, ROI_slice_ordered, of same size as a slice. This matrix will
%eventually hold the correct sequence of pixels that make up the GM outline in
%this slice
ROI_slice_ordered=zeros(size(ROI_slice));
order=1;
ctr=0;


%Create a temporary binary matrix of the current slice. All pixels that
%haven't yet been added to the sequence above will be of value 1. Those
%that have been added are of value 0.
ROI_slice_temp=ROI_slice;

%Identify endpoints for a line (GM/WM)- start point and end point will be saved
%to ends. Then chose the first point to be the seed point in order to start
%identifying the sequence of points.

seed=ends(1,:); %set seed point to the first set of (x,y) coordinates
endpt=ends(2,:); %endpoint

%Identify the sequence of points that form the GM/WM line if there is a
%seedpoint
if (seed ~= [0 0])
    new_ends(1,:)=seed;
    %update temp slice and ordered slice
    ROI_slice_ordered(seed(2),seed(1)) = order; % assign pixel correct order
    ROI_slice_temp(seed(2),seed(1)) = 0; % done with that pixel so zero it out
    array(1,:) = seed; %array will eventually hold the list of coordinates that make the line
    ctr = ctr + 1; % ctr is number of points that make the line
else
   disp('seed point not found.')
   return
end

point = seed;
%check if seed point is the only point in the slice
dim = size(ROI_slice_temp);

%identify next point & its connectivity
next_pt = identify_next_point(ROI_slice_temp,array,order,dim,draw); %identify next point
next_con = connectivity(next_pt(1),next_pt(2),ROI_slice_temp,dim);


% While there are points to add to the sequence (i.e., slice_temp is not
% entirely zeros and the last point was valid)
while (any(any(ROI_slice_temp))~=0 && any(point))
    %if endpoint reached. This prevents code from looping back to the extra points
    %in the slice
    if (isequal(point,endpt)||isequal(next_pt,endpt))
        new_ends=ends; %same start and endpoints as originally started with
        %if the next point is the endpoint add that point to the array and
        %return
        if (next_pt==endpt)
            array(ctr+1,:) = endpt; % update array
        end
        return
    else %endpoint hasn't been reached yet.Identify next point & its connectivity
        
        %if there is a next point, i.e. if point not equal [0 0]
        if (any(next_pt))
            
            %calculate distances between:
            %1. current point and next pt
            d_nextpt = euclidean_distance(point,next_pt);
            %2. current point and end point
            d_endpt = euclidean_distance(point,endpt);
            
            %if next point is too far, then stop and return
            if (d_nextpt>=d_endpt) %we're most probably going in the wrong direction and this point shouldn't be the next pt
                new_ends(2,:)=point; %stopping at the last point. Next point is wrong
                return
            else    
                    %Usual scenario
                    point = next_pt; %current point becomes the next point
                    order = order + 1; %update order variable
                    ctr = ctr + 1; % update number of points in the line
                    array(ctr,:) = point; % update the array of points on the line thusfar with this latest point
                    %update temp slice and ordered slice
                    ROI_slice_ordered(point(2),point(1)) = order; % assign pixel correct order
                    ROI_slice_temp(point(2),point(1)) = 0; % done with that pixel so zero it out
                    
                    %Clean the slice before moving on, if it's not the last
                    %point in the array, as follows:
                    %Identify next point & its connectivity
                    next_pt=identify_next_point(ROI_slice_temp,array,order,dim,draw); %identify next point
                    ROI_slice_temp_cleaned = clean_slice(ROI_slice_temp,dim);
                    ROI_slice_temp = ROI_slice_temp_cleaned;
                    next_con = connectivity(next_pt(1),next_pt(2),ROI_slice_temp,dim); % identify next point's connectivity
            end
        else
            new_ends(2,:)= point;
            return
        end
    end
end

new_ends(2,:)= point;

end
