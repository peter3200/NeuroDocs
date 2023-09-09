tSNR Step 2: Surface Projection
===============================

Overview
********

For this step, we will use FreeSurfer functions to project the run tSNR maps to the fsaverage6 surface. This could easily be adapted to the fsaverage or fsaverage5 resolutions, but the resolution does need to be compatible with your parcellation resolution if you wish to average within network boundaries (step 3).

Step 2 Script
*************

To accomplish this, we will use a bash shell script. 

.. code-block:: bash 

    #!/bin/bash
    #Purpose: Project tSNR maps to fsaverage6 surface.
    #Inputs: tSNR maps from Step1, freesurfer native output
    #Outputs: .shape.gii (HCP WB compatible) surface SNR maps
    #Written by M. Peterson, Nielsen Brain and Behavior Lab under MIT License 2022

    #SET PATHS
    CODE_DIR=/fslgroup/fslg_spec_networks/compute/code/HCP_analysis/tSNR/ALL #code directory where this script is housed
    PREP_DIR=/fslgroup/fslg_autism_networks/compute/HCP_analysis/CBIG2016_preproc_FS6_ALL #preproc output directory
    T_DIR=/fslgroup/grp_hcp/compute/HCP_analysis/parc_output_fs6_HCP_ALL/quant_metrics/tSNR #tSNR output directory
    FS_DIR=/fslgroup/grp_proc/compute/HCP_analysis/HCP_download #FreeSurfer recon-all output directory
    SUBJECTS_DIR=${FREESURFER_HOME}/subjects #Set to $FREESURFER_HOME in order to use template fsaverage6 surface

    #LOOP THROUGH EACH SUBJECT AND TASK
    for SUBJ in `cat $CODE_DIR/ids.txt`; do #IDs text file
        for SESS in {1..4}; do #maximum of four sessions per subject
            #BBREGISTER (OBTAIN AFFINE.REG)
            bbregister \
            --bold \
            --s fsaverage6 \
            --init-fsl \
            --mov ${PREP_DIR}/sub-${SUBJ}/sub-${SUBJ}/bold/00${SESS}/sub-${SUBJ}_bld00${SESS}_rest_skip4_mc.nii.gz \
            --reg ${T_DIR}/sub-${SUBJ}_sess-${SESS}_register.dat

            #MRI_VOL2SURF LH 
            mri_vol2surf --mov ${T_DIR}/sub-${SUBJ}_sess-${SESS}_PREPROC_TSNR.nii.gz \
            --reg ${T_DIR}/sub-${SUBJ}_sess-${SESS}_register.dat \
            --hemi lh \
            --projfrac 0.5 \
            --o ${T_DIR}/sub-${SUBJ}_sess-${SESS}_lh.shape.gii \
            --noreshape \
            --interp trilinear

            #MRI_VOL2SURF RH
            mri_vol2surf --mov ${T_DIR}/sub-${SUBJ}_sess-${SESS}_PREPROC_TSNR.nii.gz \
            --reg ${T_DIR}/sub-${SUBJ}_sess-${SESS}_register.dat \
            --hemi rh \
            --projfrac 0.5 \
            --o ${T_DIR}/sub-${SUBJ}_sess-${SESS}_rh.shape.gii \
            --noreshape \
            --interp trilinear

        done
    done

Expected Output
***************

Following the implementation of this script, there should be a LH and RH GIFTI file for each run per participant. 