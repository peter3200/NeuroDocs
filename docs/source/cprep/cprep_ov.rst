CBIG2016 Preprocessing Overview
===============================

What is preprocessing?
**********************

"Preprocessing" in the context of neuroimaging analyses refers to the set of steps taken prior to model setup and analysis.

Why preprocess neuroimaging data?
*********************************

Neuroimaging data is very noisy--that is, it can be difficult to separate out BOLD signal from artifacts resulting from inhomogeneities in the scanner's magnetic field, physiological signal (heartbeat, respiration), and other issues such as head motion. Thus, the purpose of preprocessing is to remove or ameliorate noise and increase the signal-to-noise ratio. 

Why Use the CBIG2016 Pipline?
*****************************

* Closely follow the processing steps used to implement the multi-session hierarchical Bayesian modeling parcellation method (Kong et al., 2019). 
* Tedana multi-echo EPI integration

CBIG2016 Preprocessing Pipeline Steps
*************************************

This pipeline includes the following steps:

* Motion correction (respiratory pseudomotion filtering)
* Spatial distortion correction
* Multi-echo denoising
* Intra-subject registration between T1 and T2* images
* Nuisance regression
* Temporal interpolation of censored frames
* Bandpass filtering (recommendation of bandpass censoring)
* Projections to standard surface & volumetric spaces
* Functional connectivity (FC) matrix computation for 419 ROIs

Complete documentation for this pipeline can be found on the `CBIG Github Site <https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/preprocessing/CBIG_fMRI_Preproc2016>`__.

Prerequisites for the CBIG2016 Pipeline
***************************************

* NIFTI-formatted images (see our `dcm2niix guide <https://neurodocs.readthedocs.io/en/latest/preproc/prep1.html>`__)
* Freesurfer recon-all (this is performed as part of the `fMRIprep pipeline <https://neurodocs.readthedocs.io/en/latest/preproc/prep2.html>`__)
