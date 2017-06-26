% Matlab function to read NIfTI volume files.
%
% Prototype [data,dim,vox,type]=read_nifti_volume(filename);
%
% where data:		volume data
%	dim:		image dimensions
%	vox:		voxel dimensions
%	filename:	filename
%	type:		image type
%
% MEB 20/08/2008

function [data,dim,vox,type]=read_nifti_volume(filename);

% Read NIfTI header information
header=nifti_hread(filename);
dim=([header.dim(2) header.dim(3) header.dim(4) header.dim(5)]);
vox=([header.pixdim(2) header.pixdim(3) header.pixdim(4) header.pixdim(5)]);

% Setup data type
switch header.datatype
 case 1
  type='uint1';
 case 2
  type='uint8';
 case 4
  type='short';
 case 8
  type='int';
 case 16
  type='float';
 case 64
  type='double';
 otherwise
  ['Unsure what data type ...']
  return;
end

% Read data
fid=fopen([filename,'.nii'],'r');
fseek(fid,header.vox_offset,'bof');		% 348 byte header plus 4 bytes
if dim(4) ~= 1
 for j=1:dim(4)
  for i=1:dim(3)
   data(:,:,i,j)=fread(fid,[dim(1) dim(2)],type);
  end
 end
else
 for i=1:dim(3)
  data(:,:,i)=fread(fid,[dim(1) dim(2)],type);
 end
end
fclose(fid);
