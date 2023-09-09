tSNR Step 1: tSNR Calculation
=============================

Overview
********

For this step, we are going to use fslmaths from the FSL package to go ahead and calculate the tSNR for each run for each participant. So if a participant has four runs, you can expect a volumetric tSNR output file for each run. Again, the formula for calculating tSNR is the mean BOLD signal across the timeseries divided by the standard deviation of the BOLD signal across the timeseries.

Step 1 Script
*************

To implement fslmaths, we will use a bash shell script. 

.. code-block:: bash 

    #!/bin/bash
    #Purpose: Create SNR maps using fslmaths.
    #Input: CBIG2016 preproc output.
    #Output: SNR maps. 
    #Written by M. Peterson, Nielsen Brain and Behavior Lab under MIT License 2023

    #PATHS:
    CODE_DIR=/fslgroup/fslg_spec_networks/compute/code/HCP_analysis/tSNR/ALL #code directory where this script is
    PREPROC_DIR=/fslgroup/fslg_autism_networks/compute/HCP_analysis/CBIG2016_preproc_FS6_ALL #location of preprocessing output
    OUT_DIR=/fslgroup/grp_hcp/compute/HCP_analysis/parc_output_fs6_HCP_ALL/quant_metrics/tSNR #tSNR output directory
    mkdir -p ${OUT_DIR}

    #LOOP
    for sub in `cat ${CODE_DIR}/ids.txt`; do #subject IDs text file
        for sess in {1..4}; do #assumes a maximum of four runs per participant; adjust to your data
                BOLD_FILE="${PREPROC_DIR}/sub-${sub}/sub-${sub}/bold/00${sess}/sub-${sub}_bld00${sess}_rest_skip4_mc.nii.gz"
                T_FILE="${OUT_DIR}/sub-${sub}_sess-${sess}_PREPROC_TSNR.nii.gz" #name of output file
                MEAN_FILE=${OUT_DIR}/sub-${sub}_sess-${sess}_mean.nii.gz #mean BOLD signal file name
                STD_FILE=${OUT_DIR}/sub-${sub}_sess-${sess}_std.nii.gz #st. dev. BOLD signal file name
                fslmaths ${BOLD_FILE} -Tmean ${MEAN_FILE}
                fslmaths ${BOLD_FILE} -Tstd ${STD_FILE}
                fslmaths ${MEAN_FILE} -div ${STD_FILE} ${T_FILE}
                rm ${MEAN_FILE} #remove intermediate files
                rm ${STD_FILE}	
        done
    done

Expected Output
***************

The output will consist of one tSNR file per run per participant. Intermediate files will be removed as part of the script. 