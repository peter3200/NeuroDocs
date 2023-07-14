CBIG2016 Preproc Step 1
========================

Overview
********

During Step 0, we cloned the CBIG repo and configured our environment to be functional with CBIG pipelines in general. Now we are ready to get things setup to run the CBIG2016 preprocessing pipeline. For Step 1, we will set up the specific configuration for preprocessing, create the necessary text files containing paths to the BOLD runs, and run FreeSurfer's recon-all surface reconstruction on the anat files.

Preproc Config File 
*******************

The config file for the preprocessing pipeline specifies which steps we would like to take and in what order. Here is what our config file looks like:

.. code-block:: bash 

    ###CBIG fMRI preprocessing configuration file
    ###The order of preprocess steps is listed below
    CBIG_preproc_skip -skip 4
    ### Caution: Change your slice timing file based on your data !!! The example slice timing file is a fake one.
    #CBIG_preproc_fslslicetimer -slice_timing ${CBIG_CODE_DIR}/stable_projects/preprocessing/CBIG_fMRI_Preproc2016/example_slice_timing.txt
    CBIG_preproc_fslmcflirt_outliers -FD_th 0.2 -DV_th 50 -force -discard-run 50 -rm-seg 5 

    ### Caution: In the case of spatial distortion correction using opposite phase encoding directions, please change the path of j- and j+ image accordingly. If the voxel postion increases from posterior to anterior (for example, RAS, LAS orientation), j+ corresponds to PA and j- corresponds to AP direction.
    ### Total readout time (trt), effective echo spacing (ees) and echo time (TE) should be based on your data!!!
    #CBIG_preproc_spatial_distortion_correction -fpm oppo_PED -j_minus <j_minus_image_path> -j_plus <j_plus_image_path> -j_minus_trt 0.04565 -j_plus_trt 0.04565 -ees .000690017 -te 0.0344

    CBIG_preproc_bbregister
    CBIG_preproc_regress -whole_brain -wm -csf -motion12_itamar -detrend_method detrend -per_run -polynomial_fit 1
    #CBIG_preproc_censor -max_mem NONE
    CBIG_preproc_bandpass -low_f 0.009 -high_f 0.08 -detrend 
    CBIG_preproc_QC_greyplot -FD_th 0.2 -DV_th 50
    CBIG_preproc_native2fsaverage -proj fsaverage6 -sm 6
    CBIG_preproc_FC_metrics -Pearson_r
    CBIG_preproc_native2mni_ants -sm_mask ${CBIG_CODE_DIR}/data/templates/volume/FSL_MNI152_masks/SubcorticalLooseMask_MNI1mm_sm6_MNI2mm_bin0.2.nii.gz -final_mask ${FSL_DIR}/data/standard/MNI152_T1_2mm_brain_mask_dil.nii.gz

Create fmrinii.txt
******************

The next part of our setup involves create fmrinii.txt files for each participant, listing the BOLD runs for that subject and their paths. To do this we will use the get_individual_subjects.sh script:

.. code-block:: bash

    #!/bin/bash

    # Set your paths here
    code_DIR=/fslgroup/fslg_spec_networks/compute/code/CBIG2016_preproc
    data_DIR=/fslgroup/fslg_spec_networks/compute/data/BIDS_compliant

    # Put all of your subjects into a text file  
    #/bin/ls -1 ${data_DIR} > ${code_DIR}/subjids.txt

    # Create that special CBIG subjids text file for each subject (data must be in BIDS format)
    # CBIG example format: 001 /fslhome/NETID/Downloads/CBIG_Data/Sub0001/func/Sub0001_Ses1.nii
    # Ideal for running subjects parallel
    # Change the path of the first for loop to be your code_DIR

    counter=0
    for subj in sub-AA0002 sub-AA0004; do
	for SES in ${data_DIR}/${subj}/ses-*/; do
	ses=`basename "$SES"`
		for i in ${data_DIR}/${subj}/${ses}/func/${subj}_${ses}_task-inscapes*bold.nii.gz; do
		counter=$((counter+1))
		(echo 00$counter ${i}) >> ${data_DIR}/${subj}/${subj}_fmrinii.txt
		done
	    done
    counter=0
    done

.. note:: This script works best with BIDS-formatted data.

For reference, the fmrinii.txt file will look something like the following: 

.. code-block:: bash 

    001 /fslgroup/fslg_spec_networks/compute/data/BIDS_compliant/sub-AA0002/ses-1/func/sub-AA0002_ses-1_task-inscapes_run-1_bold.nii.gz
    002 /fslgroup/fslg_spec_networks/compute/data/BIDS_compliant/sub-AA0002/ses-1/func/sub-AA0002_ses-1_task-inscapes_run-2_bold.nii.gz
    003 /fslgroup/fslg_spec_networks/compute/data/BIDS_compliant/sub-AA0002/ses-2/func/sub-AA0002_ses-2_task-inscapes_run-1_bold.nii.gz
    004 /fslgroup/fslg_spec_networks/compute/data/BIDS_compliant/sub-AA0002/ses-3/func/sub-AA0002_ses-3_task-inscapes_run-1_bold.nii.gz
    005 /fslgroup/fslg_spec_networks/compute/data/BIDS_compliant/sub-AA0002/ses-4/func/sub-AA0002_ses-4_task-inscapes_run-1_bold.nii.gz

FreeSurfer Output
*****************

An additional prerequisite for this pipeline is the output from FreeSurfer's ``recon-all`` pipeline. In an ideal world with plenty of computing power, fMRIprep would have been ran previously and we could use the FreeSurfer output that comes as part of the fMRIprep processing pipeline. However, if this is not the case, you can run FreeSurfer as its own job:

.. code-block:: bash 

    ## FREESURFER JOB SCRIPT
    
    #!/bin/bash

    #SBATCH --time=45:00:00   # walltime
    #SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
    #SBATCH --nodes=1   # number of nodes
    #SBATCH --mem-per-cpu=16384M  # memory per CPU core
    #SBATCH -J "FS_R9"   # job name


    # Compatibility variables for PBS. Delete if not needed.
    export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
    export PBS_JOBID=$SLURM_JOB_ID
    export PBS_O_WORKDIR="$SLURM_SUBMIT_DIR"
    export PBS_QUEUE=batch

    # Set the max number of threads to use for programs using OpenMP.
    export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

    # LOAD ENVIRONMENTAL VARIABLES
    export FREESURFER_HOME=/fslhome/mpeter55/compute/research_bin/freesurfer
    source $FREESURFER_HOME/SetUpFreeSurfer.sh

    # INSERT CODE, AND RUN YOUR PROGRAMS HERE
    genDir=/fslgroup/fslg_autism_networks/compute
    codeDir=${genDir}/code/freesurfer
    dataDir=${genDir}/data

    ~/compute/research_bin/freesurfer/bin/recon-all \
    -subjid ${1} \
    -i ${dataDir}/sub-${1}/anat/sub-${1}_T1w_resampled.nii.gz \
    -wsatlas \
    -all \
    -sd ${dataDir}/sub-${1}/anat

The adjacent wrapper script would look something like the following:

.. code-block:: bash

    #!/bin/bash
    genDir=/fslgroup/fslg_autism_networks/compute
    codeDir=${genDir}/code/freesurfer
    dataDir=${genDir}/data/

    normal=${codeDir}/subjids/${release}_T1.txt

    for subj in `cat ${normal}`; do
	sbatch \
	    -o ~/logfiles/HBN_FS2/output_${subj}.txt \
	    -e ~/logfiles/HBN_FS2/error_${subj}.txt \
	    ${codeDir}/freesurfer_job.sh \
	    ${subj}
	    sleep 1
    done

A Note About Filestructure 
**************************

Not completely unexpected, CBIG scripts are strict about maintaining an *implied* filestructure. For the preprocessing pipeline, BIDS structure for input /anat and /func files is required. If you run into errors, this is also a good place to start--chances are that your filestructure is not organized according the scripts' implied requirements.

Addendum for Spatial Distortion Correction
******************************************

Just a quick note about how to perform spatial distortion correction using this pipeline.

1. Edit the config file to include fieldmaps, TRT, EES, and TE values. Fieldmaps need to be mag+phasediff or oppPED (j, j-). 

.. note:: Use sidecar .json files to identify a fieldmap's phase-encoding direction. 
    
Fieldmaps that aren’t a single volume each will result in a "datain.txt error". The function `topup` requires that the datain.txt file contains one line per volume. So, if your fieldmap has more than one volume, you may need to run `topup`` by hand and then restart the job. 
