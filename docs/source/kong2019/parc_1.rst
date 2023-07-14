Kong2019 Parc Step 1
====================

For this step, we will generate individual profiles, a group profile, and the group parcellation. To perform these steps, we will use MATLAB. If you have never used MATLAB in a supercomputing environment, please refer to the MATLAB tutorial (https://neurodocs.readthedocs.io/en/latest/misc/matlab.html).

Beginning Notes
***************

Before beginning this set of steps, you should have completed the Step 0 Generate Data, which generated specifically formatted data lists pointing to your CBIG2016 preproc output. Additionally, note that depending on the number of subjects, these steps make take several hours and require a lot of RAM ~50 - 200G.

.. code-block:: matlab

    %Step 1 of CBIG Kong2019 Brain Parc Pipeline
    %
    %To run: 1. Open Matlab using salloc (ex: `salloc --mem-per-cpu 200G --time 48:00:00 --x11`)
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


Generate Profiles 
*****************

For this step, we will generate functional connectivity profiles for each individual subject using all of their available sessions. We will first specify the subject list, which can be done two different ways. 

.. note:: To run MATLAB steps, such as this, make sure you are in the CBIG repo and running your script from the appropriate step's folder. For this step, you should be in /stable_projects/brain_parcellation/Kong2019_MSHBM/step1_generate_profiles_and_ini_params.

* Option 1. Create an array and list each subject. This option is ideal for a small number of subjects.

.. code-block:: matlab

    sublist = [ "HCD0001305" "HCD0008117" "HCD0021614" "HCD0022919" "HCD0026119" "HCD0029630" "HCD0031617" "HCD0040113" ];

Then, to run this step using Option 1, simply use this code. 

.. code-block:: matlab

    %% Part 1: Generate Profiles for all Subjs 
    seslist = [1 2 3 4 5 6 7 8];
    project_dir = '/fslgroup/fslg_HBN_preproc/compute/HCPD_analysis/parc_output_fs6_HCPD/generate_profiles_and_ini_params'
    for sub = sublist
    for sess = seslist
        try  CBIG_MSHBM_generate_profiles('fsaverage3','fsaverage6',project_dir,num2str(sub),num2str(sess),'0');
        continue
        end
    end 
    end

* Option 2. Load in a text file containing the subject IDs. This option is ideal for a large number of subjects. However, this option has downstream effects for how the profile generation step is called.

.. code-block:: matlab

    %Load subjids text file
    filename = '/nobackup/scratch/grp/fslg_spec_networks/code/HBN_analysis/Kong2019_parc_fs6/subjids/subjids.txt';
    delimiter = {''};
    formatSpec = '%s%[^\n\r]';
    fileID = fopen(filename,'r');
    % Read columns of data according to the format.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
    % Close the text file.
    fclose(fileID);
    subjids = [dataArray{1:end-1}];
    clearvars filename delimiter formatSpec fileID dataArray ans;

    %% Part 1: Generate Profiles for all Subjs 
    seslist = [1 2 3 4 5 6 7 8];

    project_dir = '/fslgroup/fslg_HBN_preproc/compute/HCPD_analysis/parc_output_fs6_HCPD/generate_profiles_and_ini_params'
    for sub = 1:length(subjids)
            subject=subjids(sub);
    for sess = seslist
        try  CBIG_MSHBM_generate_profiles('fsaverage3','fsaverage6',char(project_dir),char(subject),num2str(sess),'0');
        continue
        end
    end 
    end

To generate the profiles for each subject, we are going to loop through each subject and each session within each subject. Because we are using the `try` command, it doesn't matter if a specific subject is missing any sessions--MATLAB will simply skip over these if it can't find the files. 


Group Profile
*************

For this next step, we will generate a profile for the group. This can take some time, so make sure you have requested adequate time in your `salloc` job (12-24 hours depending on the number of subjects). 

.. code-block:: matlab

    %Part 2: Create group profile
    project_dir = '/fslgroup/fslg_HBN_preproc/compute/HCPD_analysis/parc_output_fs6_HCPD/generate_profiles_and_ini_params'
    num_sub = '616';
    num_sess = '9'; %max number of sessions
    CBIG_MSHBM_avg_profiles('fsaverage3','fsaverage6',project_dir,num_sub,num_sess);

This code starts by specifying the project directory, which is the parcellation output directory followed by the /generate_profiles_and_ini_params directory. From here, we specify the number of subjects and the maximum number of sessions available for each subject. Then we call the CBIG script CBIG_MSHBM_avg_profiles.

.. note:: If your data does not conform to BIDS naming conventions exactly, you will run into errors. However, there is a workaround. 

If your naming conventions include a dataset-specific prefix such as 'MSC' or 'HCP' or 'NDAR', you will want to implement this workaround. This involves editing the CBIG script directly, so make sure that you are the only one using your CBIG repo.

For this workaround, we will be loading the subject names using a text file. These edits are made to the CBIG script "CBIG_MSHBM_avg_profiles" which is found in /CBIG/stable_projects/brain_parcellation/Kong2019_MSHBM/step1_generate_profiles_and_ini_params.

.. code-block:: matlab

    %HBN sublist
    filename = '/nobackup/scratch/grp/fslg_spec_networks/code/HBN_analysis/Kong2019_parc_fs6/subjids/SUBJIDS.txt';
        delimiter = {''};
        formatSpec = '%s%[^\n\r]';
        fileID = fopen(filename,'r');
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
        fclose(fileID);
        subjids = [dataArray{1:end-1}];
        clearvars filename delimiter formatSpec fileID dataArray ans;

    for i = 1:length(subjids)
        sub=subjids(i);    
    %for sub = 1:str2num(num_sub)
        for sess = 1:str2num(num_sess)
            sess = num2str(sess);           
            out_profile_dir = fullfile(char(out_dir),'profiles',strcat('sub', sub),strcat('sess',sess));    

Group Parcellation 
******************   

Now we will generate a group parcellation! This step can take a while, so make sure you have requested adequate RAM and time (24 hours or more depending on the number of initializations). 

.. code-block:: matlab

    %Part 3: Create group.mat with group parc
    project_dir = '/fslgroup/fslg_HBN_preproc/compute/HCPD_analysis/parc_output_fs6_HCPD/generate_profiles_and_ini_params'
    num_clusters = '17';
    num_initialization = '1000';
    CBIG_MSHBM_generate_ini_params('fsaverage3','fsaverage6',num_clusters,num_initialization, project_dir)

.. note:: If you desire a group parcellation using onlly a subset of your participants (such as participants in a specific clinical group), you will need to first generate the group LH and RH profiles using only those desired subjects and then generate the parcellation using those profiles. 

Expected Output 
***************

Within your parcellation output folder and within the generate_profiles_and_ini_params directory, you should see /group /data_list and /profiles folders. The group parcellation is stored in the group folder (group.mat) and all of the profiles are stored within the /profiles folder. 

Troubleshooting Help 
********************

Some common errors include the following. 

* fscanf cannot open... In this case, your paths somewhere are incorrect. Doublecheck your paths in the generate_profiles_and_ini_params/data_list/fMRI. Also, your project_dir could be incorrect. Also, the format of the data_list/fMRI_list text files names may be incorrect.
* CBIG_MSHBM_generate_ini_params function not found (or something like that)... You need to be in the step1 folder to run this script. If you are in a different directory, you will encounter this error.It may help to copy this script over to the script1 directory and then open matlab...

If MATLAB has crashed unexpectedly, you most likely have not requested adequate memory or time. You can check your job stats to see if this is the case on your account at rc.byu.edu. 

Addendum
********

For subjects with a single session, `CBIG documentation advises <https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/brain_parcellation/Kong2019_MSHBM>`__ splitting this session to create two sessions. This can be accomplished by changing the split flag from '0' to '1'. 

Here is an example of detecting if more than one session is available and then splitting accordingly. 

.. code-block:: matlab

    seslist = [1 2 3 4];
    preproc_dir= '/fslgroup/fslg_HBN_preproc/compute/HCP_analysis/CBIG2016_preproc_FS6';
    project_dir = '/fslgroup/fslg_HBN_preproc/compute/HCP_analysis/parc_output_fs6_HCP_REPLICATION/generate_profiles_and_ini_params'
    for subid = 1:length(sublist)
        sub=sublist(subid);
        sub = strtrim(sub);
        ses1=strcat('lh.sub-', sub, '_bld001_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz');
        str1 = fullfile(preproc_dir,strcat('sub-', sub), strcat('sub-', sub), 'surf', ses1);
        ses2=strcat('lh.sub-', sub, '_bld002_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz');
            str2 = fullfile(preproc_dir,strcat('sub-', sub), strcat('sub-', sub), 'surf', ses2);
        ses3=strcat('lh.sub-', sub, '_bld003_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz');
        str3 = fullfile(preproc_dir, strcat('sub-', sub), strcat('sub-', sub), 'surf', ses3);
        ses4=strcat('lh.sub-', sub, '_bld004_rest_skip4_mc_resid_bp_0.009_0.08_fs6_sm6_fs6.nii.gz');
        str4=fullfile(preproc_dir, strcat('sub-', sub), strcat('sub-', sub), 'surf', ses4);


        %Count number of sessions available
        file_variables = {str1, str2, str3, str4};  % Store file variables in a cell array
        file_count=0;
        for i = 1:length(file_variables)
            file = file_variables{i};
            if isfile(file)
                file_count = file_count + 1;
            end
        end


        %Generate profiles
        if file_count > 1
                for sess = seslist
                    try CBIG_MSHBM_generate_profiles('fsaverage3','fsaverage6',char(project_dir),num2str(sub),num2str(sess),'0');
                    continue
                    end
                end
        else
                for sess = seslist
                    try CBIG_MSHBM_generate_profiles('fsaverage3','fsaverage6',char(project_dir),num2str(sub),num2str(sess),'1');
                    continue
                    end
                end
        end
    end


