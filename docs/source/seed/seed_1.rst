Seed-based Analysis Step 1
==========================

Overview
********

For the first step, we will compute a full-surface functional connectivity matrix. This involves correlating every vertex in both the right and left hemispheres with every other vertex. As one can imagine, this makes for a massive correlation matrix!

Full-Surface Correlation
************************

There are four different scripts we will use to (painlessly) create individual jobs for each FC matrix calculation. 

First, we will generate text files containing the paths to the left and right hemisphere surface-projected preprocessing output. You may need to adjust the code if you subjects only have a single session of rs-fMRI data.

.. code-block:: bash

    #!/bin/bash

    # Purpose: Generate text files to create individual vertex-to-vertex FC matrices.
    # Inputs: Surface-projected timeseries (rsfMRI)
    # Outputs: Vertex-to-vertex FC matrices for each individual
    # Written by M. Peterson, Nielsen Brain and Behavior Lab under MITT License 2022

    ##########################
    # Specify paths
    ##########################

    HOME=/fslgroup/fslg_spec_networks/compute
    code_dir=${HOME}/code/MSC_analysis_group/FC_matrices/ALL
    preproc_output=${HOME}/results/MSC_analysis/CBIG2016_preproc_FS6
    out_dir=${HOME}/results/MSC_analysis/parc_output_fs6_MSC_ALL/quant_metrics/FC_matrices
    mkdir -p $out_dir

    #########################################
    # Create data lists
    #########################################

    mkdir -p $out_dir/data_list

    for SUB in ${preproc_output}/*/; do
        sub=`basename "$SUB"`
        for sess in 1 2 3 4 5 6 7 8 9 10; do
            if [ $sess -ne 10 ]; then
            FILE=$preproc_output/${sub}/${sub}/surf/lh.${sub}_bld00${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz

                #if file exists
                if [ -f "$FILE" ]; then
                # fMRI data
                lh_fmri="$preproc_output/${sub}/${sub}/surf/lh.${sub}_bld00${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"

                echo $lh_fmri >> $out_dir/data_list/${sub}_sess-${sess}_LH.txt

                rh_fmri="$preproc_output/${sub}/${sub}/surf/rh.${sub}_bld00${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"

                echo $rh_fmri >> $out_dir/data_list/${sub}_sess-${sess}_RH.txt
                else 
                echo "no $sess $sub"
                fi
            else

            FILE=$preproc_output/${sub}/${sub}/surf/lh.${sub}_bld0${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz
                #check if file exists
                if [ -f "$FILE" ]; then
                lh_fmri="$preproc_output/${sub}/${sub}/surf/lh.${sub}_bld0${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"
            
                echo $lh_fmri >> $out_dir/data_list/${sub}_sess-${sess}_LH.txt

                rh_fmri="$preproc_output/${sub}/${sub}/surf/rh.${sub}_bld0${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"

                echo $rh_fmri >> $out_dir/data_list/${sub}_sess-${sess}_RH.txt
                    else
                    echo "no $sess $sub"
                fi
            fi
        done
    done

The next step is to set up our SLURM job script and individual Matlab scripts, which we will do simultaneously with a wrapper script. This scripts takes advantage of `sed` to replace subject and session variables with the correct values in each individual's set of scripts. 

.. code-block:: bash

    #!/bin/bash

    #Purpose: submit jobs to generate individual full-surface FC matrices

    #Set paths and vars
    HOME=/fslgroup/fslg_spec_networks/compute
    CODE_DIR=${HOME}/code/MSC_analysis_group/FC_matrices/ALL
    PREP_DIR=${HOME}/results/MSC_analysis/CBIG2016_preproc_FS6

    #Submit a job for each sub/sess
    for sub in ${PREP_DIR}/*/; do
        SUB=`basename "$sub"`
        for SES in 1 2 3 4 5 6 7 8 9 10; do
        if [ $SES -ne 10 ]; then
            FILE=$PREP_DIR/${SUB}/${SUB}/surf/lh.${SUB}_bld00${SES}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz
                #if file exists
                if [ -f "$FILE" ]; then

                #make new matlab and job scripts for each sub/sess
                CODE_DIR2=${CODE_DIR}/subj_scripts/${SUB}/ses-${SES}
                mkdir -p ${CODE_DIR2}
            
                #matlab script
                matfile=${CODE_DIR}/FC_matrix_SINGLE.m
                cp ${matfile} ${CODE_DIR2}
            
                sed -i 's|SUB|'"${SUB}"'|g' ${CODE_DIR2}/FC_matrix_SINGLE.m
                sed -i 's|SES|'"${SES}"'|g' ${CODE_DIR2}/FC_matrix_SINGLE.m

                #job script
                jobfile=${CODE_DIR}/FC_matrix_job.sh
                cp ${jobfile} ${CODE_DIR2}
        
                sed -i 's|${SUB}|'"${SUB}"'|g' ${CODE_DIR2}/FC_matrix_job.sh
                sed -i 's|${SES}|'"${SES}"'|g' ${CODE_DIR2}/FC_matrix_job.sh

                #submit job 
                sbatch ${CODE_DIR2}/FC_matrix_job.sh
            else
                echo "no $SES $SUB"
            fi

        else
            FILE=$PREP_DIR/${SUB}/${SUB}/surf/lh.${SUB}_bld0${SES}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz
                #if file exists
                if [ -f "$FILE" ]; then

                #make new matlab and job scripts for each sub/sess
                CODE_DIR2=${CODE_DIR}/subj_scripts/${SUB}/ses-${SES}
                mkdir -p ${CODE_DIR2}
            
                #matlab script
                matfile=${CODE_DIR}/FC_matrix_SINGLE.m
                cp ${matfile} ${CODE_DIR2}
            
                sed -i 's|SUB|'"${SUB}"'|g' ${CODE_DIR2}/FC_matrix_SINGLE.m
                sed -i 's|SES|'"${SES}"'|g' ${CODE_DIR2}/FC_matrix_SINGLE.m

                #job script
                jobfile=${CODE_DIR}/FC_matrix_job.sh
                cp ${jobfile} ${CODE_DIR2}
        
                sed -i 's|${SUB}|'"${SUB}"'|g' ${CODE_DIR2}/FC_matrix_job.sh
                sed -i 's|${SES}|'"${SES}"'|g' ${CODE_DIR2}/FC_matrix_job.sh

                #submit job 
                sbatch ${CODE_DIR2}/FC_matrix_job.sh
            else
                echo "no $SES $SUB"
            fi
    fi
    done
    done


The job script referenced in the wrapper script is as follows.

.. code-block:: bash

    #!/bin/bash

    #SBATCH --time=1:00:00   # walltime
    #SBATCH --ntasks=4   # number of processor cores (i.e. tasks)
    #SBATCH --nodes=1   # number of nodes
    #SBATCH --mem-per-cpu=102400M   # memory per CPU core
    #SBATCH -J "fc_matrix"   # job name

    # Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
    export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

    # LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
    #load CBIG environment
    source /fslgroup/fslg_rdoc/compute/test_scripts/parc_scripts/CBIG_preproc_tested_config_funconn.sh

    #load matlab
    module load matlab/r2018b
    LD_PRELOAD= matlab &
    unset DISPLAY

    #go to subject code dir with individual matlab script
    SUBJ_CODE_DIR=/fslgroup/fslg_spec_networks/compute/code/MSC_analysis_group/FC_matrices/ALL/subj_scripts/${SUB}/ses-${SES}
    cd $SUBJ_CODE_DIR

    #call matlab to run the FC_matrix_SINGLE.m script
    matlab -nodisplay -nojvm -nosplash -r FC_matrix_SINGLE


Finally, the matlab script for each individual job is as follows.

.. code-block:: matlab 

    %Purpose: Implement CBIG_ComputeFullSurfaceCorrelation function
    %Inputs: Text lists for LH and RH data
    %Ouputs: Full surface correlation matrices
    %
    %Written by M. Peterson, Nielsen Brain and Behavior Lab under MIT License 2022

    %Arg structure:  CBIG_ComputeFullSurfaceCorrelation(output_file, varargin_text1, varargin_text2, pval)
    %Instructions: source the CBIG config file, request an salloc job, load matlab/r2018b module, in Matlab run this script

    %1c. Single sub and sess trial run  
    subout='/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/parc_output_fs6_MSC_ALL/quant_metrics/FC_matrices/SUB_sess-SES_fullcorr.mat';
    LH_text='/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/parc_output_fs6_MSC_ALL/quant_metrics/FC_matrices/data_list/SUB_sess-SES_LH.txt';
    RH_text='/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/parc_output_fs6_MSC_ALL/quant_metrics/FC_matrices/data_list/SUB_sess-SES_RH.txt';
    CBIG_ComputeFullSurfaceCorrelation(subout, LH_text, RH_text, '0')




Average Across Runs
*******************

If your subjects have multiple rs-fMRI runs and you would like to compute a single correlation matrix per subject, we can average across functional connectivity matrices.

This code can be implemented in the same way as the single FC matrix code, with a template .m file, a template job script, and a wrapper script. Here is an example template .m script to perform the averaging. 

.. code-block:: matlab 

    % Purpose: Load FC matrices and create an average FC matrix for each participant.
    % Inputs: FC matrices for individual rs-fMRI runs.
    % Outputs: Single averaged FC matrix per individual.
    %
    % Written by M. Peterson, Nielsen Brain and Behavior Lab, under MIT License 2022

    %To run: 
    %	 1. Claim computing resources using salloc (ex: `salloc --mem-per-cpu 300G --time 48:00:00 --x11`)
    %	 2. Load matlab module: `ml matlab/r2018b`
    %	 3. Enter the command `LD_PRELOAD= matlab`


    % Step  1: Create 3D matrix of corr. matrices
    project_dir = '/fslgroup/fslg_spec_networks/compute/results/MSC_analysis/parc_output_fs6_MSC_ALL/quant_metrics/FC_matrices';
    sublist=[ "SUB" ];
    seslist = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "10"];

    for i = sublist
        count=0;
        for ses = seslist
            %Create 3D matrix of all runs for a single subject
            filename=strcat(i,'_sess-',ses,'_fullcorr.mat');
            str = fullfile(project_dir,filename);
            if isfile(str)
                count=(count+1);
                new = load(str);
                if count==1
                    matrix_1 = new.corr_mat; %name of struct for FC matrix
                else    
                    matrix_1 = cat(3,matrix_1,new.corr_mat); 
                end
            else
            end
        end 
        
        %Created the individual-averaged FC matrix
        ind_avg = mean(matrix_1,3);
        file_out = strcat(i,'_avg_FC.mat');
        file_full = fullfile(project_dir,file_out);
        filename = sprintf(file_full, ind_avg);
        save(filename, 'ind_avg', '-v7.3');

        %Step 3: Plot the individual-averaged FC matrix
        %FC_plot = imagesc(ind_avg);
        %image_out = strcat(i,'_avg_FC.png');
        %full_image = fullfile(project_dir,image_out);
        %saveas(FC_plot, full_image, 'png');
    end 


Fisher's Z Transformation
*************************

If normalization is desired, we can transform the Pearson's r correlation values to z-scores using the Fisher's Z transform. In Matlab, this is as simple as adding an additional line of code before writing out the matrix to a .mat file. 

.. code-block:: matlab 

    %Fisher Z Transform
    z = atanh(ind_avg); %where ind_avg is the matrix to be transformed
    
    %Save Z output
    file_out = strcat('sub-', sub,'_avg_FC_FisherZ.mat');
    file_full = fullfile(out_dir,file_out);
    filename = sprintf(file_full, z);
    save(filename, 'z', '-v7.3')

