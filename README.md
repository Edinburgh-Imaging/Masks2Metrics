# Masks2Metrics (M2M)

Copyright (C) 2017 S. Mikhael, 26 June 2017
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. For more details see the license.txt file and <http://www.gnu.org/licenses>.

## What is M2M for?

Masks2Metrics (M2M) is a Matlab based tool that is used to calculate 3 metrics for a given region-of-interest (ROI) in a 3D image: thickness, volume and suface area. While many software exist to compute such metric automatically, it is also needed to compare the results from automated software with manually traced ROI. The current software take such manually traced ROI and compute the metrics automatically.

We (the author and contributors) use M2M to compute those metrics on images coming out of a Magnetic Resonance Imaging (MRI) machine. The ROI are defined by paired of masks (in nifti format) defining the inner and outer borders of the ROI, and they are drawn continuously along one direction (x-, y- or z-axis). For the special case of brain images, if the ROI describes a gyrus, the paired masks would be the corresponding grey matter (GM) and white matter curves (WM). Paired ROI nifti (.nii) masks are expected to be of the form subj_roi_hem_gm/wmsegments.nii. An example of a pair corresponding to subject 1 right SFG (superior frontal gyrus would be 1_sfg_r_gm1.nii and 1_sfg_r_wm1.nii. A special feature of M2M is that multiple segments can be used rather than a single continuous ROI (see wiki help). The ROI metrics outputted are grey matter thickness (GMth), grey matter volume (GMvol),and white matter surface area (WMsa).

## Installation instructions

Download M2M into a folder called Masks2Metrics. In addition to the Masks2Metrics code, the folder includes external code that is called by the tool, including Nifti Matlab tools and pre-existing distance code (Frechet and the Modified Hausdorff Distance).
Add the Masks2Metrics folder and subfolders to your list of Matlab paths - to start call masks2metrics

## Authors
Shadia Mikhael, Neuroimaging Sciences, Centre for Clinical Brain Sciences, University of Edinburgh, Edinburgh, UK.
Calhum Gray, Clinical Research Imaging Centre, University of Edinburgh, Edinburgh, UK.  

## Contributors
Maria del C. Valdés Hernández, Neuroimaging Sciences, Centre for Clinical Brain Sciences, University of Edinburgh, Edinburgh, UK.  
Corne, Hoogendoorn, Toshiba Medical Visualization Systems Edinburgh, Edinburgh, UK  
Cyril R. Pernet, Neuroimaging Sciences, Centre for Clinical Brain Sciences, University of Edinburgh, Edinburgh, UK.  



