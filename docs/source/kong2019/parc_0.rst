Kong2019 Parc Step 0
====================

This is a preparatory step in which we will generate text files for Step 1. These text files will include the paths to the left and right hemisphere preprocessed BOLD output for each session of each subject. You will thus need to know the path to your CBIG2016 preprocessed outputs.

Scripting
*********

This is a simple step with only one script! Hooray! 

.. code-block:: bash 

    #!/bin/bash

    # This is Step 0: Generate Input Data and setup file folder structures.
    # Run this before CBIG Parc Step 1.
    # Additionally, the preproc data was formatted sub-0#. Adjust the script as necessary to fit your naming conventions.


    ##########################
    # Specify output directory
    ##########################

    HOME=/fslgroup/fslg_spec_networks/compute
    D_HOME=/fslgroup/fslg_HBN_preproc/compute
    code_dir=${HOME}/code/HCPD_analysis/Kong2019_parc_fs6
    out_dir=${D_HOME}/HCPD_analysis/parc_output_fs6_HCPD
    preproc_output=${D_HOME}/HCPD_analysis/CBIG2016_preproc_FS6
    mkdir -p $out_dir/estimate_group_priors
    mkdir -p $out_dir/generate_individual_parcellations

    # Add the $CBIG_CODE_DIR to your environment
    source ${code_dir}/CBIG_preproc_tested_config_funconn.sh

    #########################################
    # Create data lists to generate profiles
    #########################################

    mkdir -p $out_dir/generate_profiles_and_ini_params/data_list/fMRI_list
    mkdir -p $out_dir/generate_profiles_and_ini_params/data_list/censor_list

    for sub in `cat ${code_dir}/subjids.txt`; do
        for sess in 1 2 3; do
        # fMRI data
            lh_fmri="$preproc_output/\
    sub-${sub}/sub-${sub}/surf/\
    lh.sub-${sub}\
    _bld00${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"
            
            echo $lh_fmri >> $out_dir/generate_profiles_and_ini_params/data_list/fMRI_list/lh_sub${sub}_sess${sess}.txt
            
            rh_fmri="$preproc_output/\
    sub-${sub}/sub-${sub}/surf/\
    rh.sub-${sub}\
    _bld00${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"
            
            echo $rh_fmri >> $out_dir/generate_profiles_and_ini_params/data_list/fMRI_list/rh_sub${sub}_sess${sess}.txt
            
            # censor list
            censor_file="${preproc_output}/sub-${sub}/sub-${sub}/qc/sub-${sub}\
    _bld00${sess}_FDRMS0.2_DVARS50_motion_outliers.txt"
            
            echo $censor_file >> $out_dir/generate_profiles_and_ini_params/data_list/censor_list/sub${sub}.txt
        done
    done


    echo "Step 0 was successful!"

    # You are now ready to run Step 1!

Explanation
***********

In the first section of code, we are setting up our paths to the code directory ($code_dir), the parcellation output directory ($out_dir), and the CBIG2016 preproc output directory ($preproc_output). After that, we are going to create the file structure needed for the parcellation output. 

The following section is going to do the heavy lifting and generate the data lists needed for Step 1. This portion of code begins by making additional directories for the data lists within the overall parcellation output folder. Next, we are going to loop through each subject in a subject IDs text file. It is assumed in the subject IDs text file that the subjects do not have the prefix 'sub-'. Next, we set up the loop for each session. If your data does not have multiple BOLD runs, remove this loop.

Within the for loops, we will `echo` the paths and file names of the preprocessed BOLD runs into LH and RH text files. The names of these text files must be ?h_sub${sub}_sess${sess}.txt for Step 1 to find them. Notice that there is also a censor file that contains the volumes that exceed the motion thresholds set in the preprocessing pipeline. Step 1 will skip the volumes found in the censor list.

.. note:: Even if your subjects have different numbers of sessions, we will generate the same number of session text files for each subject. If a particular session doesn't exist, Step 1 will just skip over that session. 

Once the data lists are generated, we can proceed to Step 1!
