CBIG2016 Preproc Step 2
========================

Overview
********
For this step of processing, we are going to submit the CBIG2016 preprocessing jobs (1 per subject) using a wrapper script as follows:

Job Script 
**********

The job script will look something like this:
.. code-block:: bash 
    #!/bin/bash

    #SBATCH --time=20:00:00   # walltime
    #SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
    #SBATCH --nodes=1   # number of nodes
    #SBATCH --mem-per-cpu=51250M   # memory per CPU core
    #SBATCH -J "preproc"   # job name

    # Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
    export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

    #Load git and matlab modules
    ml git/2.14
    ml matlab/r2018b
    LD_PRELOAD= matlab &
    unset DISPLAY

    #Set paths! ADD YOUR NETID: 
    code_Dir=/fslgroup/fslg_spec_networks/compute/code/ind_parc/CBIG2016_preproc
    CBIG_Dir=/fslgroup/fslg_rdoc/compute/CBIG
    out_Dir=/fslgroup/fslg_spec_networks/compute/results/CBIG2016_preproc_FS6
    subj=$1
    subj_Dir=/fslgroup/fslg_spec_networks/compute/results/fmriprep_results/fmriprep/${subj}
    #fs_Dir=/fslgroup/fslg_spec_networks/compute/results/fmriprep_results/freesurfer
    mkdir -p ${out_Dir}

    # 'source' -> YOUR <- config script (with software paths)
    source /fslgroup/fslg_spec_networks/compute/code/ind_parc/CBIG2016_preproc/CBIG_preproc_tested_config_funconn.sh

    # Run the preprocessing pipeline
    ${CBIG_Dir}/stable_projects/preprocessing/CBIG_fMRI_Preproc2016/CBIG_preproc_fMRI_preprocess.csh \
        -s ${subj} \
        -output_d ${out_Dir}/${subj} \
        -anat_s ${subj} \
        -anat_d ${subj_Dir}/anat \
        -fmrinii ${subj_Dir}/${subj}_fmrinii.txt \
        -config ${code_Dir}/example_config.txt 

A few things to note about the flags in the last section of the job script ('Run the preprocessing pipeline'). 

`-s` Refers to the subject name (designated in the wrapper script)
`-output_d` Currently set to produce output in /path/to/output/${subj}/${subj}
`-anat_s` The name of the Freesurfer output directory for the subject (named after the subject in this case)
`-anat_d` The path to the Freesurfer output 
`-fmrinii` The path and name of the fmrinii.txt files created in Step 1
`-config` The path an dname of the config file created in Step 1.

Wrapper Script
**************
The wrapper script will look something like the following: 

.. code-block:: bash
    #!/bin/bash

    code_DIR=/fslgroup/fslg_spec_networks/compute/code/ind_parc/CBIG2016_preproc
    output_DIR=/fslgroup/fslg_spec_networks/compute/results/CBIG2016_preproc_FS6

    #Change this first line to your code_DIR pointing to the subjids file
    for subj in sub-AA0002 sub-AA0004; do
        mkdir -p ${code_DIR}/logfiles
        sbatch \
        -o ${code_DIR}/logfiles/output_${subj}.txt \
        -e ${code_DIR}/logfiles/error_${subj}.txt \
        ${code_DIR}/preproc_job.sh \
        ${subj}
        sleep 1
    done

This script will submit a preproc job for each subject listed in the first line of the for loop. If there is a large amount of subjects, consider changing the first line to: "for subj in `cat ${code_dir}/subjids.txt`; do" and include a subjids.txt file containing the needed subject IDs within ${code_dir}.
