---
title: 'Masks2Metrics (M2M): A Matlab Toolbox for Gold Standard Morphometrics'
tags:
  - example
  - tags
  - for the paper
authors:
 - name: Shadia Mikhael
   orcid: 
   affiliation: 1
 - name: Calum Gray
   affiliation: 1,2
affiliations:
 - name: Edinburgh Imaging, The Chancellor’s Building, 1st floor, FU303e, 49 Little France Crescent, Edinburgh, Scotland, UK, EH16 4SB.
   index: 1
 - name: Edinburgh Clinical Research Facility, University of Edinburgh, Edinburgh, UK.
   index: 2
date: 20 October 2017
bibliography: paper.bib
---


# Summary

Human brains undergo morphometric changes over a lifetime, from conception through to birth, infancy, adolescence, adulthood, and old age (@Thambisetty_2012; @Madan_2016). This is further compounded by the changes associated with various brain pathologies such as tumours (e.g. @Bauer_2013) and dementia (e.g., @Dickerson_2011). It is therefore essential to accurately and scientifically characterise such changes by using an array of morphologic measurements, for a better understanding of the natural progression of ageing and disease (@Mills_2016; @Madan_2017). While many existing brain image analysis tools (e.g., FreeSurfer (@Fischl_2004; @Desikan_2006), BrainSuite (@Shattuck_2002), and BrainVISA (@Kochunov_2012)) automatically compute such data from a 3-dimensional (3D) brain image, they lack the ability to do so for the equivalent manually-traced regions of interest (ROIs). This is all the more significant as such ROIs are considered as the gold standard, thus making knowledge of their metrics essential.


We have developed an automated Matlab-based tool, Masks2Metrics (@Mikhael_2017), that calculates three metrics for a given ROI in a 3D image: thickness, volume and suface area. An ROI is defined by a pair of masks (in NIfTI file format) representing its outer and inner borders, each of which are drawn continuously along one direction (x-, y- or z-axis). In the specific case of brain images, when the ROI describes a gyrus, its paired masks would correspond to grey matter (GM) and white matter (WM) curves. The paired ROI NIfTI (.nii) masks are expected to be of the form subj_roi_hem_gm/wmsegments.nii. For example, a pair corresponding to subject 1's right SFG (superior frontal gyrus) would be 1_sfg_r_gm1.nii and 1_sfg_r_wm1.nii. A special feature of M2M is that multiple pairs, or segments, can be used rather than a single continuous ROI. These segments can be manually or automatically derived. The generated ROI metrics are grey matter thickness (GMth), grey matter volume (GMvol),and white matter surface area (WMsa), also classically calculated by popular existing automated tools (Fischl_2000; Shattuck_2002) . Additionally, the ROI's corresponding mean Fréchet(@Ursell_2013) and mean Modified Hausdorff Distance (@SasiKanth_2011) are calculated and saved as matrices.


M2M is freely available on GitHub at https://github.com/Edinburgh-Imaging/Masks2Metrics under a GNU General Public License, along with external code that is called by the tool. It can be downloaded into 'Masks2Metrics' folder, added to the list of Matlab paths, and consequently run by calling 'masks2metrics' with the appropriate input and output parameters. As part of the tool's wiki, we provide a sample 3-segment ROI outlining part of a subject's superior frontal gyrus for demonstration purposes. The gyrus was manually segmented over a 3D image acquired by a Magnetic Resonance Imaging (MRI) machine. 

This tool not only provides invaluable gold standard data for the brain imaging field, but equally so for any other field investigating morphometrics of manually and automatically-derived 3D ROIs represented as paired masks.



# Authors and Affiliations
Shadia Mikhael, Edinburgh Imaging, Centre for Clinical Brain Sciences, University of Edinburgh, Edinburgh, UK.  
Calum Gray, Edinburgh Imaging and Edinburgh Clinical Research Facility, University of Edinburgh, Edinburgh, UK.  


# Contributors
Maria del C. Valdés Hernández, Edinburgh Imaging, Centre for Clinical Brain Sciences, University of Edinburgh, Edinburgh, UK.  
Corne, Hoogendoorn, Toshiba Medical Visualization Systems Edinburgh, Edinburgh, UK.  
Cyril R. Pernet, Edinburgh Imaging, Centre for Clinical Brain Sciences, University of Edinburgh, Edinburgh, UK.  

#References
