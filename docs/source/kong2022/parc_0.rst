Kong2022 Step 0: Generate Gradients
===================================

Overview
********

Unlike the Kong2019 pipeline, the 2022 pipeline begins with the generation of gradients before generating individual connectivity profiles. These gradients (specifically diffusion embedding matrices of gradients) are used to inform the gradient prior. 

To generate these gradients, we will first create the text files used as input for steps 0 and 1. Then, we will go to MATLAB and implement the generate gradients function.

Part 1 Generate Text Files
**************************

The following bash shell script generates text files to be used as input for steps 0 and 1. It is assumed that your code directory contains an ids.txt file. 

.. code-block:: bash 

    #!/bin/bash

    # This is Step 0: Generate Input Data and setup file folder structures.
    # Run this before CBIG Parc Step 0 and 1.
    # Additionally, the preproc data was formatted sub-0#. Adjust the script as necessary to fit your naming conventions.

    ##########################
    # Specify output directory
    ##########################

    code_dir=/fslgroup/fslg_spec_networks/compute/code/HCP_analysis/Kong2022_parc_fs6 #location of present script
    out_dir=/fslgroup/grp_hcp/compute/HCP_analysis/Kong2022_parc_output_fs6_HCP_ALL #output directory
    preproc_output=/fslgroup/fslg_autism_networks/compute/HCP_analysis/CBIG2016_preproc_FS6_ALL #preprocessing output directory

    gradient_dir=${out_dir}/generate_gradients
    mkdir -p $out_dir/estimate_group_priors
    mkdir -p $out_dir/generate_individual_parcellations
    mkdir -p $gradient_dir

    # Add the $CBIG_CODE_DIR to your environment
    source ${code_dir}/CBIG_preproc_tested_config_funconn.sh

    #########################################
    # Create data lists for /generate_profiles (step 1)
    #########################################

    mkdir -p $gradient_dir/data_list/fMRI_list $gradient_dir/data_list/censor_list
    mkdir -p $out_dir/generate_profiles_and_ini_params/data_list/fMRI_list
    mkdir -p $out_dir/generate_profiles_and_ini_params/data_list/censor_list

    for sub in `cat ${code_dir}/subjids/ids.txt`; do #assumes that you have a text file containing subject IDs
        for sess in {1..4}; do  #assumes a maximum of four runs per subjects. Edit this to reflect the maximum number of runs
        if [ $sess -ne 10 ]; then
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
            
        else

        # fMRI data
            lh_fmri="$preproc_output/\
    sub-${sub}/sub-${sub}/surf/\
    lh.sub-${sub}\
    _bld0${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"
            
            echo $lh_fmri >> $out_dir/generate_profiles_and_ini_params/data_list/fMRI_list/lh_sub${sub}_sess${sess}.txt
            
            rh_fmri="$preproc_output/\
    sub-${sub}/sub-${sub}/surf/\
    rh.sub-${sub}\
    _bld0${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"
            
            echo $rh_fmri >> $out_dir/generate_profiles_and_ini_params/data_list/fMRI_list/rh_sub${sub}_sess${sess}.txt
            
            # censor list
            censor_file="${preproc_output}/sub-${sub}/sub-${sub}/qc/sub-${sub}\
    _bld0${sess}_FDRMS0.2_DVARS50_motion_outliers.txt"
            
            echo $censor_file >> $out_dir/generate_profiles_and_ini_params/data_list/censor_list/sub${sub}.txt

        fi
        done
    done

    ##########################################
    #Create Data Lists for /generate_gradients (step 0)
    ##########################################

    for sub in `cat ${code_dir}/subjids/ids.txt`; do
        count=0
        for sess in {1..4}; do
        if [ $sess -ne 10 ]; then
            FILE=$preproc_output/sub-${sub}/sub-${sub}/surf/lh.sub-${sub}_bld00${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz
            if [ -f "$FILE" ]; then
            count=$((count+1))
            # fMRI data
            lh_fmri="$preproc_output/\
    sub-${sub}/sub-${sub}/surf/\
    lh.sub-${sub}\
    _bld00${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"
            
            echo $lh_fmri >> $gradient_dir/data_list/fMRI_list/lh_sub${sub}_sess${count}.txt
            
            rh_fmri="$preproc_output/\
    sub-${sub}/sub-${sub}/surf/\
    rh.sub-${sub}\
    _bld00${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"
            
            echo $rh_fmri >> $gradient_dir/data_list/fMRI_list/rh_sub${sub}_sess${count}.txt
            
            # censor list
            censor_file="${preproc_output}/sub-${sub}/sub-${sub}/qc/sub-${sub}\
    _bld00${sess}_FDRMS0.2_DVARS50_motion_outliers.txt"
            
            echo $censor_file >> $gradient_dir/data_list/censor_list/sub${sub}_sess${count}.txt
            
            else
            echo ""
            fi
        else

            FILE=$preproc_output/sub-${sub}/sub-${sub}/surf/lh.sub-${sub}_bld0${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz
            if [ -f "$FILE" ]; then
            count=$((count+1))
            # fMRI data
            lh_fmri="$preproc_output/\
    sub-${sub}/sub-${sub}/surf/\
    lh.sub-${sub}\
    _bld0${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"
            
            echo $lh_fmri >> $gradient_dir/data_list/fMRI_list/lh_sub${sub}_sess${count}.txt
            
            rh_fmri="$preproc_output/\
    sub-${sub}/sub-${sub}/surf/\
    rh.sub-${sub}\
    _bld0${sess}_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz"
            
            echo $rh_fmri >> $gradient_dir/data_list/fMRI_list/rh_sub${sub}_sess${count}.txt
            
            # censor list
            censor_file="${preproc_output}/sub-${sub}/sub-${sub}/qc/sub-${sub}\
    _bld0${sess}_FDRMS0.2_DVARS50_motion_outliers.txt"
            
            echo $censor_file >> $gradient_dir/data_list/censor_list/sub${sub}_sess${count}.txt
            else
            echo ""
            fi

        fi
        done
    done

    echo "Step 0 was successful!"

Part 2 Generate Gradients
*************************

After the input text files have been generated, we can go to MATLAB and run the CBIG function CBIG_ArealMSHBM_generate_gradient. After setting the project directory variable, we read in the ids.txt file used previously. Next, we loop through each subject, determine how many runs are available for a given subject, and generate the gradient matrix based on the number of available runs. This is computationally intensive and may require multiple days to complete serially.

.. code-block:: matlab 

    %Step 0 of CBIG Kong2022 Brain Parc Pipeline
    %
    %To run: 1. Open Matlab using salloc (ex: `salloc --mem-per-cpu 200G --time 2:00:00 --x11`)
    %	 2. source your config file containing the $CBIG_CODE_DIR variable
    %	 	-It might be helpful to `cd` to the $CBIG_CODE_DIR/stable_projects/brain_parcellation/Kong2019_MSHBM/step1... folder
    % 	 3. Enter the command `ml matlab/r2018b`
    %	 4. Enter the command `LD_PRELOAD= matlab`
    %	 5. In Matlab: pull up this script and choose "Run"
    %
    %FYI, the data_list/fMRI_list lists should be formatted sub01_sess1, etc (such that there are no dashes or spaces between "sub" and "01" or "sess" and "1"
    %
    %Previously, recon-all and the CBIG preproc pipeline were run on these subjects. 
    %Additionally, you must have the folder structure and text files with paths to your preproc output set up 
    %See the CBIG example script CBIG_MSHBM_create_example_input_data.sh for details on formatting.
    %The script "Create_parc_data.sh" has taken care of this.
    %
    %For questions, contact M. Peterson, Nielsen Brain and Behavior Lab

    %Set tmpdir
        clear all
        setenv('TMPDIR','/fslgroup/fslg_spec_networks/compute/results/tmp');

    %Part 1: Generate gradients
    project_dir = '/fslgroup/grp_hcp/compute/HCP_analysis/Kong2022_parc_output_fs6_HCP_ALL/generate_gradients';

    %Read in the subjids text file
        filename = '/nobackup/scratch/grp/fslg_spec_networks/code/HCP_analysis/Kong2022_parc_fs6/subjids/230413_ids.txt';
        delimiter = {''};
        % Format for each line of text:
        %   column1: text (%s)
        % For more information, see the TEXTSCAN documentation.
        formatSpec = '%s%[^\n\r]';
        % Open the text file.
        fileID = fopen(filename,'r');
        % Read columns of data according to the format.
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
        % Close the text file.
        fclose(fileID);
        sublist = [dataArray{1:end-1}];
        clearvars filename delimiter formatSpec fileID dataArray ans;

    for subid = 1:length(sublist)
        sub=sublist(subid);
        %Count number of text files that start with sub string
        filedir = strcat(project_dir, '/data_list/fMRI_list');
        code_dir=pwd;
        cd ( filedir )
        file = dir('*.txt');
        filenames = {file.name};
        sess = sum( ~cellfun(@isempty, strfind(filenames, sub)) )/2;
        cd ( code_dir )
        %Generate gradients on that number of sessions
        CBIG_ArealMSHBM_generate_gradient('fsaverage6', project_dir, sub, num2str(sess));
    end

    %Troubleshooting help
    %
    %Error: fscanf cannot open... 
    %	In this case, your paths somewhere are incorrect. Doublecheck your paths in the generate_profiles_and_ini_params/data_list/fMRI. Also, your project_dir could be incorrect
    %   Also, the format of the data_list/fMRI_list text files names may be
    %   incorrect
    %
    %Error: CBIG_MSHBM_generate_gradients function not found (or something like that)
    %	You need to be in the step0 folder to run this script. If you are in a different directory, you will encounter this error.It may help to copy this script over to the script1 directory and then open matlab...

.. note:: As an alternative to this serial computing MATLAB script, consider using the set of batch scripts found on GitHub at https://github.com/peter3200/NeuroDocs/tree/main/example_data/Kong2022/parc_step_0. This will greatly reduce the amount of time needed for this step (since gradients will be generated in parallel). For a single subject witih four 15-minute runs of data, Step 0 takes approximately 23 minutes.

Step 0 Output 
*************

The resulting output can be found in $project_dir/generate_gradients/gradients/$SUBJID. The files that will be used further in the pipeline are the lh_emb_100_distance_matrix.mat and rh_emb_100_distance_matrix.mat files.