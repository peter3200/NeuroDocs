Kong2019 Parc Step 3
====================

This step is a little more complicated than those previously described for this pipeline. But you can do it! As a general overview, we will generate text lists containing the paths to the LH and RH profiles generated in Step 1, identify the number of available sessions for each participant, and then generate the individual parcellations!

Generate Text Lists 
*******************

For this step, we are going to jump right in the code!

.. code-block:: bash 

    #!/bin/bash
    # This is Step 2.5, which will generate the profile lists for Step 3

    ##########################
    # Specify output directory
    ##########################

    HOME=/fslgroup/fslg_spec_networks/compute #code home
    code_dir=${HOME}/code/HCPD_analysis/Kong2019_parc_fs6 #code directory

    HOME_D=/fslgroup/fslg_HBN_preproc/compute #data home
    out_dir=${HOME_D}/HCPD_analysis/parc_output_fs6_HCPD #parc output directory
    preproc_output=${HOME_D}/HCPD_analysis/CBIG2016_preproc_FS6 #preproc output directory

    profile_dir=${out_dir}/generate_profiles_and_ini_params/profiles #do not edit
    list_dir=${out_dir}/generate_individual_parcellations/profile_list/test_set #do not edit
    sess_dir=${code_dir}/sess_lists #do not edit

    ########################################
    # Generate profile lists--Step3 Test Set 
    ########################################

    mkdir -p $list_dir $sess_dir 

    #1. create list of sessions available for each subject
    for sub in `cat ${code_dir}/subjids.txt`; do
        for sess in 1 2 3 4 5 6 7 8 9; do  #include maximum number of sessions available for each subject
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

            #add filler lines equal to number of missing sessions to the end of the file
            num_lines=`wc --lines < ${sess_dir}/sub-${sub}_lh.txt`
            max_sess=9 #maximum number of sessions available for each subject
            filler=`expr $max_sess - $num_lines`
            
            if [ "$filler" -ne 0 ]; then
            for i in $( seq 1 $filler ); do
            filler_message="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess${sess}/\
    rh.sub${sub}_sess11_fsaverage6_roifsaverage3.surf2surf_profile.nii.gz" #note this is an imaginary "sess11"
            echo $filler_message >> ${sess_dir}/sub-${sub}_lh.txt
            echo $filler_message >> ${sess_dir}/sub-${sub}_rh.txt 
            done
            fi
    done


    #2. RH: if # line exists, add to list# otherwise, dummy line
    for sub in `cat ${code_dir}/subjids.txt`; do
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
    for sub in `cat ${code_dir}/subjids.txt`; do
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
    done

    echo "Lists successfully generated! Step 2.5 is complete."

As you might have noticed, this script is composed of two main parts: #1 Creation of a session list for each subject (RH and LH) in the $code_dir and #2 Creation of the official Parcellation Step 3 session lists. I will address each part separately. 

For #1 of the script, we are going to loop through each subject in a subjids.txt file located in the $code_dir and then loop through each session for that subject. If the profile exists (in fsaverage6 resolution; change if in a different resolution), then the line is added to the text file. After looping through all of the sessions, we will then read the text file and add filler lines equal to number of missing sessions to the end of the file. 

For #2 of the script, we are going to create a set of text files for each subject within the $code_dir -- for both the RH and LH. These files will read the text files created in #1 and read each line--if the line exists, then it will stick the line in the $list_dir for use in Parcellation Step 3. If the line does not exist, then a dummy line will be placed in the Parcellation Step 3 list. The dummy line is needed to maintain contiguity across the session lists for Step 3-- the line number within the text file signals which subject the parcellation is calling, so if each subject has a different number of sessions, then without the dummy line, the parcellation code could bring up files from different subjects to compute an individual parcellation (not desired).  

Identify Number of Available Sessions 
*************************************

For this next script, we are going to generate text files that will lead us to the number of sessions available for each subject. This is important for Parcellation Step 3, which requires us to indicate how many sessions to draw on for a given subject when computing the individual parcellations. 

.. code-block:: bash 

    #!/bin/bash

    #Purpose: Determine which subjects have which number of runs available and create lists accordingly for MSHBM Step3.
    #Inputs: Generate_data_step_2.5 sess_lists output.
    #Outputs: Text lists with corresponding subjects for each number of sessions. 
    #Written by M. Peterson, Nielsen Brain and Behavior Lab under MIT License 2022.

    #Set paths
    HOME=/fslgroup/fslg_spec_networks/compute #code directory 
    CODE_DIR=${HOME}/code/HCPD_analysis/Kong2019_parc_fs6 #parcellation code directory
    code_dir=${CODE_DIR}
    SESS_DIR=${CODE_DIR}/sess_lists_fake #do not edit
    sess_dir=$SESS_DIR 
    NUM_SESS=${CODE_DIR}/sess_numbers #do not edit; folder for text files indicating number of available sessions
    mkdir -p $SESS_DIR
    mkdir -p $NUM_SESS

    HOME_D=/fslgroup/fslg_HBN_preproc/compute #output home directory
    out_dir=${HOME_D}/HCPD_analysis/parc_output_fs6_HCPD #parcellation output directory
    preproc_output=${HOME_D}/HCPD_analysis/CBIG2016_preproc_FS6 #preproc output directory
    list_dir=${out_dir}/generate_individual_parcellations/profile_list/test_set #do not edit
    profile_dir=${out_dir}/generate_profiles_and_ini_params/profiles #do not edit
    
    #1
    #create fake sess_list that only includes files that exist
    for sub in `cat ${code_dir}/subjids.txt`; do
        for sess in 1 2 3 4 5 6 7 8 9; do
            FILE=$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess${sess}/\
    lh.sub${sub}_sess${sess}_fsaverage6_roifsaverage3.surf2surf_profile.nii.gz #assumes fsaverage6 resolution

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

    #2
    #Grab number of available sessions for each individual
    count=0
    #Loop through each subject
    for sub in `cat ${CODE_DIR}/subjids.txt`; do	
        count=$((count+1))
        #Determine number of sessions for each subj (=length of sess list)
        num_sess=$( cat ${SESS_DIR}/sub-${sub}_lh.txt | wc -l )		

        #Add subject to appropriate list depending on # of sessions (= number of lines in file)
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

Once again, this script is divided into two main parts: #1 Create a session list that only consists of available profiles for each subject and #2 Use those files to find the number of available runs for each subject and compile those together (e.g., all subjects with only 1 run end up in 1_sess.txt).

To break this down further, in #1, we are looping through each subject in $code_dir/subjids.txt and each session within that subject. We are then identifying whether those profiles were created in Parcellation Step 1 and then adding them to a subject-specific text file in the $code_dir. 

For #2 of this script, we are looping through each subject in $code_dir/subjids.txt and finding the number of lines in that text file (each line equals 1 session of data). That subject ID is then added to a text file corresponding the number of session available. 

Step 3 - Individual Parcellation 
********************************

For this step, we are going to use Matlab within an `salloc` job. 

Here is the script header, where we given instructions for using the script and explain where our optimal parameters came from.

.. code-block:: matlab 

    %Step 3 of CBIG Kong2019 Brain Parc Pipeline
    %
    %To run: 1. Open Matlab using salloc (ex: `salloc --mem-per-cpu 6G --time 2:00:00 --x11`)
    %	 2. source your config file containing the $CBIG_CODE_DIR variable
    %	 3. `cd` to the $CBIG_CODE_DIR/stable_projects/brain_parcellation/Kong2019_MSHBM/step3... folder
    % 	 4. `cp` this script over to the step3 folder in the CBIG repo
    %	 5. Enter the command `ml matlab/r2018b`
    %	 6. Enter the command `LD_PRELOAD= matlab`
    %	 7. In Matlab: Pull up this script and choose "Run" (green button)
    %	
    %
    %Previously, recon-all and the CBIG preproc pipeline were run on these subjects. 
    %Additionally, you must have the folder structure and text files with paths to your preproc output set up 
    %See the CBIG example script CBIG_MSHBM_create_example_input_data.sh for details on formatting.
    %The script "Create_parc_data.sh" has taken care of this.
    %Steps 1 and 2 have also been ran previous to this.
    %
    %
    %For questions, contact M. Peterson, Nielsen Brain and Behavior Lab

    %Note: Using the GSP Final_Params (FS6 space) from Ruby and CBIG. Per
    %supplementary material for Kong2019 paper, the optimal parameters for the GSP dataset are c=30
    %and alpha=200 (see page 10).


For the actual indivdiual parcellations, we are going to call on a CBIG function. We will run this function for each number of available runs (i.e., all the subjects with only 1 session, all the subjects with only two sessions, etc.). You will need to edit the filename variable and the project_dir variable. 

.. code-block:: matlab 

    %% Subs with 1 run
    %Load text file
        filename = '/nobackup/scratch/grp/fslg_spec_networks/code/HBN_analysis/Kong2019_parc_fs6/sess_numbers/1_sess.txt';
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

    project_dir = '/fslgroup/fslg_autism_networks/compute/HBN_analysis/parc_output_fs6_HBN/generate_individual_parcellations';
    for subid = 1:length(sublist)
            subject=sublist(subid);
        CBIG_MSHBM_generate_individual_parcellation(project_dir,'fsaverage6','1','17',subject,'200','30');
    end


    %% Subs with 2 runs
    %Load text file
        filename = '/nobackup/scratch/grp/fslg_spec_networks/code/HBN_analysis/Kong2019_parc_fs6/sess_numbers/2_sess.txt';
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

    project_dir = '/fslgroup/fslg_autism_networks/compute/HBN_analysis/parc_output_fs6_HBN/generate_individual_parcellations';
    for subid = 1:length(sublist)
            subject=sublist(subid);
        CBIG_MSHBM_generate_individual_parcellation(project_dir,'fsaverage6','2','17',subject,'200','30');
    end


    %% Subs with 3 runs
    %Load text file
        filename = '/nobackup/scratch/grp/fslg_spec_networks/code/HBN_analysis/Kong2019_parc_fs6/sess_numbers/3_sess.txt';
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

    project_dir = '/fslgroup/fslg_autism_networks/compute/HBN_analysis/parc_output_fs6_HBN/generate_individual_parcellations';
    for subid = 1:length(sublist)
            subject=sublist(subid);
        CBIG_MSHBM_generate_individual_parcellation(project_dir,'fsaverage6','3','17',subject,'200','30');
    end

To break this down a little, we will take a closer look at the '%% Subs with 1 run' block of code. 

* First, we are going to load the text file we generated earlier that contains all of the subjects with only 1 available session. You will need to change the filename variable to point to the correct file!
* Second, we will set our project_dir variable (edit this to point to your parcellation output folder). 
* Third, we will loop through each subject in the text file that we loaded and run the CBIG function to compute individual parcellations. 
* Fourth, for the CBIG_MSHBM_generate_individual_parcellation function, we will specify our parameters: project_dir (output directory), 'fsaverage6' (resolution of profiles), '1' (number of sessions), '17' (number of networks), subject (variable for subject name), '200' (alpha value; see Step 2), '3') (c value; see Step 2). 

At this point, we will have our individual parellations! From here, we can start to work with the output and visualize it and perform other calculations such as dice coefficients and network surface area.