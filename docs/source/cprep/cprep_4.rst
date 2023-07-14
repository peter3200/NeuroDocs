CBIG2016 Preproc: Tedana Integration
====================================

Purpose
*******

Multi-echo EPI data are different from their single-echo counterparts in a fundamental way: three or more images per volume are acquired at echo times spanning tens of milliseconds. This results in a couple of specific benefits: 1) Echoes can be integrated into a single time-series with improved BOLD contrast and less susceptibility artifact via weighted averaging, and 2) the way in which signals decay across echoes can be used to inform denoising (Lynch et al., 2021). Ultimately, through this multi-echo acquisiton process, you end up with a greater signal-to-noise ratio than with single-echo data.

In order to take advantage of these properties, the CBIG2016 pipeline allows for the integration of tedana (see DuPre et al., 2021). tedana creates a weighted sum of individual echoes and then denoises the data using a multi-echo ICA-based denoising method. In addition to incorporating Tedana, consider altering your CBIG2016 preproc configuration to remove steps rendered unnecessary by multi-echo acquisition, such as bandpass filtering (as suggested by Kundu et al., 2017).

Configuring CBIG2016 Preproc with Tedana
****************************************

0. Install the tedana python module and dependencies.

.. code-block:: bash 

    ml python/3.6
    pip install --user nilearn
    pip install --user nibabel
    pip install --user numpy
    pip install --user scikit-learn
    pip install --user scipy
    pip install --user tedana

Or, install and activate the `CBIG python environment <https://github.com/ThomasYeoLab/CBIG/tree/master/setup/python_env_setup#quick-installation-for-linux>`__`

1. Set up your config file. The biggest change is the addition of CBIG_preproc_multiecho_denoise and the removal of bandpass filtering. Note that echo time must be in milliseconds, separated by commas in ascending order.

.. code-block:: bash
    ###CBIG fMRI preprocessing configuration file
    ###The order of preprocess steps is listed below
    ###Change: swap bandpass and regress order, regress_new (use BOLD_stem as MASK_stem), per_run, detrend (not trendout), censor
    CBIG_preproc_skip -skip 4
    ### Caution: Change your slice timing file based on your data !!! The example slice timing file is a fake one.
    #CBIG_preproc_fslslicetimer -slice_timing ${CBIG_CODE_DIR}/stable_projects/preprocessing/CBIG_fMRI_Preproc2016/example_slice_timing.txt
    CBIG_preproc_fslmcflirt_outliers -FD_th 0.2 -DV_th 50 -force -discard-run 50 -rm-seg 5 

    ### Caution: In the case of spatial distortion correction using opposite phase encoding directions, please change the path of j- and j+ image accordingly. If the voxel postion increases from posterior to anterior (for example, RAS, LAS orientation), j+ corresponds to PA and j- corresponds to AP direction.
    ### Total readout time (trt), effective echo spacing (ees) and echo time (TE) should be based on your data!!!

    #CBIG_preproc_spatial_distortion_correction -fpm oppo_PED -j_minus <j_minus_image_path> -j_plus <j_plus_image_path> -j_minus_trt 0.04565 -j_plus_trt 0.04565 -ees .000690017 -te 0.0344
    #Echo-times as follows come from King et al. (2018) based on the Utah dataset
    CBIG_preproc_multiecho_denoise -echo_time 12.4,34.28,56.16 
    CBIG_preproc_bbregister
    CBIG_preproc_regress -wm -csf -motion12_itamar -detrend_method detrend -per_run -polynomial_fit 1
    #CBIG_preproc_censor -max_mem NONE
    #CBIG_preproc_bandpass -low_f 0.009 -high_f 0.08 -detrend 
    CBIG_preproc_QC_greyplot -FD_th 0.2 -DV_th 50
    CBIG_preproc_native2fsaverage -proj fsaverage6 -sm 6 -down fsaverage6
    #CBIG_preproc_FC_metrics -Pearson_r
    #CBIG_preproc_native2mni_ants -sm_mask ${CBIG_CODE_DIR}/data/templates/volume/FSL_MNI152_masks/SubcorticalLooseMask_MNI1mm_sm6_MNI2mm_bin0.2.nii.gz -final_mask ${FSL_DIR}/data/standard/MNI152_T1_2mm_brain_mask_dil.nii.gz

2. Set up your job and wrapper scripts per usual (see `Step 2 <https://neurodocs.readthedocs.io/en/latest/cprep/cprep_2.html>`__).

.. note:: Theoretically, the only differences resulting from using tedana should be limited to the configuration file. However, we found that the preproc jobs randomly failed on the tedana step for some subjects. This was easily fixed by restarting the pipeline on that step (see step 3).

3. In the case where you need to restart your multi-echo job, use the following wrapper and job scripts to just restart the tedana step.

The tedana resetart wrapper script is first. 
 .. code-block:: bash
    #!/bin/bash

    #Purpose Submit tedana restart script for each subject
    #Written by M. Peterson, Nielsen Brain and Behavior Lab

    #PATHS
    CODE_DIR=/fslgroup/fslg_spec_networks/compute/code/Utah_analysis/CBIG2016_preproc_ALL

    for subj in `cat ${CODE_DIR}/subjids/preproc_failed_ids2.txt`; do
        mkdir -p ${CODE_DIR}/subject_scripts/${subj}
        cp ${CODE_DIR}/tedana_preproc.sh ${CODE_DIR}/subject_scripts/${subj}
        
        #replace subject with subject name
        sed -i 's|${subj}|'"${subj}"'|g' ${CODE_DIR}/subject_scripts/${subj}/tedana_preproc.sh
        
        source ${CODE_DIR}/subject_scripts/${subj}/tedana_preproc.sh
    done

This is followed by the job script. 
.. code-block:: bash
    #!/bin/bash

    #Purpose Run CBIG2016 preprocessing for multi-echo data. Restarts the Tedana command and remainder of the preproc.
    #Written by M. Peterson, Nielsen Brain and Behavior Lab

    #PATHS
    HOME=/fslgroup/fslg_spec_networks/compute
    CODE_DIR=${HOME}/code/Utah_analysis/CBIG2016_preproc_ALL
    OUT_DIR=/fslgroup/grp_proc/compute/Utah_analysis/CBIG2016_preproc_FS6 #preproc output
    mkdir -p ${CODE_DIR}/subject_scripts/${subj}

    #STEP 1 Tedana Processing
        source ${CODE_DIR}/CBIG_preproc_tested_config_funconn.sh
        #grab tedana command from CBIG preproc log file
        sed -n '/CBIG_preproc_multiecho_denoise]/p' ${OUT_DIR}/${subj}/${subj}/logs/CBIG_preproc_fMRI_preprocess.log >> ${CODE_DIR}/subject_scripts/${subj}/tedanacommand.txt

        #remove first three lines in order to isolate the command
        sed -i '1d' ${CODE_DIR}/subject_scripts/${subj}/tedanacommand.txt
        sed -i '1d' ${CODE_DIR}/subject_scripts/${subj}/tedanacommand.txt
        sed -i '1d' ${CODE_DIR}/subject_scripts/${subj}/tedanacommand.txt

        #remove the last line of the file
        sed -i '2d' ${CODE_DIR}/subject_scripts/${subj}/tedanacommand.txt

        #remove the first handful of characters that preceed the command	
        sed -r 's/.{34}//' ${CODE_DIR}/subject_scripts/${subj}/tedanacommand.txt > ${CODE_DIR}/subject_scripts/${subj}/tedanacommand2.txt

        #run the command
        sh ${CODE_DIR}/subject_scripts/${subj}/tedanacommand2.txt


    #STEP 2 Restart the Preproc

        #Submit the job script for the subject (as if this script is a wrapper)
            mkdir -p ${CODE_DIR}/logfiles
            sbatch \
            -o ${CODE_DIR}/logfiles/output_${subj}.txt \
            -e ${CODE_DIR}/logfiles/error_${subj}.txt \
            ${CODE_DIR}/preproc_job.sh \
            ${subj}
            sleep 5


References
**********

* DuPre, E., Salo, T., Ahmed, Z., Bandettini, P. A., Bottenhorn, K. L., Caballero-Gaudes, C., Dowdle, L. T., Gonzalez-Castillo, J., Heunis, S., Kundu, P., Laird, A. R., Markello, R., Markiewicz, C. J., Moia, S., Staden, I., Teves, J. B., Uruñuela, E., Vaziri-Pashkam, M., Whitaker, K., & Handwerker, D. A. (2021). TE-dependent analysis of multi-echo fMRI with tedana. Journal of Open Source Software, 6(66), 3669. https://doi.org/10.21105/joss.03669
* Kundu, P., Voon, V., Balchandani, P., Lombardo, M. V., Poser, B. A., & Bandettini, P. A. (2017). Multi-echo fMRI: a review of applications in fMRI denoising and analysis of BOLD signals. Neuroimage, 154, 59–80.
* Lynch, C. J., Elbau, I., & Liston, C. (2021). Improving precision functional mapping routines with multi-echo fMRI. Current Opinion in Behavioral Sciences, 40, 113–119. https://doi.org/10.1016/j.cobeha.2021.03.017