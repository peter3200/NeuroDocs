Preprocessing Overview
======================

What is preprocessing?
**********************

"Preprocessing" in the context of neuroimaging analyses refers to the set of steps taken prior to model setup and analysis.

Why preprocess neuroimaging data?
*********************************

Neuroimaging data is very noisy--that is, it can be difficult to separate out BOLD signal from artifacts resulting from inhomogeneities in the scanner's magnetic field, physiological signal (heartbeat, respiration), and other issues such as head motion. Thus, the purpose of preprocessing is to remove or ameliorate noise and increase the signal-to-noise ratio. 

What are some general components of preprocessing?
**************************************************

Preprocessing is performed for both anatomical and functional images, and each pipeline is slightly different. Anatomical processing can include bias field correction, skull-striping, segmentation, surface reconstruction, creation of a brain mask, and spatial normalization among others. On the functional processing side, there is registration to a reference T1w image, slice-timing correction, resampling to a standard space (such as fsaverage), head motion correction, physiological regression, component-based noise correction, high-pass filtering, and mask creation. Many of these steps are visually depicted in the fMRIprep `documentation <https://fmriprep.org/en/stable/index.html>`__.

What preprocessing pipelines are available?
*******************************************

At this point in neuroimaging method development, there are many good preprocessing pipelines available. Here are a few options:

1. `fMRIprep <https://fmriprep.org/en/stable/index.html>`__

2. `CBIG2016 <https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/preprocessing/CBIG_fMRI_Preproc2016>`__

3. `ABCD-HCP BIDS <https://github.com/DCAN-Labs/abcd-hcp-pipeline>`__

4. `CCS <https://www.sciencedirect.com/science/article/pii/S2095927316305394?via?3Dihub>`__

How do I choose a preprocessing pipeline?
*****************************************

To make this choice, we recommend considering your data and your eventual analysis--what forms of noise are most salient? Also, you might consider how much you value transparency and reproducibility in science--would you rather select a pipeline that is automated and well-documented or one that is more customizable to better fit the needs of your data? 

You might also consider reading `Moving beyond processing and analysis-related variation in neuroscience` which directly compares the performance of several preprocessing pipelines. `Table 1 <https://www.biorxiv.org/content/10.1101/2021.12.01.470790v1.abstract>`__ is very instructive!

Where can I go to learn more about preprocessing?
*************************************************

* We highly recommend the 2011 Handbook of Functional MRI Data Analysis by Russell A. Poldrack and others. From this handbook, Chapter 3 will be particularly relevant for preprocessing.

* Andy's Brain Book is another excellent resource. See `section #4 <https://andysbrainbook.readthedocs.io/en/latest/fMRI_Short_Course/fMRI_04_Preprocessing.html>`__.
