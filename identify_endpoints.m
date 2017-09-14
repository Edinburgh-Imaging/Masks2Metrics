function [ends] = identify_endpoints(myslice,dim)
%This function identifies the endpoints of a gm/wm boundary (line) in a 
%given slice, and returns their coordinates. In order for a point to be a 
%seed point,its value should be nonzero and its connectivity should equal 1. 
%This should be the case at either endpoint of the line. 
%If connectivity =1 at the endpoints, then the function identify_seed_point
%can be used instead.
%
% Inputs: 
%   myslice: binary representation of the grey matter/white matter mask in
%   the current slice
%   dim: the 3 dimensions of the 3D volume
%
% Output: 
%   ends: the two endpoints of the mask for the current slice. In the event
%   that the mask represented by a curve includes branching, the endpoints
%   making up the longest path are the ones chosen.
%
% Author: S Mikhael - 26 June 2017

disp('Identifying endpoints ..');

%initializing seed point. If returns from function as [0 0;0 0] then no seed
%point for this slice (i.e., error)
ends=zeros(2,2);

%Identify start and endpoints of the mask in myslice by:

%1. Thinning the mask to eliminate the bits that are thicker than one voxel and
%identify the coordinates of the thinned mask (thin_array)
thin_slice = bwmorph(myslice, 'thin',Inf); %thin the curve
[thiny thinx] = find(thin_slice); %identify coords making the thin curve
thin_array=[thinx thiny];

%2. Identifying connectivity of each voxel in the thinned slice
%The points with connectivity 1 will be the actual endpoints

for i=1:size(thiny,1)
    con_thin(i) = connectivity(thinx(i),thiny(i),thin_slice,dim);
end

%3. Identifying indices where connectivity is 1
%Those indices should correspond to the endpoints
all_end_indices = find(con_thin == 1); 
number_of_indices=size(all_end_indices,2);

%We may end up with more than 2 indices, and therefore more than just the
%start and end points

%If no indices with connectivity equal to 1 are found, search for the
%furthest indices with a connectivity equal to 2
if(number_of_indices==0) 
    disp('Warning: no endpoints found. Identifying furthest 2 points which may not necessarily be true start and end points')
    % identify indices where connectivity is 2,i.e., next best thing
    all_end_indices = find(con_thin == 2);
    number_of_indices=size(all_end_indices,2);

    %next 3 lines added June 13th 2017- 'if....else', and line 80 'end'
    %If still no endpoints are found, even when looking for a connectivity
    %of 2, return (0,0)s as endpoints. In this case, measurements
    %(thickness, surface area, volume etc) for this slice will not be taken
    %nor incorporated into the final stats.

    if (number_of_indices==0) % #indices still zero
        ends=zeros(2,2); %no seedpoint for this slice and no endpoints found.    
    else
        %endpoints found, so identify all possible sequence of points
        %between start and endpoint.
        k=1;
        for i=1:number_of_indices-1 %for each index
            j=i;
            while j < number_of_indices %for each pair of indices from index i onwards
                index1=all_end_indices(i); %identify first index
                index2=all_end_indices(j+1); %identify second index
                endpoint1=thin_array(index1,:); %identify corresponding coordinates at these 2 indices
                endpoint2=thin_array(index2,:);
                [sequence,ends] = get_sequential_pixels_given_seedpoint(thin_slice,[endpoint1;endpoint2],0); %get the sequence of points given endpoints 1 and 2
                sequence_length=size(sequence,1); %identify the length of the current sequence
                pairs(k,:)=[endpoint1 endpoint2 sequence_length]; %populate the pairs array with endpoints and corresponding curve length in terms of points
                j=j+1; %move to the next pair of indices
                k=k+1; %increase counter for number of pairs
            end
        end

    %Identify the longest of the sequences
    lengths=pairs(:,5); %extract lengths column from pairs array
    [max_value,longest_index]=max(lengths); %identify index of longest path, i.e., path between 2 endpoints with largest number of points
    disp('Identified endpoints based on longest path between 2 sets of pixels with connectivity=2');
    ends = [pairs(longest_index,1) pairs(longest_index,2);pairs(longest_index,3) pairs(longest_index,4)]
    end 
             
else
    if(number_of_indices==1) %only 1 endpoint with connectivity=1 has been found.
        %now identify furthest point from this endpoint with connectivity=2
        disp('Warning: only one endpoint found. Identifying second point based on the furthest point away from it with connectivity=2')
        endpoint1=thin_array(all_end_indices(1),:); %identified first endpoint. It has connectivity 1
        
        %identify 2nd endpoint
        % identify indices where connectivity is 2, i.e., going for the next best thing
        all_end_indices = find(con_thin == 2);
        number_of_indices=size(all_end_indices,2);
        
        for i=1:number_of_indices %for each index            
            index2=all_end_indices(i); %identify first index
            endpoint2=thin_array(index2,:); %identify corresponding coordinates at these 2 indices
            [sequence,ends] = get_sequential_pixels_given_seedpoint(thin_slice,[endpoint1;endpoint2],0); %get the sequence of points given endpoints 1 and 2
            sequence_length=size(sequence,1); %identify the length of the current sequence
            pairs(i,:)=[endpoint1 endpoint2 sequence_length]; %populate the pairs array with endpoints and corresponding curve length in terms of points            
        end
        
        lengths=pairs(:,5); %extract lengths column from pairs array
        [max_value,longest_index]=max(lengths); %identify index of longest path, i.e., path between 2 endpoints with largest number of points
        disp('Identified endpoints based on longest path between the 1 endpoint with connectivity=1 and the sets of pixels with connectivity=2');
        ends = [pairs(longest_index,1) pairs(longest_index,2);pairs(longest_index,3) pairs(longest_index,4)];

    else
        if (number_of_indices==2) %only 2 endpoints found
            ends=[thinx(all_end_indices(1)) thiny(all_end_indices(1));thinx(all_end_indices(2)) thiny(all_end_indices(2))];            
        else %more than 2 endpoints  have been identified, i.e., branching exists
            %Check connectivity at each of the identified pixels in the
            %original slice (myslice). Those where connectivity is greater than
            %the minimum (usually 1) are branch endings. Exclude and keep the 2 where connectivity
            %was minimum in myslice.
            disp('More than 2 endpoints found.')
            
            %Traverse entire list of indices, while considering each pair
            %of indices as the 2 endpoints of the curve.
            %Identify the sequential list of points between each of these
            %pairs, and count the number of points. The pair with the
            %longest path, ie largest number of points, will be chosen as
            %the correct pair
            k=1;
            for i=1:number_of_indices-1 %for each index
                j=i;
                while j < number_of_indices %for each pair of indices from index i onwards
                    index1=all_end_indices(i); %identify first index
                    index2=all_end_indices(j+1); %identify second index
                    endpoint1=thin_array(index1,:); %identify corresponding coordinates at these 2 indices
                    endpoint2=thin_array(index2,:);
                    [sequence,ends] = get_sequential_pixels_given_seedpoint(thin_slice,[endpoint1;endpoint2],0); %get the sequence of points given endpoints 1 and 2
                    sequence_length=size(sequence,1); %identify the length of the current sequence
                    pairs(k,:)=[endpoint1 endpoint2 sequence_length]; %populate the pairs array with endpoints and corresponding curve length in terms of points
                    j=j+1; %move to the next pair of indices
                    k=k+1; %increase counter for number of pairs
                end
            end
            
            %Identify the longest of the sequences
            lengths=pairs(:,5); %extract lengths column from pairs array
            [max_value,longest_index]=max(lengths); %identify index of longest path, i.e., path between 2 endpoints with largest number of points
            disp('Identified endpoints based on longest path');
            ends = [pairs(longest_index,1) pairs(longest_index,2);pairs(longest_index,3) pairs(longest_index,4)];            
        end
    end
end

end
