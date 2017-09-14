# Masks2Metrics (M2M)
Please read the license.txt file before proceeding. 

Masks2Metrics (M2M) is a tool that can be used to calculate 3 metrics for a given region-of-interest (ROI). The ROI must be defined by paired nii masks, and drawn continuously along one direction (x-, y- or z-axis). In the case of the ROI being a gyrus, the paired masks would be the corresponding grey matter (GM) and white matter curves (WM).

Paired ROI nifti (.nii) masks are expected to be of the form subj_roi_hem_gm/wmsegments.nii. An example of a pair corresponding to subject 1 right SFG (superior frontal gyrus would be 1_sfg_r_gm1.nii and 1_sfg_r_wm1.nii.

The ROI metrics outputted are grey matter thickness (GMth), grey matter volume (GMvol),and white matter surface area (WMsa).

Author: Shadia Mikhael, Neuroimaging Sciences, Centre for Clinical Brain Sciences, University of Edinburgh, Edinburgh, UK.
