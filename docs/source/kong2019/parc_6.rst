Kong2019 Parc: Training Your Own Priors
=======================================

Each of the previously described steps for this parcellation tutorial have assumed that you will be using priors previously trained and made available by CBIG. This is highly advised as these priors were trained at a great cost and are freely available in fsaverage5, fsaverage6, and fsLR 32k resolutions. However, if you attempt to train your own priors, you should know the costs and risks. For one, training your own priors will require a fairly large quantity of data that you can just burn (30-40 subjects). Additionally, there is the chance that the iterations will "fail to converge" and you will be left without priors.

In the event that you desire to train your own priors, here are some tips and scripts for each step. 

Step 1 Initialization 
*********************

After generating individual and group profiles, you will need to generate initialization parameters in preparation for Step 2. 

To do this, first `cd` to the step1 folder within the CBIG repo and then implement the following code in MATLAB. 

.. code-block:: matlab 

    project_dir = '<output_dir>/generate_profiles_and_ini_params';
    num_clusters = '17';
    num_initialization = '1000';
    CBIG_MSHBM_generate_ini_params('fsaverage3','fsaverage6',num_clusters,num_initialization, project_dir)

This code is specifying that there are 17 clusters (networks) and 1000 random initializations. 

.. note:: Depending on the number of random initializations performed (1000 is recommended), you will need to request a large allocation of time and RAM. 

Step 2 Group Priors 
*******************

This step is where we will really diverge from the previous tutorial steps. You will need to separate out your 'training set' or the 30-40 subjects set aside to train these priors. 

Profile Lists
-------------

The first step is to generate profile lists for the training set using a bash script. Note the patterns within this script and adopt it to fit the needs of your dataset.  

.. code-block:: bash 

    #!/bin/bash
    # This is Step 1.5, which will generate the profile lists for Step 2: Estimate Group Priors
    # Previous to this, Parc Step 1 has been completed.

    ##########################
    # Specify output directory
    ##########################
    out_dir=/fslgroup/fslg_HBN_preproc/compute/parc_test_output_MP2
    preproc_output=/fslgroup/fslg_HBN_preproc/compute/preproc_output_MP4
    data_dir=/fslgroup/fslg_HBN_preproc/compute/parc_test_output_MP2/generate_profiles_and_ini_params/profiles
    code_dir=/fslgroup/fslg_autism_networks/compute/code/Kong2019_parc
    
    ########################################
    # Generate profile lists-- 
    ########################################
    mkdir -p $out_dir/estimate_group_priors/profile_list/training_set
    mkdir -p $out_dir/estimate_group_priors/profile_list/test_set
    mkdir -p $out_dir/estimate_group_priors/profile_list/validation_set

    #When specifying sessions, choose the least common denominator for your subjects (e.g., if each subject as at least 2 sessions, choose 2 even if some subjects have more).
    #We chose to specify lists explicitly, but you can alternatively create if/then statements to determine which subject has which number of sessions.
    SESS1and2=(711 181 632 435 576 780 782 476 557 784 791 794 479 714 628 177 463 712)
    SESS1and4=(625)
    SESS3and4=(178 626 179 723)

    SESS1=(43 20 69 96)
    SESS2=(381 710)

    #Sessions 1 and 2
    for sess in {1..2}; do
        for sub in "${SESS1and2[@]}"; do
            lh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess${sess}/\
    lh.sub${sub}_sess${sess}_fsaverage5_roifsaverage3.surf2surf_profile.nii.gz"

            echo $lh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/lh_sess${sess}.txt
                            
            rh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess${sess}/\
    rh.sub${sub}_sess${sess}_fsaverage5_roifsaverage3.surf2surf_profile.nii.gz"

            echo $rh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/rh_sess${sess}.txt
            
        done
    done


    #for subjects with sessions 1 and 4
            for sub in "${SESS1and4[@]}"; do
                lh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess1/\
    lh.sub${sub}_sess1_fsaverage5_roifsaverage3.surf2surf_profile.nii.gz"
                echo $lh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/lh_sess1.txt

                rh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess1/\
    rh.sub${sub}_sess1_fsaverage5_roifsaverage3.surf2surf_profile.nii.gz"
                echo $rh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/rh_sess1.txt
    done

            for sub in "${SESS1and4[@]}"; do
                lh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess4/\
    lh.sub${sub}_sess4_fsaverage5_roifsaverage3.surf2surf_profile.nii.gz"
                echo $lh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/lh_sess2.txt

                rh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess4/\
    rh.sub${sub}_sess4_fsaverage5_roifsaverage3.surf2surf_profile.nii.gz"
                echo $rh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/rh_sess2.txt

    done

    #for subjects with sessions 3 and 4
    for sub in "${SESS3and4[@]}"; do
                lh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess3/\
    lh.sub${sub}_sess3_fsaverage5_roifsaverage3.surf2surf_profile.nii.gz"
                echo $lh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/lh_sess1.txt

                rh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess3/\
    rh.sub${sub}_sess3_fsaverage5_roifsaverage3.surf2surf_profile.nii.gz"
                echo $rh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/rh_sess1.txt
    done    

            for sub in "${SESS3and4[@]}"; do
                lh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess4/\
    lh.sub${sub}_sess4_fsaverage5_roifsaverage3.surf2surf_profile.nii.gz"
                echo $lh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/lh_sess2.txt

                rh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess4/\
    rh.sub${sub}_sess4_fsaverage5_roifsaverage3.surf2surf_profile.nii.gz"
                echo $rh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/rh_sess2.txt

    done

    #For subjects with only one functional run that were split in step 1
    for split in {1,2}; do
        for sub in {1..164}; do
            lh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess1/\
    lh.sub${sub}_sess1_fsaverage5_roifsaverage3.surf2surf_profile_${split}.nii.gz"

            echo $lh_profile >> $out_dir/estimate_group_priors/profile_list/validation_set/lh_sess${split}.txt
            echo $lh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/lh_sess${split}.txt	

            rh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess1/\
    rh.sub${sub}_sess1_fsaverage5_roifsaverage3.surf2surf_profile_${split}.nii.gz"
            
            echo $rh_profile >> $out_dir/estimate_group_priors/profile_list/validation_set/rh_sess${split}.txt
            echo $rh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/rh_sess${split}.txt
        done
    done

    #Split session1
    for split in {1,2}; do
            for sub in "${SESS1[@]}"; do
                    lh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess1/\
    lh.sub${sub}_sess1_fsaverage5_roifsaverage3.surf2surf_profile_${split}.nii.gz"
                    echo $lh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/lh_sess${split}.txt

                    rh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess1/\
    rh.sub${sub}_sess1_fsaverage5_roifsaverage3.surf2surf_profile_${split}.nii.gz"
                    echo $rh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/rh_sess${split}.txt
            done
    done

    #If split session 2
    for split in {1,2}; do
            for sub in "${SESS2[@]}"; do
                    lh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess2/\
    lh.sub${sub}_sess2_fsaverage5_roifsaverage3.surf2surf_profile_${split}.nii.gz"
                    echo $lh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/lh_sess${split}.txt

                    rh_profile="$out_dir/generate_profiles_and_ini_params/profiles/sub${sub}/sess2/\
    rh.sub${sub}_sess2_fsaverage5_roifsaverage3.surf2surf_profile_${split}.nii.gz"
                    echo $rh_profile >> $out_dir/estimate_group_priors/profile_list/training_set/rh_sess${split}.txt
            done
    done


    mkdir -p $out_dir/estimate_group_priors/group
    cp $out_dir/generate_profiles_and_ini_params/group/group.mat $out_dir/estimate_group_priors/group/

    #Order the profiles within each list
    sort ${out_dir}/estimate_group_priors/profile_list/training_set/lh_sess1.txt > ${out_dir}/estimate_group_priors/profile_list/training_set/lh_sess1_sort.txt 
    sort ${out_dir}/estimate_group_priors/profile_list/training_set/rh_sess1.txt > ${out_dir}/estimate_group_priors/profile_list/training_set/rh_sess1_sort.txt 
    sort ${out_dir}/estimate_group_priors/profile_list/training_set/lh_sess2.txt > ${out_dir}/estimate_group_priors/profile_list/training_set/lh_sess2_sort.txt 
    sort ${out_dir}/estimate_group_priors/profile_list/training_set/rh_sess2.txt > ${out_dir}/estimate_group_priors/profile_list/training_set/rh_sess2_sort.txt 

    list_dir=${out_dir}/estimate_group_priors/profile_list/training_set
    mv ${list_dir}/lh_sess1_sort.txt ${list_dir}/lh_sess1.txt
    mv ${list_dir}/rh_sess1_sort.txt ${list_dir}/rh_sess1.txt
    mv ${list_dir}/lh_sess2_sort.txt ${list_dir}/lh_sess2.txt
    mv ${list_dir}/rh_sess2_sort.txt ${list_dir}/rh_sess2.txt	

    echo "Profile lists successfully generated! Step 1.5 is complete."

Once the profile lists are created, you can proceed to the clustering step. 

Clustering 
----------

Next, after entering the step2 directory and launching MATLAB, you can use the following code.

.. code-block:: matlab

    project_dir = '<output_dir>/estimate_group_priors';
    num_sub = 30; 
    num_sessions = 2;
    Params = CBIG_MSHBM_estimate_group_priors(project_dir,'fsaverage6', num_sub, num_sessions,'17','max_iter','1000');

Where the number of subjects reflects the number of subjects within the training set, and the number of sessions reflects the number of sessions for each subject (note that code is available on the CBIG Github repo to split sessions if needed), and '17' refers to the number of networks.

.. note:: Depending on the number of random initializations performed (1000 is recommended), you will need to request a large allocation of time and RAM. 

You can find detailed information about the outputs on `Github <https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/brain_parcellation/Kong2019_MSHBM>`_.


Step 3 Homogeneity and Parcellations 
************************************

Homogeneity Finder
------------------

As we inch towards the individual parcellations, the next step is to identify the optimal 'w' and 'c' parameters using those group priors we just generated in Step 2. To do this, we will use MATLAB. 

.. code-block:: matlab 

    %% CBIG AVERAGE HOMOGENEITY ACROSS PARTICIPANTS
    project_dir= '/fslgroup/fslg_HBN_preproc/compute/parc_test_output_MP2/generate_individual_parcellations/homogeneity/validation_set';

    homogeneity_mat = zeros(30,4,4,2);
    w_values = [60; 80; 100; 120];
    MRF_values = [30; 40; 50; 60];

    for i = 1:30
        for j = 1:4
            for k = 1:4
                w = w_values(j);
                MRF = MRF_values(k);
                load([project_dir, '/Ind_homogeneity_MSHBM_sub', num2str(i), '_w', num2str(w), '_MRF', num2str(MRF),'.mat'])
                homogeneity_mat(i,j,k,:) = homo_with_weight;
            end
        end
    end

    homogeneity_mat_mean_1 = squeeze(mean(homogeneity_mat(:,:,:,1)))
    homogeneity_mat_mean_2 = squeeze(mean(homogeneity_mat(:,:,:,2)))

    %Now it is up to you to identify the w and c combination that resulted in the highest homo value. W=row and MRF=column

Parcellation
------------

Now that you have identified the optimal 'w' and 'c' values, you can use them in generated indivdiual parcellations. Also note that you will need to copy your generated priors from Step 2 into your Step 3 output folder. 

.. code-block:: bash 

    cp -r ${out_dir}/estimate_group_priors/priors ${out_dir}/generate_individual_parcellations

You can then proceed to generate individual parcellations. 

.. code-block:: matlab 

    %Create test_set subj list
    initial = 18:831;
    training = [625 711 178 626 179 557 784 181 791 794 43 20 479 714 381 723 435 628 576 632 69 177 709 710 463 96 780 712 476 782];
    test_set = setdiff(initial,training);
        
    project_dir = '/fslgroup/fslg_HBN_preproc/compute/parc_test_output_MP2/generate_individual_parcellations';
    for subid = test_set
        w = 120; 
        c = 40; 
        CBIG_MSHBM_generate_individual_parcellation(project_dir,'fsaverage6','2','17',num2str(subid),num2str(w),num2str(c));
    end 
    