Kong2022 Step 2: Group Priors
=============================

Step 2 Overview 
***************

As in the Kong2019 pipeline, group priors are incorporated into the algorithm to shape network boundaries. To avoid circularity, these priors should be generated using a separate set of subjects than those for whom individual parcellations are being generated. 

In the Kong et al. 2021 article introducing Areal MS-HBM, the authors note that priors can be effectively applied to data with different acquisition parameters. As such, it is recommended that users implement the group priors pre-calculated by CBIG, which are available in the fs_LR 32K and fsaverage6 resolutions (generated on 40 HCP subjects). 

For the purposes of this tutorial, the fsaverage6 400 parcel priors will be used (https://github.com/ThomasYeoLab/CBIG/blob/master/stable_projects/brain_parcellation/Kong2022_ArealMSHBM/lib/group_priors/HCP_fs_LR_32k_40sub/400/gMSHBM/beta50/Params_Final.mat).

If you desire to generate your own priors, please see the CBIG instructions on GitHub (https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/brain_parcellation/Kong2022_ArealMSHBM/examples).

Copy Priors (and Spatial Mask)
******************************

In Step 1, a spatial mask based on the Schaefer 2018 parcellation was generated, which needs to be copied over to the $project_dir/generate_individual_parcellations folder. To copy the spatial mask and priors, see the following bash script. 

.. code-block:: bash 

    #!/bin/bash

    #Purpose: Copy priors and spatial masks in preparation for Kong2022 parc step3
    #Inputs: Spatial masks from step1
    #Outputs: Priors and spatial masks ready

    #PATHS
    PARC=/fslgroup/grp_hcp/compute/HCP_analysis/Kong2022_parc_output_fs6_HCP_ALL #project_dir
    CBIG_DIR=/fslgroup/fslg_rdoc/compute/CBIG #CBIG repo directory

    #COPY SPATIAL MASKS
    cp -r ${PARC}/generate_profiles_and_ini_params/spatial_mask ${PARC}/generate_individual_parcellations

    #COPY PRIORS
    CBIG_PRIORS=${CBIG_DIR}/stable_projects/brain_parcellation/Kong2022_ArealMSHBM/examples/ref_results/estimate_group_priors/priors/gMSHBM/beta5/Params_Final.mat
    mkdir -p ${PARC}/generate_individual_parcellations/priors/gMSHBM/beta5
    cp ${CBIG_PRIORS} ${PARC}/generate_individual_parcellations/priors/gMSHBM/beta5

    #MESSAGE
    echo "Ready for Step3"


