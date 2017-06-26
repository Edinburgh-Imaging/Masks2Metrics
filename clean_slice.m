%% This function cleans a slice by eliminating all remaining nonzero pixels
%% with connectivity equal to 0. This may be the case when a line has some
%% thickness to it or when there are extra voxels in a slice that aren't
%% connected to others.

% Inputs: 
%   myslice: matrix representing pixel values of the current slice
%   dim: dimensions of current slice

% Output:
%   cleaned_slice: a cleaned version of myslice, i.e., this version exludes
%   any pixels with connectivity 0

function cleaned_slice = clean_slice(myslice,dim)

%if slice dimensions are valid
if (dim(1) > 0 && dim(2) > 0)
    %search entire slice for nonzero pixels with connectivity equal to 0
    for x=1:dim(2)
        for y=1:dim(1)
            %if pixel value is nonzero, check its connectivity
            if (myslice(y,x) ~= 0)
                connectivity_xy = connectivity(x,y,myslice,dim);
                %if this pixel's connectivity is zero, then zero it out
                if (connectivity_xy == 0) 
                    myslice(y,x)=0; %zero out this point
                end
            end
        end
    end
    cleaned_slice=myslice;
end

