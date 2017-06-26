% Matlab function to read header information from NIFTI files. Header information taken from the
% official defintion (http://nifti.nimh.nih.gov/pub/dist/src/niftilib/nifti1.h).
%
% MEB 20/08/2008

function header=nifti_hread(filename);

fid=fopen([filename,'.nii'],'r');
header.sizeof_hdr=fread(fid,1,'int32');				% Must be 348
header.data_type=char(fread(fid,[1,10],'char'));		% Unused
header.db_name=char(fread(fid,[1,18],'char'));			% Unused
header.extents=fread(fid,1,'int32');				% Unused
header.session_error=fread(fid,1,'int16');			% Unused
header.regular=char(fread(fid,1,'char'));			% Unused
header.dim_info=char(fread(fid,1,'char'));			% MRI slice ordering	

header.dim=fread(fid,[1,8],'int16');				% Data array dimensions
header.intent_p1=fread(fid,1,'float');				% Intent parameters
header.intent_p2=fread(fid,1,'float');
header.intent_p3=fread(fid,1,'float');

header.intent_code=fread(fid,1,'int16');			% NIFTI intent code
header.datatype=fread(fid,1,'int16');				% Defines data type! 
header.bitpix=fread(fid,1,'int16');				% Number bits/voxel
header.slice_start=fread(fid,1,'int16');			% First slice index
header.pixdim=fread(fid,8,'float32');				% Grid spacings
header.vox_offset=fread(fid,1,'float');				% Offset into .nii file

header.scl_slope=fread(fid,1,'float');				% Data scaling: slope
header.scl_inter=fread(fid,1,'float');				% Data scaling: offset
header.slice_end=fread(fid,1,'int16');				% Last slice index
header.slice_code=char(fread(fid,[1,1],'char'));		% Slice timing order
header.xyzt_units=char(fread(fid,[1,1],'char'));		% Units of pixdim[1..4]

header.cal_max=fread(fid,1,'float');
header.cal_min=fread(fid,1,'float');
header.slice_duration=fread(fid,1,'float');			% Time for 1 slice
header.toffset=fread(fid,1,'float');
header.glmax=fread(fid,1,'int32');				% Unused
header.glmin=fread(fid,1,'int32');				% Unused
header.descrip=char(fread(fid,[1,80],'char'));			% Any text
header.aux_file=char(fread(fid,[1,24],'char'));			% Auxiliary filename
header.qform_code=fread(fid,1,'int16');
header.sform_code=fread(fid,1,'int16');
header.quatern_b=fread(fid,1,'float');
header.quatern_c=fread(fid,1,'float');
header.quatern_d=fread(fid,1,'float');
header.qoffset_x=fread(fid,1,'float');
header.qoffset_y=fread(fid,1,'float');
header.qoffset_z=fread(fid,1,'float');
header.srow_x=fread(fid,[1,4],'float');				% Affine transformation
header.srow_y=fread(fid,[1,4],'float');
header.srow_z=fread(fid,[1,4],'float');
header.intent_name=char(fread(fid,[1,16],'char'));		% Name or meaning of data
header.magic=char(fread(fid,[1,4],'char'));			% Must be "ni1\0" or "n+1\0"
header.extension=char(fread(fid,[1,4],'char'));			% All elements should be set to zero
fclose(fid);
