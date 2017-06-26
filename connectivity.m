%% This function identifies connectivity for a pixel (2D) in a given slice
%% based on all 8 voxels around it. Connectivity (con) can range from 0 to
%% 8).

function con = connectivity(x,y,slice,dim)

%Inputs: 
%     x: x-coordinate of pixel being checked for 8-pt connectivity
%     y: y-coordinate of pixel being checked for 8-pt connectivity
%     slice: binary matrix of the current slice with pixel (x,y) in it 
%     dim: dimensions of slice 

% Output:
%     con: number of pixels to which pixel (x,y) is connected based on
%     8-point connectivity


%Initializing variables
i=1; j=1;
con=0;

%Check if the pixel out of slice range
if ((x < 0) | (x > size(slice,2)) | (y < 0) | (y > size(slice,1)))
    disp(['Point ' num2str(x) ',' num2str(y) ' is out of range'])
    return;
end

%Checking connectivity of pixel (x,y) by identifying the 8 pixels around it, 
%in a clockwise direction and looking at the intensity value of each. 
%For each nonzero pixel it finds, the variable 'con' is incremented by 1.

%Checking 1st point's connectivity (x+1,y)
xtemp=x+1; ytemp=y;
%if not past the edge of the slice, then check intensity value
if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
    if (slice(ytemp,xtemp)~=0)
        con = con + 1;
    end
end


%Checking 2nd point's connectivity (x+1,y+1)
xtemp=x+1; ytemp=y+1;
%if not past the edge of the slice, then check intensity value
if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
    if (slice(ytemp,xtemp)~=0)
        con = con + 1;
    end
end


%Checking 3rd point's connectivity (x,y+1)
xtemp=x; ytemp=y+1;
%if not past the edge of the slice, then check intensity value
if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
    if (slice(ytemp,xtemp)~=0)
        con = con + 1;
    end
end


%Checking 4th point's connectivity (x-1,y+1)
xtemp=x-1; ytemp=y+1;
%if not past the edge of the slice, then check intensity value
if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
    if (slice(ytemp,xtemp)~=0)
        con = con + 1;
    end
end


%Checking 5th point's connectivity (x-1,y)
xtemp=x-1; ytemp=y;%if not past the edge of the slice, then check intensity value
if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
    if (slice(ytemp,xtemp)~=0)
        con = con + 1;
    end
end


%Checking 6th point's connectivity (x-1,y-1)
xtemp=x-1; ytemp=y-1;
%if not past the edge of the slice, then check intensity value
if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
    if (slice(ytemp,xtemp)~=0)
        con = con + 1;
    end
end


%Checking 7th point's connectivity (x,y-1)
xtemp=x; ytemp=y-1;
%if not past the edge of the slice, then check intensity value
if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
    if (slice(ytemp,xtemp)~=0)
        con = con + 1;
    end
end


%Checking 8th point's connectivity (x+1,y-1)
xtemp=x+1; ytemp=y-1;
%if not past the edge of the slice, then check intensity value
if ((xtemp > 0) && (ytemp > 0) && (xtemp <= dim(2)) && (ytemp <= dim(1)))
    if (slice(ytemp,xtemp)~=0)
        con = con + 1;
    end
end

end