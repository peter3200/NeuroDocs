Kong2022 Step 3: Generate Individual Parcellations
==================================================

Step 3 Overview 
***************

In this step, we will first generate text lists and then implement the CBIG function to generate the individual parcellations. If you are using the fsaverage6 HCP priors generated by CBIG, then the optimal parameters are c=30 and alpha=30 (see the Kong 2021 supplementary materials p. 17). If you generated your own group priors, you will need to find the greatest homogeneity values and then validate them prior to this step (instructions on the CBIG repo https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/brain_parcellation/Kong2022_ArealMSHBM/examples)

Part 1 Generate Text Files 
**************************

Two bash scripts are used to generate and sort the input text files for Step 3. 

.. code-block:: bash 

    #!/bin/bash

    # This is Step 2.5, which will generate the profile lists for Step 3

    ##########################
    # Specify output directory
    ##########################
    #Edit these
    out_dir=/fslgroup/grp_hcp/compute/HCP_analysis/Kong2022_parc_output_fs6_HCP_ALL
    preproc_output=/fslgroup/fslg_autism_networks/compute/HCP_analysis/CBIG2016_preproc_FS6_ALL
    code_dir=/fslgroup/fslg_spec_networks/compute/code/HCP_analysis/Kong2022_parc_fs6
    max_sess=4

    #Don't edit these
    list_dir=${out_dir}/generate_individual_parcellations/profile_list/test_set
    profile_dir=${out_dir}/generate_profiles_and_ini_params/profiles
    sess_dir=${code_dir}/sess_lists
    grad_dir=${out_dir}/generate_individual_parcellations/gradient_list/test_set
    ########################################
    # Generate profile lists--Step3 Test Set 
    ########################################

    mkdir -p $list_dir $sess_dir $grad_dir

    #1. create list of sessions available for each subject
    for sub in `cat ${code_dir}/subjids/ids.txt`; do
        for sess in {1..4}; do
                FILE=$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess${sess}/\
    lh.sub${sub}_sess${sess}_fsaverage6_roifsaverage3.surf2surf_profile.nii.gz

                #if file exists, add to sub sesslist
                    if [ -f "$FILE" ]; then
                    lh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess${sess}/\
    lh.sub${sub}_sess${sess}_fsaverage6_roifsaverage3.surf2surf_profile.nii.gz"
                    echo $lh_profile >> $sess_dir/sub-${sub}_lh.txt
                            
                    rh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess${sess}/\
    rh.sub${sub}_sess${sess}_fsaverage6_roifsaverage3.surf2surf_profile.nii.gz"
                    echo $rh_profile >> $sess_dir/sub-${sub}_rh.txt

                else
                echo "sess $sess not available"
                fi		
            done

            #add filler lines equal to number of missing sessions to the end of the file
            num_lines=`wc --lines < ${sess_dir}/sub-${sub}_lh.txt`
            filler=`expr $max_sess - $num_lines`
            
            if [ "$filler" -ne 0 ]; then
            for i in $( seq 1 $filler ); do
            filler_message="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess${sess}/\
    rh.sub${sub}_sess11_fsaverage6_roifsaverage3.surf2surf_profile.nii.gz"
            echo $filler_message >> ${sess_dir}/sub-${sub}_lh.txt
            echo $filler_message >> ${sess_dir}/sub-${sub}_rh.txt 
            done
            fi
    done



    #2. RH: if # line exists, add to list# otherwise, dummy line
    for sub in `cat ${code_dir}/subjids/ids.txt`; do
        filename=${sess_dir}/sub-${sub}_rh.txt
        n=1
        while read line; do
            if [ -z "$line" ]; then
            echo "this is a fake line" >> $list_dir/rh_sess${n}.txt
            else
            echo $line >> $list_dir/rh_sess${n}.txt	
            fi
        n=$((n+1))
        done < $filename
    done

    #2. LH
    for sub in `cat ${code_dir}/subjids/ids.txt`; do
        filename=${sess_dir}/sub-${sub}_lh.txt
        n=1
        while read line; do
            if [ -z "$line" ]; then
            echo "this is a fake line" >> $list_dir/lh_sess${n}.txt
            else		
            echo $line >> $list_dir/lh_sess${n}.txt	
            fi
        n=$((n+1))
        done < $filename
        
        #Create gradient lists (each line = subject)
        rh_grad="${out_dir}/generate_gradients/gradients/sub${sub}/rh_emb_100_distance_matrix.mat"
        echo $rh_grad >> ${grad_dir}/gradient_list_rh.txt
        lh_grad="${out_dir}/generate_gradients/gradients/sub${sub}/lh_emb_100_distance_matrix.mat"
        echo $lh_grad >> ${grad_dir}/gradient_list_lh.txt
    done

    echo "Lists successfully generated! Step 2.5 is complete"


.. code-block:: bash 

    #!/bin/bash

    #Purpose: Determine which subjects have which number of runs available and create lists accordingly for MSHBM Step3.
    #Inputs: Generate_data_step_2.5 sess_lists output.
    #Outputs: Text lists with corresponding subjects for each number of sessions. 
    #Written by M. Peterson, Nielsen Brain and Behavior Lab under MIT License 2022.

    #Set paths
    HOME=/fslgroup/fslg_spec_networks/compute
    CODE_DIR=${HOME}/code/HCP_analysis/Kong2022_parc_fs6
    SESS_DIR=${CODE_DIR}/sess_lists_fake
    sess_dir=$SESS_DIR
    NUM_SESS=${CODE_DIR}/sess_numbers
    mkdir -p $SESS_DIR
    mkdir -p $NUM_SESS

    HOME_D=/fslgroup/grp_hcp/compute
    out_dir=${HOME_D}/HCP_analysis/Kong2022_parc_output_fs6_HCP_ALL
    list_dir=${out_dir}/generate_individual_parcellations/profile_list/test_set
    profile_dir=${out_dir}/generate_profiles_and_ini_params/profiles
    code_dir=${HOME}/code/HCP_analysis/Kong2022_parc_fs6

    #create fake sess_list that only includes files that exist
    for sub in `cat ${code_dir}/subjids/ids.txt`; do
        for sess in {1..4}; do
            FILE=$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess${sess}/\
    lh.sub${sub}_sess${sess}_fsaverage6_roifsaverage3.surf2surf_profile.nii.gz

            #if file exists, add to sub sesslist
                if [ -f "$FILE" ]; then
            lh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess${sess}/\
    lh.sub${sub}_sess${sess}_fsaverage6_roifsaverage3.surf2surf_profile.nii.gz"
            echo $lh_profile >> $sess_dir/sub-${sub}_lh.txt
            
            rh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess${sess}/\
    rh.sub${sub}_sess${sess}_fsaverage6_roifsaverage3.surf2surf_profile.nii.gz"
            echo $rh_profile >> $sess_dir/sub-${sub}_rh.txt

            else
            echo "sess $sess not available for sub $sub"
            fi		
    done
    done


    #Grab number of available sessions for each individual
    count=0
    #Loop through each subject
    for sub in `cat ${CODE_DIR}/subjids/ids.txt`; do	
        count=$((count+1))
        #Determine number of sessions for each subj (=length of sess list)
        num_sess=$( cat ${SESS_DIR}/sub-${sub}_lh.txt | wc -l )		

        #Add subject to appropriate list depending on # of sessions
        if [ "$num_sess" -eq 1 ]; then
            echo ${count} >> ${NUM_SESS}/1_sess.txt
        elif [ "$num_sess" -eq 2 ]; then
            echo ${count} >> ${NUM_SESS}/2_sess.txt
        elif [ "$num_sess" -eq 3 ]; then
            echo ${count} >> ${NUM_SESS}/3_sess.txt
        elif [ "$num_sess" -eq 4 ]; then
            echo ${count} >> ${NUM_SESS}/4_sess.txt
        elif [ "$num_sess" -eq 5 ]; then
            echo ${count} >> ${NUM_SESS}/5_sess.txt
        elif [ "$num_sess" -eq 6 ]; then
            echo ${count} >> ${NUM_SESS}/6_sess.txt
        elif [ "$num_sess" -eq 7 ]; then
            echo ${count} >> ${NUM_SESS}/7_sess.txt
        elif [ "$num_sess" -eq 8 ]; then
            echo ${count} >> ${NUM_SESS}/8_sess.txt
        elif [ "$num_sess" -eq 9 ]; then
            echo ${count} >> ${NUM_SESS}/9_sess.txt
        else
            echo ${sub} has 0 sess
        fi

    done


Part 2 Generate Individual Parcellations 
****************************************

Now we can go ahead and implement the CBIG function to generate individual parcellations. First, a list of IDs with 4 runs available is loaded. Then, we loop through each subject and generate the individual parcellation for that subject. Note that this will take longer than the Kong2019 pipeline on account of integrating the gradient matrices (generated in Step 0).

.. code-block:: matlab 

    %Step 3 of CBIG Kong2019 Brain Parc Pipeline
    %
    %To run: 1. Open Matlab using salloc (ex: `salloc --mem-per-cpu 100G --time 2:00:00 --x11`)
    %	 2. source your config file containing the $CBIG_CODE_DIR variable
    %	 3. `cd` to the $CBIG_CODE_DIR/stable_projects/brain_parcellation/Kong2019_MSHBM/step3... folder
    % 	 4. `cp` this script over to the step3 folder in the CBIG repo
    %	 5. Enter the command `ml matlab/r2018b`
    %	 6. Enter the command `LD_PRELOAD= matlab`
    %	 7. In Matlab: Pull up this script and choose "Run" (green button)
    %	
    %For questions, contact M. Peterson, Nielsen Brain and Behavior Lab

    %Note: Using the HCP Priors (FS6 space) from Ruby and CBIG. Per
    %supplementary material for Kong2021 paper, the optimal parameters for the HCP dataset are c=30
    %and alpha=30 (see page 17).

    %% Part 1: Generate individual parcellation for each subject
    %Subs with 4 runs 

    %Read in the subjids text file
        filename = '/nobackup/scratch/grp/fslg_spec_networks/code/HCP_analysis/Kong2022_parc_fs6/sess_numbers/4_sess.txt';
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

    project_dir = '/fslgroup/grp_hcp/compute/HCP_analysis/Kong2022_parc_output_fs6_HCP_ALL/generate_individual_parcellations';
    for subid = 1:length(sublist)
        sub=sublist(subid);
        w='30';
        c='30';
        beta='5';
        [lh_labels, rh_labels] = CBIG_ArealMSHBM_gMSHBM_generate_individual_parcellation(project_dir,'fsaverage6','4','400',num2str(subid),w,c,beta,'test_set');
    end
    


    %Troubleshooting help
    %
    %Error: using fgets
    %   In this case, your data_list/validation_fMRI_set txt files are off
    %   somewhere. They should be named consecutively (even if the subjids in
    %   their contents are not). 
    %
    %Error: fscanf cannot open... 
    %	In this case, your paths somewhere are incorrect. Doublecheck your paths in the generate_profiles_and_ini_params/data_list/fMRI. Also, your project_dir could be incorrect
    %
    %Error: CBIG_MSHBM_estimate_group_params function not found (or something like that)
    %	You need to be in the step2 folder to run this script. If you are in a different directory, you will encounter this error.It may help to copy this script over to the step2 directory and then open matlab...
    %
    %Error: Error using mtimesx Inner matrix dimensions must agree.
    %   Paths in your data_list/validation_fMRI text files are incorrect
    %   Paths in your profile_list/validation_set are incorrect and lead to
    %   preproc instead of step1 profiles

Expected Output 
***************

Output can be found in $project_dir/generate_individual_parcellations/ind_parcellation_gMSHBM/test_set/4_sess/beta5 and files will be named Ind_parcellation_MSHBM_sub*_w30_MRF30_beta5.mat. 

.. note:: The subject name in the output corresponds with the line number on the input text lists and is not the actual subject ID. 

