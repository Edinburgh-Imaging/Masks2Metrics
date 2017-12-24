# Masks2Metrics (M2M)

Copyright (C) 2017 S. Mikhael and C. Gray.

## Table of Contents
- [What is M2M for](#M2M)  
- [License](#License)
- [Installation Instructions](#Installation)  
- [Getting Started](#Start)  
- [Authors](#Authors)
- [Contributors](#Contributors)
- [Contributing](#Contributing)  
- [Code of Conduct](#CoC)  
- [Road Map](#RoadMap)  

## What is M2M for? <a name="M2M"></a>

Masks2Metrics (M2M) is a Matlab based tool that is used to calculate 3 metrics for a given region-of-interest (ROI) in a 3D image: thickness, volume and suface area. While many software packages that automatically compute such metrics exist, it is also necessary to compare the results from automated software with manually-traced ROIs. The current software takes such manually-traced ROIs and computes the metrics automatically.

We (the authors and contributors) use M2M to compute those metrics on images acquired by a Magnetic Resonance Imaging (MRI) machine. The ROI is defined by pairs of 3-dimensional (3D) binary masks (in NIfTI format) that represent the inner and outer borders of the ROI, and are drawn continuously along one direction (x-, y- or z-axis). For the special case of brain images, if the ROI describes a gyrus, the paired masks would be the corresponding grey matter (GM) and white matter curves (WM). Paired ROI NIfTI (.nii) masks are expected to be of the form subj_roi_hem_gm/wmsegments.nii. An example of a pair corresponding to subject 1 right superior frontal gyrus (SFG) would be 1_sfg_r_gm1.nii and 1_sfg_r_wm1.nii. A special feature of M2M is that multiple segments can be used rather than a single continuous ROI (see Wiki help). The ROI metrics calculated are grey matter thickness (GMth), grey matter volume (GMvol),and white matter surface area (WMsa).

## License <a name="License"></a>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License, the license.txt file, and <http://www.gnu.org/licenses> for more details.

## Installation Instructions <a name="Installation"></a>

Download M2M into a folder called Masks2Metrics. In addition to the Masks2Metrics code, the folder includes external code that is called by the tool, including a NIfTI Matlab tools and pre-existing distance code (Euclidean, Fréchet and the Modified Hausdorff Distance).

## Getting Started <a name="Start"></a>
1. Add the Masks2Metrics folder and subfolders to your list of Matlab paths. 
2. To calculate your ROI's metrics call the function <code>'masks2metrics'</code> with the appropriate parameters. 

For more details, please refer to our _[Wiki](https://github.com/Edinburgh-Imaging/Masks2Metrics/wiki)_. It includes a _[short tutorial](https://github.com/Edinburgh-Imaging/Masks2Metrics/wiki/Short-tutorial)_ demonstrating how the tool can be used as well as a _[workflow](https://github.com/Edinburgh-Imaging/Masks2Metrics/wiki/Workflow)_ highlighting communication between all functions.

## Authors <a name="Authors"></a>
Shadia Mikhael, Edinburgh Imaging, Centre for Clinical Brain Sciences, University of Edinburgh, Edinburgh, UK.  
Calum Gray, Edinburgh Imaging and Edinburgh Clinical Research Facility, University of Edinburgh, Edinburgh, UK.  

## Contributors <a name="Contributors"></a>
Maria del C. Valdés Hernández, Edinburgh Imaging, Centre for Clinical Brain Sciences, University of Edinburgh, Edinburgh, UK.  
Corne, Hoogendoorn, Toshiba Medical Visualization Systems Edinburgh, Edinburgh, UK.  
Cyril R. Pernet, Edinburgh Imaging, Centre for Clinical Brain Sciences, University of Edinburgh, Edinburgh, UK.  

## Contributing <a name="Contributing"></a>
See [CONTRIBUTING](CONTRIBUTING.md)

## Code of Conduct <a name="CoC"></a>
See [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md)

## Roadmap <a name="RoadMap"></a>
Coming soon
  <a name="Summary"></a>
